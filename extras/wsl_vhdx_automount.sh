#!/bin/bash

if ! mount | grep -q '/mnt/wsl/persistent'; then # 防止开多个terminal时多次执行
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'wsl --mount  --vhd "F:\vhds\persistent.vhdx" --name "persistent" ' > /dev/null
	sleep 1    # 等块设备出来
fi

if ! mount | grep -q '/mnt/wsl/workspace'; then # 防止开多个terminal时多次执行
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'wsl --mount  --vhd "J:\vhdxs\workspace.vhdx" --name "workspace" ' > /dev/null
	sleep 1    # 等块设备出来
fi



if ! mount | grep -q '/nix'; then
	/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'wsl --mount --bare --vhd "F:\vhds\nix.vhdx" ' > /dev/null
	sleep 1    # 等块设备出来
	sudo mkdir -p /nix
	sudo mount -U 'c4849a89-57a8-40e2-92d3-d46f05943cbe' /nix
fi
# ref: https://www.cnblogs.com/qoobee/p/18854320
