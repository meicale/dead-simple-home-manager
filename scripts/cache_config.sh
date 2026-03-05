#!/bin/bash
# 缓存配置脚本

# 引用环境变量和函数配置
SCRIPT_DIR="$HOME/.config/home-manager/scripts"

if [ -f "$SCRIPT_DIR/cache_envs.sh" ]; then
    source "$SCRIPT_DIR/cache_envs.sh"
else
    echo "错误：cache_envs.sh 文件不存在: $SCRIPT_DIR/cache_envs.sh"
    exit 1
fi

# 确保共享目录存在
mkdir -p "$SHARED_BASE"/{cache,data,state,conda/{envs,pkgs}}
mkdir -p "$SHARED_BASE"/cache/{huggingface,pip,uv,poetry,torch,node,yarn,npm,go-build,cargo,atuin,llama.cpp}
mkdir -p "$SHARED_BASE"/data/{atuin,zoxide,direnv,pipx}
mkdir -p "$SHARED_BASE"/state/nix

# 创建符号链接
create_symlink "$XDG_CACHE_HOME/huggingface" "$HOME/.cache/huggingface"
create_symlink "$XDG_CACHE_HOME/pip" "$HOME/.cache/pip"
create_symlink "$XDG_CACHE_HOME/uv" "$HOME/.cache/uv"
create_symlink "$XDG_CACHE_HOME/poetry" "$HOME/.cache/poetry"
create_symlink "$XDG_CACHE_HOME/torch" "$HOME/.cache/torch"
create_symlink "$CONDA_ENVS_PATH" "$HOME/.conda/envs"
create_symlink "$CONDA_PKGS_DIRS" "$HOME/.conda/pkgs"
create_symlink "$MAMBA_ROOT_PREFIX" "$HOME/.micromamba"
create_symlink "$LLAMA_CACHE" "$HOME/.cache/llama.cpp"

# 如果直接执行脚本，则运行配置
if [[ "$0" == "$BASH_SOURCE" ]]; then
    echo "执行缓存配置..."
    echo "缓存配置初始化完成！"
fi
