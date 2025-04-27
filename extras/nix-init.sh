#!/usr/bin/env sh
# /etc/profile.d/nix-init.sh - Nix environment auto-activator

# 防重复加载标记（兼容所有Shell）
if [ -n "${NIX_PROFILES_LOADED}" ]; then
return 0 2>/dev/null || exit 0
fi

# 检测Nix安装模式
_NIX_DAEMON_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
_NIX_USER_SCRIPT="${HOME}/.nix-profile/etc/profile.d/nix.sh"

# 优先检测Daemon模式安装
if [ -f "${_NIX_DAEMON_SCRIPT}" ]; then
. "${_NIX_DAEMON_SCRIPT}"
export NIX_PROFILES_LOADED="daemon"
elif [ -f "${_NIX_USER_SCRIPT}" ]; then
. "${_NIX_USER_SCRIPT}"
export NIX_PROFILES_LOADED="single-user"
else
unset _NIX_DAEMON_SCRIPT _NIX_USER_SCRIPT
return 0 2>/dev/null || exit 0
fi

# 二次验证激活状态
if ! command -v nix >/dev/null 2>&1; then
echo "[WARN] Nix detected but activation failed" >&2
export NIX_PROFILES_LOADED="error"
fi

# 清理临时变量
unset _NIX_DAEMON_SCRIPT _NIX_USER_SCRIPT

