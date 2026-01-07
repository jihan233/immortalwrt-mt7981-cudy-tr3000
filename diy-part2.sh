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
# -------------------------------------------------------
# 融合 Cudy TR3000 512MB 内存支持
# -------------------------------------------------------
echo "正在修改 Cudy TR3000 内存配置为 512MB..."

# 1. 查找设备树文件 (通常路径在 target/linux/mediatek/files-5.4/...)
# 使用 find 命令模糊匹配，防止源码路径变更导致找不到文件
TR3000_DTS=$(find target/linux/mediatek -name "mt7981-cudy-tr3000.dts")

if [ -n "$TR3000_DTS" ]; then
    echo "找到设备树文件: $TR3000_DTS"

    # 2. 修改内存大小
    # 原厂 256MB = 0x10000000
    # 魔改 512MB = 0x20000000
    # 下面的命令会将 DTS 文件中的 0x10000000 替换为 0x20000000
    sed -i 's/0x10000000/0x20000000/g' "$TR3000_DTS"

    # (可选) 如果源码里写的是 <0 0x10000000> 这种形式，上面的命令也能通用匹配
    # 再次确认是否替换成功
    if grep -q "0x20000000" "$TR3000_DTS"; then
        echo "成功: 内存已修改为 512MB (0x20000000)"
    else
        echo "警告: 修改可能失败，请检查日志"
    fi
else
    echo "错误: 未找到 Cudy TR3000 的设备树文件，无法修改内存！"
fi
