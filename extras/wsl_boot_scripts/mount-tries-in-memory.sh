#!/bin/sh
# WSL 启动时自动挂载 tmpfs 到家目录下的 tries
# 幂等：已挂载则跳过

TARGET="/home/bill/tries"
OPTIONS="size=25%,mode=0755,uid=1000,gid=1000,noatime"

# 若目标已挂载，直接退出（避免重复挂载报错）
if mountpoint -q "$TARGET"; then
  echo "Already mounted"
  exit 0
fi

# 确保目录存在
mkdir -p "$TARGET"

# 挂载 tmpfs
if ! mount -t tmpfs -o "$OPTIONS" tmpfs "$TARGET"; then
  echo "mount-tries: 挂载 $TARGET 失败" >&2
  exit 1
fi
