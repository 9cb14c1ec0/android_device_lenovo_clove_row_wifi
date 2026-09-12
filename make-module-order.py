#!/usr/bin/env python3
"""Topologically order Android kernel modules using modules.dep."""

import argparse
from pathlib import Path


parser = argparse.ArgumentParser()
parser.add_argument("modules_dep", type=Path)
parser.add_argument("modules_load", type=Path)
args = parser.parse_args()

deps = {}
paths = {}
for line in args.modules_dep.read_text().splitlines():
    target, _, requirements = line.partition(":")
    name = Path(target).name
    paths[name] = target
    deps[name] = [Path(item).name for item in requirements.split()]

requested = [Path(line.strip()).name for line in args.modules_load.read_text().splitlines() if line.strip()]
ordered = []
visiting = set()
visited = set()


def visit(name):
    if name in visited or name not in deps:
        return
    if name in visiting:
        raise RuntimeError(f"dependency cycle at {name}")
    visiting.add(name)
    for dependency in deps[name]:
        visit(dependency)
    visiting.remove(name)
    visited.add(name)
    ordered.append(paths[name])


for module in requested:
    visit(module)

print("\n".join(ordered))
