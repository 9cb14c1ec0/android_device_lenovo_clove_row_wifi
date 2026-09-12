#include <android-base/file.h>
#include <android-base/strings.h>

#include <fcntl.h>
#include <signal.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <unistd.h>

#include <chrono>
#include <algorithm>
#include <cstdlib>
#include <cerrno>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

namespace {

constexpr char kDefaultList[] = "/system/etc/lenovo-modules.safe";
constexpr char kLogPath[] = "/tmp/lenovo-module-loader.log";
constexpr auto kPollInterval = std::chrono::milliseconds(50);

const std::vector<std::string> kSearchPaths = {
        "/lib/modules",
        "/vendor_dlkm/lib/modules",
        "/vendor/lib/modules",
};

void Log(const std::string& message) {
    std::ofstream log(kLogPath, std::ios::app);
    log << message << '\n';
    std::cerr << message << '\n';
}

std::string ModuleName(std::string filename) {
    filename = android::base::Basename(filename);
    if (android::base::EndsWith(filename, ".ko")) filename.resize(filename.size() - 3);
    std::replace(filename.begin(), filename.end(), '-', '_');
    return filename;
}

bool IsLoaded(const std::string& filename) {
    std::string modules;
    if (!android::base::ReadFileToString("/proc/modules", &modules)) return false;
    const std::string prefix = ModuleName(filename) + " ";
    for (const auto& line : android::base::Split(modules, "\n")) {
        if (android::base::StartsWith(line, prefix)) return true;
    }
    return false;
}

std::string FindModule(const std::string& entry) {
    if (android::base::StartsWith(entry, "/") && access(entry.c_str(), R_OK) == 0) return entry;
    for (const auto& directory : kSearchPaths) {
        const std::string path = directory + "/" + entry;
        if (access(path.c_str(), R_OK) == 0) return path;
    }
    return {};
}

int InsertModule(const std::string& path, const std::string& parameters) {
    int fd = open(path.c_str(), O_RDONLY | O_CLOEXEC);
    if (fd < 0) return errno;
    int result = syscall(SYS_finit_module, fd, parameters.c_str(), 0);
    int error = result == 0 ? 0 : errno;
    close(fd);
    return error;
}

int LoadWithTimeout(const std::string& path, const std::string& parameters, int timeout_ms) {
    pid_t pid = fork();
    if (pid < 0) return errno;
    if (pid == 0) _exit(InsertModule(path, parameters));

    const auto deadline = std::chrono::steady_clock::now() + std::chrono::milliseconds(timeout_ms);
    int status = 0;
    while (std::chrono::steady_clock::now() < deadline) {
        pid_t result = waitpid(pid, &status, WNOHANG);
        if (result == pid) return WIFEXITED(status) ? WEXITSTATUS(status) : EINTR;
        if (result < 0) return errno;
        std::this_thread::sleep_for(kPollInterval);
    }

    kill(pid, SIGKILL);
    waitpid(pid, &status, WNOHANG);
    return ETIMEDOUT;
}

std::vector<std::string> ReadList(const std::string& path) {
    std::string contents;
    std::vector<std::string> entries;
    if (!android::base::ReadFileToString(path, &contents)) return entries;
    for (auto line : android::base::Split(contents, "\n")) {
        line = android::base::Trim(line);
        if (!line.empty() && line[0] != '#') entries.push_back(line);
    }
    return entries;
}

}  // namespace

int main(int argc, char** argv) {
    std::string list_path = kDefaultList;
    int timeout_ms = 3000;
    if (argc > 1) list_path = argv[1];
    if (argc > 2) timeout_ms = std::max(100, atoi(argv[2]));

    Log("START list=" + list_path + " timeout_ms=" + std::to_string(timeout_ms));
    const auto entries = ReadList(list_path);
    if (entries.empty()) {
        Log("FATAL empty or unreadable module list");
        return 2;
    }

    int failures = 0;
    for (const auto& entry : entries) {
        const auto fields = android::base::Split(entry, " ");
        const std::string module = fields.front();
        const std::string parameters = entry.size() > module.size()
                                               ? android::base::Trim(entry.substr(module.size()))
                                               : "";
        if (IsLoaded(module)) {
            Log("SKIP already-loaded " + ModuleName(module));
            continue;
        }
        const std::string path = FindModule(module);
        if (path.empty()) {
            Log("FAIL not-found " + module);
            ++failures;
            continue;
        }

        Log("BEGIN " + path);
        const int error = LoadWithTimeout(path, parameters, timeout_ms);
        if (error == 0 || error == EEXIST) {
            Log("OK " + ModuleName(module));
        } else if (error == ETIMEDOUT) {
            Log("TIMEOUT " + ModuleName(module));
            ++failures;
            break;
        } else {
            Log("FAIL " + ModuleName(module) + " errno=" + std::to_string(error) + " " +
                strerror(error));
            ++failures;
        }
    }
    Log("DONE failures=" + std::to_string(failures));
    return failures == 0 ? 0 : 1;
}
