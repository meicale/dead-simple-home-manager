#!/bin/sh
# WSL 启动编排器：按序执行 /usr/local/lib/wsl-boot.d/ 下的脚本
# 特性：每个脚本独立执行，失败仅记录不中断，主入口始终返回 0

BOOT_DIR="/home/bill/.config/home-manager/extras/wsl_boot_scripts"
LOG="/tmp/wsl-boot.log"

# 确保日志可写（root 执行，一般没问题）
: >>"$LOG" 2>/dev/null || LOG=/dev/stderr

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG"
}

log "===== wsl-boot 启动 ====="

if [ ! -d "$BOOT_DIR" ]; then
  log "警告：脚本目录 $BOOT_DIR 不存在，跳过"
  exit 0
fi

# 按文件名排序遍历，子 shell 执行，永不因单个失败退出
for script in "$BOOT_DIR"/*.sh; do
  # 目录为空时 glob 不展开，产生字面量，过滤掉
  [ -e "$script" ] || continue
  # 只执行可执行文件
  [ -x "$script" ] || {
    log "跳过（不可执行）：$script"
    continue
  }

  name=$(basename "$script")
  log "开始执行：$name"

  # 关键：用单独的 sh 运行，捕获输出与退出码，不影响本进程
  output=$(sh "$script" 2>&1)
  rc=$?

  if [ "$rc" -eq 0 ]; then
    log "成功：$name"
    [ -n "$output" ] && printf '%s\n' "$output" >>"$LOG"
  else
    log "失败（退出码 $rc）：$name"
    printf '%s\n' "$output" >>"$LOG"
  fi
done

log "===== wsl-boot 结束 ====="

# 无论如何都成功退出，绝不阻断 WSL 登录
exit 0
