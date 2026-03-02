#!/bin/bash
# 缓存配置脚本
# 共享存储基础路径
SHARED_BASE="/mnt/wsl/persistent"

# 确保共享目录存在
mkdir -p "$SHARED_BASE"/{cache,data,state,conda/{envs,pkgs}}
mkdir -p "$SHARED_BASE"/cache/{huggingface,pip,uv,poetry,torch,node,yarn,npm,go-build,cargo,atuin}
mkdir -p "$SHARED_BASE"/data/{atuin,zoxide,direnv,pipx}
mkdir -p "$SHARED_BASE"/state/nix

# 设置XDG环境变量
export XDG_CACHE_HOME="$SHARED_BASE/cache"
export XDG_DATA_HOME="$SHARED_BASE/data"
export XDG_STATE_HOME="$SHARED_BASE/state"

# Python相关
export HF_HOME="$XDG_CACHE_HOME/huggingface"
export HUGGINGFACE_HUB_CACHE="$HF_HOME"
export TRANSFORMERS_CACHE="$HF_HOME/hub"
export PIP_CACHE_DIR="$XDG_CACHE_HOME/pip"
export UV_CACHE_DIR="$XDG_CACHE_HOME/uv"
export POETRY_CACHE_DIR="$XDG_CACHE_HOME/poetry"

# PyTorch相关
export TORCH_HOME="$XDG_CACHE_HOME/torch"
# 或使用XDG标准: export TORCH_XDG_HOME="1"

# Conda/Micromamba共享配置
export CONDA_ENVS_PATH="$SHARED_BASE/conda/envs"
export CONDA_PKGS_DIRS="$SHARED_BASE/conda/pkgs"
export MAMBA_ROOT_PREFIX="$SHARED_BASE/conda"
export MAMBA_ENVS_DIRS="$SHARED_BASE/conda/envs"
export MAMBA_PKGS_DIRS="$SHARED_BASE/conda/pkgs"

# Node.js
export npm_config_cache="$XDG_CACHE_HOME/npm"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/yarn"

# Go
export GOCACHE="$XDG_CACHE_HOME/go-build"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Zsh相关
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-$HOST"

# Zoxide
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

# Direnv
export DIRENV_LOG_FORMAT=""
export DIRENV_WATCHES="$XDG_DATA_HOME/direnv/watches"

# 创建必要的符号链接（仅在不存在时）
create_symlink() {
    local target="$1"
    local link="$2"
    
    if [ ! -e "$link" ]; then
        mkdir -p "$(dirname "$link")"
        ln -s "$target" "$link"
        echo "Created symlink: $link -> $target"
    fi
}

# 创建符号链接
create_symlink "$XDG_CACHE_HOME/huggingface" "$HOME/.cache/huggingface"
create_symlink "$XDG_CACHE_HOME/pip" "$HOME/.cache/pip"
create_symlink "$XDG_CACHE_HOME/uv" "$HOME/.cache/uv"
create_symlink "$XDG_CACHE_HOME/poetry" "$HOME/.cache/poetry"
create_symlink "$XDG_CACHE_HOME/torch" "$HOME/.cache/torch"
create_symlink "$CONDA_ENVS_PATH" "$HOME/.conda/envs"
create_symlink "$CONDA_PKGS_DIRS" "$HOME/.conda/pkgs"
create_symlink "$MAMBA_ROOT_PREFIX" "$HOME/.micromamba"

# 缓存路径查看函数
cache_paths() {
    echo "=== 缓存路径映射 ==="
    echo "共享基础路径: $SHARED_BASE"
    echo "XDG_CACHE_HOME: $XDG_CACHE_HOME"
    echo "XDG_DATA_HOME: $XDG_DATA_HOME"
    echo "XDG_STATE_HOME: $XDG_STATE_HOME"
    echo ""
    echo "=== 具体缓存路径 ==="
    echo "HuggingFace: $HF_HOME"
    echo "Pip: $PIP_CACHE_DIR"
    echo "UV: $UV_CACHE_DIR"
    echo "Poetry: $POETRY_CACHE_DIR"
    echo "PyTorch: $TORCH_HOME"
    echo "Conda环境: $CONDA_ENVS_PATH"
    echo "Conda包缓存: $CONDA_PKGS_DIRS"
    echo "MicroMamba根目录: $MAMBA_ROOT_PREFIX"
    echo ""
    echo "=== 符号链接状态 ==="
    ls -la "$HOME/.cache/" | grep -E "(huggingface|pip|uv|poetry|torch)"
    ls -la "$HOME/.conda/" | grep -E "(envs|pkgs)"
    ls -la "$HOME/" | grep micromamba
}

# 清理缓存函数
clean_cache() {
    local cache_type="$1"
    
    case "$cache_type" in
        "all")
            echo "清理所有缓存..."
            rm -rf "$XDG_CACHE_HOME"/*
            rm -rf "$CONDA_PKGS_DIRS"/*
            mkdir -p "$XDG_CACHE_HOME"/{huggingface,pip,uv,poetry,torch,node,yarn,npm,go-build,cargo,atuin}
            mkdir -p "$CONDA_PKGS_DIRS"
            ;;
        "hf"|"huggingface")
            echo "清理HuggingFace缓存..."
            rm -rf "$HF_HOME"/*
            ;;
        "pip")
            echo "清理Pip缓存..."
            rm -rf "$PIP_CACHE_DIR"/*
            ;;
        "torch")
            echo "清理PyTorch缓存..."
            rm -rf "$TORCH_HOME"/*
            ;;
        "conda")
            echo "清理Conda/MicroMamba包缓存..."
            rm -rf "$CONDA_PKGS_DIRS"/*
            mkdir -p "$CONDA_PKGS_DIRS"
            ;;
        *)
            echo "用法: clean_cache [all|hf|pip|torch|conda]"
            ;;
    esac
}

# 如果直接执行脚本，则运行配置
if [[ "$0" == "$BASH_SOURCE" ]]; then
    echo "执行缓存配置..."
    # 这里可以添加额外的执行逻辑
fi