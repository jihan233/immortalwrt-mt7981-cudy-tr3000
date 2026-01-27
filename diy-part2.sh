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

# -------------------------------------------------------------------------
# [新增] TR3000 512M 内存改机专用逻辑
# 功能：通过 YML 传入的 DEVICE_INPUT 变量判断，如果是 512M 选项，自动修改 DTS
# -------------------------------------------------------------------------
target_device="${DEVICE_INPUT:-256M}" # 如果变量为空，默认视为 256M

if [[ "$target_device" == "512M" ]]; then
    echo "======================================================="
    echo "检测到 512M 编译选项，正在修改内存配置..."
    
    # 查找 DTS 文件路径 (通常是 mt7981-cudy-tr3000.dts)
    dts_file=$(find target/linux/mediatek -name "mt7981-cudy-tr3000.dts")
    
    if [ -f "$dts_file" ]; then
        echo "找到 DTS 文件: $dts_file"
        # 将 256M (0x10000000) 修改为 512M (0x20000000)
        sed -i 's/0 0x10000000/0 0x20000000/g' "$dts_file"
        
        # 二次保险修改（防止上面的替换未生效）
        sed -i '/memory/,/};/ s/0x10000000/0x20000000/' "$dts_file"
        
        # 检查是否修改成功
        if grep -q "0x20000000" "$dts_file"; then
            echo "修改成功！内存上限已调整为 512MB"
        else
            echo "错误：内存修改失败，请检查源码结构！"
            exit 1
        fi
    else
        echo "错误：未找到 TR3000 设备树文件！"
        exit 1
    fi
    echo "======================================================="
else
    echo "当前为标准版 (256M/128M) 编译，跳过内存修改。"
fi
# -------------------------------------------------------------------------


# Add OpenClash Meta
mkdir -p files/etc/openclash/core

wget -qO "clash_meta.tar.gz" "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
tar -zxvf "clash_meta.tar.gz" -C files/etc/openclash/core/
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash_meta
rm -f "clash_meta.tar.gz"
