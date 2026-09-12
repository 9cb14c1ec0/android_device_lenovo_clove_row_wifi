// SPDX-License-Identifier: GPL-2.0
/* Recovery-only stubs for Lenovo's optional proximity/touch notification ABI. */

#include <linux/module.h>
#include <linux/notifier.h>

int ps_enable_register_notifier(struct notifier_block *nb)
{
	/* TWRP has no proximity policy consumer. */
	return 0;
}
EXPORT_SYMBOL(ps_enable_register_notifier);

int tpd_register_psenable_callback(void)
{
	return 0;
}
EXPORT_SYMBOL(tpd_register_psenable_callback);

int tpd_notifier_call_chain(unsigned long action, void *data)
{
	return NOTIFY_DONE;
}
EXPORT_SYMBOL(tpd_notifier_call_chain);

static int __init lenovo_touch_compat_init(void)
{
	return 0;
}

module_init(lenovo_touch_compat_init);

MODULE_DESCRIPTION("Lenovo TB305FU recovery-only touch compatibility stubs");
MODULE_LICENSE("GPL v2");
