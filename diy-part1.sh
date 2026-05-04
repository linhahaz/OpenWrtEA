#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 使用 O2 级别的优化
# sed -i 's,Os,O2 -march=x86-64-v2,g' include/target.mk

# 替换原来的 O2 优化代码：
sed -i 's,Os,O2 -march=x86-64-v3,g' include/target.mk

# 关闭 Spectre & Meltdown 补丁
# sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-efi.cfg
# sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-iso.cfg
# sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-pc.cfg

# PVE 虚拟机底层 GRUB 优化 
# mitigations=off：关闭漏洞缓解
# tsc=reliable：提升虚拟机时钟精度，减少开销
sed -i 's,noinitrd,noinitrd mitigations=off tsc=reliable,g' target/linux/x86/image/grub-efi.cfg
sed -i 's,noinitrd,noinitrd mitigations=off tsc=reliable,g' target/linux/x86/image/grub-iso.cfg
sed -i 's,noinitrd,noinitrd mitigations=off tsc=reliable,g' target/linux/x86/image/grub-pc.cfg

# 添加第三方插件源
# echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >> feeds.conf.default
# echo 'src-git small https://github.com/kenzok8/small' >> feeds.conf.default
