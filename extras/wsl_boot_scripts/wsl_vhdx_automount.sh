#!/bin/bash

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查挂载点
check_mount() {
    mount | grep -q "$1"
    return $?
}

# 挂载 VHDX
mount_vhdx() {
    local vhd_path="$1"
    local mount_name="$2"
    local mount_point="$3"
    
    if check_mount "$mount_point"; then
        log "$mount_point 已经挂载，跳过"
        return 0
    fi
    
    log "开始挂载 $mount_point..."
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "wsl --mount --vhd \"$vhd_path\" --name \"$mount_name\"" > /dev/null 2>&1
    
    # 等待挂载完成
    local max_wait=10
    local count=0
    while ! check_mount "$mount_point" && [ $count -lt $max_wait ]; do
        sleep 1
        count=$((count + 1))
    done
    
    if check_mount "$mount_point"; then
        log "$mount_point 挂载成功"
        return 0
    else
        log "错误：$mount_point 挂载失败"
        return 1
    fi
}

# 主逻辑
log "开始执行 VHDX 自动挂载..."

# 挂载 persistent VHDX
mount_vhdx "F:\vhds\persistent.vhdx" "persistent" "/mnt/wsl/persistent"

# 挂载 workspace VHDX
mount_vhdx "J:\vhdxs\workspace.vhdx" "workspace" "/mnt/wsl/workspace"

# 挂载 nix VHDX
if ! check_mount "/nix"; then
    log "开始挂载 /nix..."
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "wsl --mount --bare --vhd \"F:\vhds\nix.vhdx\"" > /dev/null 2>&1
    sleep 1
    
    sudo mkdir -p /nix
    sudo mount -U 'c4849a89-57a8-40e2-92d3-d46f05943cbe' /nix
    
    if check_mount "/nix"; then
        log "/nix 挂载成功"
    else
        log "错误：/nix 挂载失败"
    fi
else
    log "/nix 已经挂载，跳过"
fi

log "VHDX 自动挂载完成"
# ref: https://www.cnblogs.com/qoobee/p/18854320
