#!/bin/bash
# 更新缓存配置脚本

echo "更新缓存配置..."
if [ -f ~/.cache_config.sh ]; then
    source ~/.cache_config.sh
    echo "缓存配置已更新"
    echo ""
    echo "=== 缓存配置状态 ==="
    echo "Conda环境目录: $CONDA_ENVS_PATH"
    echo "Conda包缓存: $CONDA_PKGS_DIRS"
    echo "MicroMamba根目录: $MAMBA_ROOT_PREFIX"
    echo ""
    echo "使用 cache_paths 命令查看详细路径映射"
else
    echo "错误: 缓存配置脚本不存在"
    echo "请先运行 home-manager switch 生成配置脚本"
fi