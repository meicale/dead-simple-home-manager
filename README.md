# Dead Simple Home Manager

I found it frustrating to establish a clear and simple setup for a cross-platform nix flake home-manager configuration. Experienced nix users offer their own intricate configurations with custom functions (sometimes recursive!) and external flakes that add too much complexity for a beginner, while basic guides fail to account for essential cross-platform functionality.

So, here's Dead Simple Home Manager, a straightforward and easy-to-understand nix flake configuration that works cross-platform. I've tested it on Linux and macOS, but it could easily generalize to other systems.

PS. This is a personal config on Windows 11/ WSL2/ Ubuntu 24.04.01

Structure
1. nix/home manager and a outsource tmux and neovim configs
2. use submodule to config this repo
3. Currently the config is based on the cache disk to hold all the /nix storage.

Just follow these steps:

1. First, install nix. I recommend [Zero-to-Nix](https://zero-to-nix.com/start/install) or the [official installer](https://nixos.org/download.html)
2. Clone this repository: `git clone --recurse-submodules https://github.com/meicale/dead-simple-home-manager ~/.config/home-manage`. use `--recurse-submodules` to clone tmux, neovim, and other configs. Clone later is OK, too.
3. Personalize `flake.nix` with your `user@host` and `system` values
4. Personalize `home.nix` with your username and home directory
5. Run to get home-manager one-time: `nix shell nixpkgs#home-manager`, you need to comment out the xdg config when running on `nix shell`
6. Run to get new home: `home-manager switch -b backup`
4. Finally, run: `nix run home-manager/release-24.05 switch`

And that's it. You're up and running with a dead simple, cross-platform home-manager configuration.

PS.
1. https://github.com/EmergentMind/nix-config/blob/dev/justfile # from this file and project
2. 如果 home manager 并没有在 nex 中进行安装，使用 nix 临时脚本环境，比如nix shell nixpkgs#home-manager, 可以于是使用home manager。home manager 带有-b 选项，即首先用 nix 安装了home manager 之后，就可以直接用home manager 命令就可以使用杠 b 选项了
