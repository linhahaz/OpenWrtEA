#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

function config_del(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"

    sed -i "s/$yes/$no/" .config
}

function config_add(){
    yes="CONFIG_$1=y"
    no="# CONFIG_$1 is not set"

    sed -i "s/${no}/${yes}/" .config

    if ! grep -q "$yes" .config; then
        echo "$yes" >> .config
    fi
}

function config_package_del(){
    package="PACKAGE_$1"
    config_del $package
}

function config_package_add(){
    package="PACKAGE_$1"
    config_add $package
}

# 取消默认密码（恢复空密码直接登录）
# sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 删除
# Firmware
#config_package_del i915-firmware-dmc
# CAKE 算法支持
config_package_add kmod-sched-cake
# Video Support
config_package_del kmod-acpi-video
config_package_del kmod-backlight
config_package_del kmod-drm
config_package_del kmod-drm-buddy
config_package_del kmod-drm-display-helper
config_package_del kmod-drm-exec
config_package_del kmod-drm-i915
config_package_del kmod-drm-kms-helper
config_package_del kmod-drm-suballoc-helper
config_package_del kmod-drm-ttm
config_package_del kmod-drm-ttm-helper
config_package_del kmod-fb
config_package_del kmod-fb-cfb-copyarea
config_package_del kmod-fb-cfb-fillrect
config_package_del kmod-fb-cfb-imgblt
config_package_del kmod-fb-sys-fops
config_package_del kmod-fb-sys-ram
config_package_del ipv6helper
config_package_del odhcp6c
# Other
config_package_del luci-app-rclone_INCLUDE_rclone-webui
config_package_del luci-app-rclone_INCLUDE_rclone-ng
# 新增
# Firmware
config_package_add intel-microcode
# KVM 专属驱动优化
config_package_add kmod-virtio-console
config_package_add kmod-virtio-balloon
config_package_add kmod-virtio-rng
config_package_add qemu-ga
config_package_add irqbalance
# 强制编译 AES-NI 硬件加速指令集支持
config_package_add kmod-crypto-hw-aesni
config_package_add kmod-crypto-hw-padlock
# luci
config_package_add luci
config_package_add default-settings-chn
# bbr
config_package_add kmod-tcp-bbr
# coremark cpu 跑分
config_package_add coremark
# autocore： cpu 频率与基础状态显示
config_package_add autocore
# nano 替代 vim
config_package_add nano
# tty 终端
config_package_add luci-app-ttyd
# tun
config_package_add kmod-tun
config_package_add ip-full
config_package_add kmod-nft-socket
config_package_add kmod-nft-tproxy
config_package_add kmod-nft-nat

# 保留原生的 offload 作为备用
config_package_add kmod-nft-offload

## 新增插件
config_package_add luci-app-homeproxy
config_package_add luci-i18n-homeproxy-zh-cn

# 系统底层优化 (BBR + 时区 + 禁用IPv6)
# 强制开启 cake
echo "net.core.default_qdisc=cake" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> package/base-files/files/etc/sysctl.conf

# 彻底禁用 IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf

# 默认设置上海时区
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 调整最大连接数为 262144
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=262144' package/base-files/files/etc/sysctl.conf
# 彻底关闭内核调试符号 (加快编译速度，减小固件体积)
sed -i 's/CONFIG_DEBUG_INFO=y/# CONFIG_DEBUG_INFO is not set/g' .config
sed -i 's/CONFIG_DEBUG_KERNEL=y/# CONFIG_DEBUG_KERNEL is not set/g' .config

# 镜像生成
# 修改分区大小
sed -i "/CONFIG_TARGET_KERNEL_PARTSIZE/d" .config
echo "CONFIG_TARGET_KERNEL_PARTSIZE=32" >> .config
sed -i "/CONFIG_TARGET_ROOTFS_PARTSIZE/d" .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=1024" >> .config
# 调整 GRUB_TIMEOUT
sed -i "s/CONFIG_GRUB_TIMEOUT=\"3\"/CONFIG_GRUB_TIMEOUT=\"1\"/" .config
## 不生成 EXT4 硬盘格式镜像
config_del TARGET_ROOTFS_EXT4FS
## 不生成非 EFI 镜像
config_del GRUB_IMAGES
