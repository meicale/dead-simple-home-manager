windows 上vhdx文件的准备ref: https://www.cnblogs.com/qoobee/p/18854320 other_ref: https://www.h3c.com/cn/pub/Document_Center/2023/05/WebHelp_H3C_CloudOS7.0YCZXT_YHZN/html/topic_m210524x0_6537.htm
1. 创建vhdx 文件：
 `new-vhd -Dynamic -SizeBytes 2048gb -BlockSizeBytes 1mb -path F:\vhds\nix.vhdx`
2. 配置权限
.vhdx文件->属性->安全->编辑->给Authenticated Users勾上完全控制.
如果没有此步骤在后面WSL启动时执行wsl --mount时会报没有权限访问.vhdx文件的错误
3. 格式化虚拟磁盘
手动把vhdx挂载进WSL
windows端powershell管理员模式执行: ` wsl --mount --vhd "F:\vhds\nix.vhdx" --bare `
在wsl内对新增磁盘进行格式化
lsblk   # 找到新增磁盘，比如/dev/sdb, 可通过挂载状态+磁盘大小判断哪个是新增的
sudo mkfs.ext4 /dev/sdb  # 格式化为ext4
lsblk -f # 记录新增磁盘的uuid，后面要用
4. 安装wsl 中的nix（可以使用已经安装好的进行导入）ref: https://zero-to-nix.com/start/install/ 或者到release位置下载修改权限后执行： https://github.com/DeterminateSystems/nix-installer/releases
修改权限 `sudo chmod +r `
5. 重新挂载，并复制所有的/nix文件
在Windows下执行
注意先卸载： ` wsl --unmount "F:\vhds\nix.vhdx" `
挂载到命令目录: ` wsl --mount  --vhd "F:\vhds\nix.vhdx" --name tmp `
在wsl2中的Ubuntu 命令行中执行 ref: https://nixos.wiki/wiki/Storage_optimization#Moving_the_store
`
# rsync --archive --hard-links --acls --one-file-system --verbose /nix/store/ /mnt/wsl/tmp/store
# rsync --archive --hard-links --acls --one-file-system --verbose /nix/var/ /mnt/wsl/tmp/var
`

6. 挂载新的 /nix
windows 下执行 
` wsl --unmount "F:\vhds\nix.vhdx" ` , 
` wsl --mount --vhd "F:\vhds\nix.vhdx" --bare `
Ubuntu 下执行
` sudo mount -U {磁盘uuid} /nix `

7. 重新启动 nix-daemon（关键:每次启用一个新的wsl实例时都需要执行）
`
$ systemctl stop nix-daemon.service
$ systemctl restart nix-daemon.socket
$ systemctl start nix-daemon.service
`

8. 实现WSL重启后自动挂载(主机是否重启没有区别)
在WSL内创建WSL启动时执行挂载的脚本
新建~/.wsl_vhdx_automount.sh用于执行挂载动作, 内容如下(添加执行权限):
设置WSL启动后自动执行~/.wsl_vhdx_automount.sh(cp ./wsl_vhdx_automount.sh ~/.wsl_vhdx_automount.sh)
win11: 通过在/etc/wsl.conf中的boot/command设置WSL开机自动执行/home/bill/.wsl_vhdx_automount.sh即可(会自动用root用户执行,其实这种场景下挂载动作和terminal会话应该就没关系了, 开多个terminal不会多次挂载) 需要包括以下内容
`
[boot]
command = /bin/sh -c "/home/bill/.wsl_vhdx_automount.sh > /home/auto_mount.log 2>&1"
`
本目录下是使用命令
` sudo cat wsl.conf >> /etc/wsl.conf `
删除重复的行
注意：可以使用复制内容并黏贴到原有/etc/wsl.conf 方式，避免直接覆盖的权限问题。

这里面是一些在 wsl 实例中的额外配置,并不能通过 home manager 进行管理.
ps.

1. 这里面的文件只是展示相应的做法并不能直接使用,并且可能过时，请结合具体情况实际应用。
2. 这种配置方式需要将相应vhdx或者目录或者磁盘映射到 wsl 实例中，需要相应的脚本或者命令进行配合.
wsl_vhdx_automount.sh
为了减少wsl实例本身的体积，同时降低重复的下载和配置需求，请nix store, cache, env, repo 等转移到独立的vhdx 文件。该脚本实现这个文件的自动加载，同时能够正常使用。ref:https://www.cnblogs.com/qoobee/p/1885432
copy_config.sh
执行相应的文件配置，该脚本只需执行一次即可
bashrc
用来配置如果目录被成功加载，则尝试激活 nix
wsl.conf
主要是用来设置，开启自动的挂载。
fstab
主要是成默认的挂载位置,因为 nix 必须挂载在/nix
这种方法已经弃用

备用:
proxychains4.conf
设置上网的代理，需要结合已经配好的服务器进行配置
