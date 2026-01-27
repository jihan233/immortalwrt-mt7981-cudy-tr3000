#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 修改固件文件名增加日期 (保留原功能)
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk

# -------------------------------------------------------------------------
# [新增] TR3000 512M 内存修改逻辑
# -------------------------------------------------------------------------
target_device="${DEVICE_INPUT:-256M}"

if [[ "$target_device" == "512M" ]]; then
    echo "正在执行 TR3000 512M 内存补丁..."
    
    # 直接修改 target/linux/mediatek/dts/ 目录下所有匹配 tr3000 的 dts 文件
    # 使用 * 通配符，无论文件叫 mt7981-cudy-tr3000.dts 还是 mt7981b... 都能匹配到
    
    # 核心修改：将 256M (0x10000000) 替换为 512M (0x20000000)
    sed -i 's/0 0x10000000/0 0x20000000/g' target/linux/mediatek/dts/mt7981*-cudy-tr3000*.dts
    
    # 保险措施：备用匹配规则，确保修改生效
    sed -i '/memory/,/};/ s/0x10000000/0x20000000/' target/linux/mediatek/dts/mt7981*-cudy-tr3000*.dts
    
    echo "512M 补丁已应用。"
else
    echo "当前为 $target_device 模式，不做内存修改。"
fi
# -------------------------------------------------------------------------

# 2. Add OpenClash Meta (保留原功能)
mkdir -p files/etc/openclash/core
wget -qO "clash_meta.tar.gz" "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
tar -zxvf "clash_meta.tar.gz" -C files/etc/openclash/core/
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash_meta
rm -f "clash_meta.tar.gz"
