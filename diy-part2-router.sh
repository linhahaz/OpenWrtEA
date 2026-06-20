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
# Sound Support
config_package_del kmod-sound-core
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
# autocore + lm-sensors-detect： cpu 频率、温度
config_package_add autocore
config_package_add lm-sensors-detect
# nano 替代 vim
config_package_add nano
# upnp
config_package_add luci-app-upnp
# autoreboot
#config_package_add luci-app-autoreboot
# python3
#config_package_add python3
#config_package_add python3-base
#config_package_add python3-pip
# tty 终端
config_package_add luci-app-ttyd
# docker
# config_package_add luci-app-dockerman
# kms
# config_package_add luci-app-vlmcsd
# usb 2.0 3.0 支持
config_package_add kmod-usb2
config_package_add kmod-usb3
# usb 网络支持
config_package_add usbmuxd
config_package_add usbutils
config_package_add usb-modeswitch
config_package_add kmod-usb-serial
config_package_add kmod-usb-serial-option
config_package_add kmod-usb-net-rndis
config_package_add kmod-usb-net-ipheth
## argon 主题
## config_package_add luci-theme-argon
## 新增插件
config_package_add luci-app-homeproxy
config_package_add luci-i18n-homeproxy-zh-cn
## 定时任务。重启、关机、重启网络、释放内存、系统清理、网络共享、关闭网络、自动检测断网重连、MWAN3负载均衡检测重连、自定义脚本等10多个功能
#config_package_add luci-app-taskplan
#config_package_add luci-lib-ipkg
#config_package_add bash
## 分区扩容。一键自动格式化分区、扩容、自动挂载插件，专为OPENWRT设计，简化OPENWRT在分区挂载上烦锁的操作
config_package_add luci-app-partexp
## iStore 应用市场
#config_package_add luci-app-store
## qmodem 4G/5G 支持
## config_package_add luci-app-qmodem-next
## luci-app-easytier
## config_package_add luci-app-easytier
## config_package_add easytier

# 系统底层优化 (BBR + 时区 + 禁用IPv6)
# 强制开启 bbr
echo "net.core.default_qdisc = fq" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> package/base-files/files/etc/sysctl.conf

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
