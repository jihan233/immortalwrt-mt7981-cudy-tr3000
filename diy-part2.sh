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

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# add date in output file name
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk

# set ubi to 122M
# sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts

# Add OpenClash Meta
mkdir -p files/etc/openclash/core

wget -qO "clash_meta.tar.gz" "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
tar -zxvf "clash_meta.tar.gz" -C files/etc/openclash/core/
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash_meta
rm -f "clash_meta.tar.gz"
# Description: Modify memory definition for TR3000 512M RAM mod
# Warning: Only strictly for hardware modified to 512M RAM

# 1. 查找 TR3000 的设备树文件 (通常位于 target/linux/mediatek 目录下)
dts_file=$(find target/linux/mediatek -name "mt7981-cudy-tr3000.dts")

if [ -f "$dts_file" ]; then
    echo "Found DTS file: $dts_file"
    
    # 2. 将内存定义从 256M (0x10000000) 修改为 512M (0x20000000)
    # 原始代码通常为: reg = <0 0x40000000 0 0x10000000>;
    sed -i 's/0 0x10000000/0 0x20000000/g' "$dts_file"
    
    # 二次确认（有些源码写法可能是十六进制小写或不同格式，增加一种通用匹配）
    # 如果上面的 sed 没生效，尝试直接匹配 reg 节点
    sed -i '/memory/,/};/ s/0x10000000/0x20000000/' "$dts_file"

    echo "Memory limit updated to 512MB for TR3000."
else
    echo "Error: TR3000 DTS file not found!"
    exit 1
fi
