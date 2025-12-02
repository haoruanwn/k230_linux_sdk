#!/bin/bash
set -e

# 定义颜色
GREEN='\033[0;32m'
NC='\033[0m'

TARGET_DIR="/opt/toolchain"
TOOLCHAIN_URL="https://kendryte-download.canaan-creative.com/k230/downloads/dl/gcc/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.0.2-20250410.tar.gz"
TOOLCHAIN_FILE="Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.0.2-20250410.tar.gz"

echo -e "${GREEN}>>> 开始配置 K230 交叉编译工具链...${NC}"

# 检查是否已有文件
if [ -d "$TARGET_DIR/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.0.2" ]; then
    echo "检测到工具链已存在于 $TARGET_DIR，跳过安装。"
    echo "如果需要重新安装，请先删除该目录。"
    exit 0
fi

# 确保目标目录存在
# 注意：在容器内如果已经是以 root 或对应权限用户运行，可能不需要 sudo，
# 但为了兼容性保留 sudo (如果容器内没安装 sudo，请去掉它)
if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    SUDO=""
fi

$SUDO mkdir -p $TARGET_DIR
$SUDO chown -R $(whoami) $TARGET_DIR

cd $TARGET_DIR

# 下载
if [ ! -f "$TOOLCHAIN_FILE" ]; then
    echo "正在下载工具链 (约 400MB)..."
    # === 修改点：添加了 --no-check-certificate ===
    wget -c --no-check-certificate "$TOOLCHAIN_URL" -O "$TOOLCHAIN_FILE"
else
    echo "检测到压缩包已存在，跳过下载。"
fi

# 解压
echo "正在解压..."
tar -zxvf "$TOOLCHAIN_FILE"

# 验证
echo -e "${GREEN}>>> 验证安装...${NC}"
TEST_CMD="$TARGET_DIR/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.0.2/bin/riscv64-unknown-linux-gnu-gcc --version"
if $TEST_CMD > /dev/null 2>&1; then
    echo -e "${GREEN}成功！工具链版本信息：${NC}"
    $TEST_CMD | head -n 1
    # 清理压缩包
    rm "$TOOLCHAIN_FILE"
else
    echo "错误：工具链安装似乎失败了，无法执行 gcc。"
    exit 1
fi

echo -e "${GREEN}>>> 所有配置完成！${NC}"