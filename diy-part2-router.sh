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

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

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
# python3
#config_package_add python3
#config_package_add python3-base
#config_package_add python3-pip
# tty 终端
config_package_add luci-app-ttyd
# tun
config_package_add kmod-tun
config_package_add ip-full
config_package_add kmod-nft-socket
config_package_add kmod-nft-tproxy
config_package_add kmod-nft-nat
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
# 第三方软件包

# 保留原生的 offload 作为备用
config_package_add kmod-nft-offload

## 替换 Golang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# OpenWrt-momo
# git clone https://github.com/nikkinikki-org/OpenWrt-momo.git package/OpenWrt-momo

## MosDNS v5
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata

# 克隆源码到 package 目录
git clone --depth 1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

## 新增插件
config_package_add luci-app-mosdns
config_package_add mosdns
config_package_add luci-i18n-mosdns-zh-cn
config_package_add luci-app-homeproxy
config_package_add luci-i18n-homeproxy-zh-cn
config_package_add luci-app-autoreboot
config_package_add luci-app-partexp
# config_package_add momo
# config_package_add luci-app-momo
# config_package_add luci-i18n-momo-zh-cn
config_package_add shadowsocksr-libev-ssr-check
config_package_add shadowsocksr-libev-ssr-local
config_package_add shadowsocksr-libev-ssr-redir
config_package_add shadowsocksr-libev-ssr-server
# 系统底层优化 (BBR + 时区 + 禁用IPv6)
# 强制开启 BBR
echo "net.core.default_qdisc=fq" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> package/base-files/files/etc/sysctl.conf

# 彻底禁用 IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> package/base-files/files/etc/sysctl.conf

# 默认设置上海时区
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
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
