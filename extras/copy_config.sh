#!/bin/bash

# 检查文件是否存在
files=("wsl.conf" "fstab")
for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "错误：以下文件缺失: ${missing_files[*]}"
    exit 1
fi

# 使用循环逐个复制文件
for file in "${files[@]}"; do
    echo "正在复制 $file..."
    sudo cp -v "$file" "/etc/$file"
    
    if [ $? -ne 0 ]; then
        echo "复制 $file 失败！"
        exit 1
    fi
done

echo "所有文件已成功复制到 /etc 目录。"

nix_init_file="nix-init.sh"
if [  -f "${nix_init_file}" ]; then
    echo "正在复制 "${nix_init_file}" ..."
    sudo cp -v  "${nix_init_file}" "/etc/profile.d/${nix_init_file}"  
else
    echo "错误：没有nix 激活文件 "${nix_init_file}" ..."
fi
echo "all done"
