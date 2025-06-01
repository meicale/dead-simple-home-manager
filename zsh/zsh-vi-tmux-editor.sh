#!/bin/bash

ORIG_PANE=$(tmux display-message -p "#{pane_id}")
# ORIG_PANE=%109
# 检查是否在 tmux 会话中
if [ -z "$TMUX" ]; then
	echo "Error: This script must be run inside a tmux session." >&2
	exit 1
fi

CLI_EDITOR=""
NVIM_APPNAME=cli_editor
# 创建临时文件路径
TMPFILE=$(mktemp /tmp/zvm-editor.XXXXXX)
cat "$@" >"$TMPFILE"

# 垂直分割创建新窗格（使用 -v 垂直分割，-h 水平分割）
tmux split-window -v -p 20 -c "#{pane_current_path}" "bash -c 'NVIM_APPNAME=$NVIM_APPNAME nvim $TMPFILE && tmux load-buffer $TMPFILE && tmux send-keys -t $ORIG_PANE 'ddi' && tmux paste-buffer -t $ORIG_PANE ; rm -f $TMPFILE; exit'"
