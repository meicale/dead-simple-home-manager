{ config, pkgs, lib,  ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
  # 共享存储基础路径（可根据实际情况调整）
  sharedBase = if isLinux then "/mnt/wsl/persistent" else "/Volumes/persistent" ;
  
  # XDG目录路径
  xdgCacheHome = "${sharedBase}/cache";
  xdgDataHome = "${sharedBase}/data";
  xdgStateHome = "${sharedBase}/state";
  
  # Python相关路径
  hfCacheDir = "${xdgCacheHome}/huggingface";
  pipCacheDir = "${xdgCacheHome}/pip";
  uvCacheDir = "${xdgCacheHome}/uv";
  poetryCacheDir = "${xdgCacheHome}/poetry";
  condaEnvDir = "${sharedBase}/conda/envs";
  
in
{
  imports = [
    ## Modularize your home.nix by moving statements into other files
    ./nixvim.nix
    ./lf.nix
  ];
# XDG环境变量配置
  xdg.enable = true;
  xdg.cacheHome = xdgCacheHome;
  xdg.dataHome = xdgDataHome;
  xdg.stateHome = xdgStateHome;
  
  # 确保共享目录存在
  home.activation.createSharedDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${xdgCacheHome}/{huggingface,pip,uv,poetry,conda,atuin,node,yarn,npm,go-build,cargo}
    mkdir -p ${xdgDataHome}/{atuin,zoxide,direnv,pipx}
    mkdir -p ${xdgStateHome}/nix
    mkdir -p ${sharedBase}/conda/envs
  '';
   # Shell环境变量
  home.sessionVariables = {
    # XDG标准
    XDG_CACHE_HOME = xdgCacheHome;
    XDG_DATA_HOME = xdgDataHome;
    XDG_STATE_HOME = xdgStateHome;
    
    # Python相关
    HF_HOME = hfCacheDir;
    HUGGINGFACE_HUB_CACHE = hfCacheDir;
    TRANSFORMERS_CACHE = "${hfCacheDir}/hub";
    PIP_CACHE_DIR = pipCacheDir;
    UV_CACHE_DIR = uvCacheDir;
    POETRY_CACHE_DIR = poetryCacheDir;
    
    # Conda/Micromamba
    CONDA_ENVS_PATH = condaEnvDir;
    MAMBA_ROOT_PREFIX = "${sharedBase}/conda";
    
    # Node.js
    npm_config_cache = "${xdgCacheHome}/npm";
    YARN_CACHE_FOLDER = "${xdgCacheHome}/yarn";
    
    # Go
    GOCACHE = "${xdgCacheHome}/go-build";
    GOMODCACHE = "${xdgCacheHome}/go/mod";
    
    # Rust
    CARGO_HOME = "${xdgDataHome}/cargo";
    RUSTUP_HOME = "${xdgDataHome}/rustup";
  };
  
  # 为不支持XDG的工具创建符号链接
  home.file.".cache/huggingface".source = config.lib.file.mkOutOfStoreSymlink hfCacheDir;
  home.file.".cache/pip".source = config.lib.file.mkOutOfStoreSymlink pipCacheDir;
  home.file.".cache/uv".source = config.lib.file.mkOutOfStoreSymlink uvCacheDir;
  home.file.".cache/poetry".source = config.lib.file.mkOutOfStoreSymlink poetryCacheDir;
  home.file.".conda/envs".source = config.lib.file.mkOutOfStoreSymlink condaEnvDir;

  home.username = "bill";
  home.homeDirectory =
    if isLinux then "/home/bill" else
    if isDarwin then "/Users/bill" else unsupported;

  home.stateVersion = "25.11"; # Don't change this. This will not upgrade your home-manager.
  programs.home-manager.enable = true;

  
  
  # Atuin配置（使用XDG路径）
  programs.atuin = {
    enable = true;
    settings = {
      db_path = "${xdgDataHome}/atuin/history.db";
      key_path = "${xdgDataHome}/atuin/key";
      session_path = "${xdgDataHome}/atuin/session";
      filter_mode_shell_up_key_binding = "directory" ;
      ctrl_n_shortcuts = true;
      enter_accept = true;
      keymap_mode = "vim-normal";
      records = true;
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file."alias.sh".source = ./zsh/alias.sh;
  home.file.".cli_tmux_editor.sh".source = ./zsh/zsh-vi-tmux-editor.sh;

  # Poetry配置
  home.file.".config/pypoetry/config.toml".text = ''
    [cache-dir]
    "${poetryCacheDir}"
  '';
  
  # UV配置
  home.file.".config/uv/uv.toml".text = ''
    [cache]
    dir = "${uvCacheDir}"
  '';
  
  # Pip配置
  home.file.".config/pip/pip.conf".text = ''
    [global]
    cache-dir = ${pipCacheDir}
  '';
  
  # Conda配置
  home.file.".condarc".text = ''
    envs_dirs:
      - ${condaEnvDir}
    pkgs_dirs:
      - ${sharedBase}/conda/pkgs
  '';
  
  # Micromamba配置
  home.file.".mambarc".text = ''
    root_prefix: ${sharedBase}/conda
    envs_dirs:
      - ${condaEnvDir}
    pkgs_dirs:
      - ${sharedBase}/conda/pkgs
  '';

# Bash 配置 - 自动切换到 zsh
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -n "$BASH_EXECUTION_STRING" ]; then
        return
      fi
      if [ -z "$ZSH_EXECUTION_STRING" ] && [ -t 1 ]; then
        exec zsh
      fi
    '';
  };

  # Bashrc - 用于非登录 shell（IDE）
  home.file.".bashrc".text = ''
    if [ -z "$ZSH_EXECUTION_STRING" ] && [ -t 1 ]; then
      if [ -n "$BASH_EXECUTION_STRING" ]; then
        return
      fi
      exec zsh
    fi
  '';

  programs.zsh = {
    enable = true;

#  oh-my-zsh doesn't work properly with the current config
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "thefuck" "sudo" "dirhistory" "copydir" "copyfile" "copybuffer"];
    #   # theme = "robbyrussell";
    # };

  };

  # programs.papis = {
  #   enable = true;
  #   settings = true;
  #   # libraries = true;
  # };

  programs.zsh.initExtra= ''
      # 确保缓存目录存在
      mkdir -p ${xdgCacheHome}/zsh
      mkdir -p ${xdgDataHome}/zsh
      
      # Zsh缓存
      export ZSH_CACHE_DIR="${xdgCacheHome}/zsh"
      export ZSH_COMPDUMP="${xdgCacheHome}/zsh/zcompdump-$HOST"
      
      # Zoxide数据
      export _ZO_DATA_DIR="${xdgDataHome}/zoxide"
      
      # Direnv数据
      export DIRENV_LOG_FORMAT=""
      export DIRENV_WATCHES="${xdgDataHome}/direnv/watches"    
    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# this is need changed to adhoc way.
    export PATH=$HOME/.npm-global/bin:$PATH
    export ZVM_VI_SURROUND_BINDKEY=s-prefix
    export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
    export ZVM_VI_EDITOR="${config.home.homeDirectory}/.cli_tmux_editor.sh"
    export CUDA_HOME=/usr/local/cuda
    export PATH=$CUDA_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PAT
    source "${config.home.homeDirectory}/alias.sh"
    eval "$(starship init zsh)"
    function zsh_vi_mode_init() {
    # https://github.com/jeffreytse/zsh-vi-mode
    # [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # Change this to nix
      [ -f  ${pkgs.fzf}/share/fzf/key-bindings.zsh ] && source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    }
    zvm_after_init_commands+=(zsh_vi_mode_init)
    # https://docs.atuin.sh/cli/integrations/
    # Append a command directly (after sourcing zvm)
    zvm_after_init_commands+=( 'eval "$(atuin init zsh)"')
  '';


  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "meicale";
        # email = "test@163.com";
      };
      lfs = {
        enable = true;
        storage = "${sharedBase}/git/lfs";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
};


# this doesn't works at all
  # xdg.configFile."pe" = {
  #     enable = true;
  #     recursive = true;
  #     source = ./nvim/.config/nvim;
  # };

  # # 貌似使用当前的.目录这种方式不能被正确映射到home-manager的目录
  # xdg.configFile."tmux/tmux.conf".source = ./tmux/.config/tmux/.tmux.conf;
  # xdg.configFile."tmux/tmux.conf.local".source = ./tmux/.config/tmux/.tmux.conf.local;
  xdg.configFile."tmux/tmux.conf".source = "${config.home.homeDirectory}/.config/home-manager/tmux/.config/tmux/.tmux.conf";
  xdg.configFile."tmux/tmux.conf.local".source = "${config.home.homeDirectory}/.config/home-manager/tmux/.config/tmux/.tmux.conf.local";

  # xdg.configFile."atuin/config.toml".source = ./extras/atuin.config.toml;

# Comment this on wsl to use vscode installed in windows
#   programs.vscode = {
#   enable = true;
#   package = pkgs.vscodium.fhs;
#   extensions = with pkgs.vscode-extensions; [
#     dracula-theme.theme-dracula
#     yzhang.markdown-all-in-one
#   ];
# };

  home.packages = with pkgs; ([
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # direnv
    aider-chat
    antibody
    aria2
    bat
    black
    btop
    # btop-cuda
    # cargo
    cmake
    claude-code
    conda
    delta
    difftastic
    diff-so-fancy
    duckdb
    entr
    eza
    fastfetch
    fd
    ffmpeg-full
    # fzf
    gcc
# this is requiored by cuda 11.7 which is required by pytorch1.13
    # gcc11
    gnumake
    gh
    go
    jless
    jq
    just
    lazygit
    lazydocker
    llm-ls
    lunarvim
    marimo
    micromamba
    mpv
    #neovim
    nodejs_24
# modify config file to use it.
    # proxychains-ng # avoid rebuild nix to run 
    opencc
    papis
    poetry
    postgresql
    ripgrep
    rustup
    rsync
    ruff # the 2 app are needed by lint python code
    # ruff-lsp # not need by 25.05
    scc
    sd
    # sesh
    skim
    sox
    sqlfluff
    sqlite
    stow
    ta-lib
    # thefuck
    tldr
    tre
    unzip
    uv
    watchexec
    wlr-which-key
    xsel
    yarn
    yq-go
    zathura
    zellij
    # zig
    # zoxide

    zsh
    #zsh plugins
    zsh-vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting

    starship
    # fontconfig
    # (pkgs.nerd-fonts.override { fonts = [ "SourceCodePro" ]; })
    # (pkgs.nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" ]; })
    # lsp
    marksman
    # python311Packages.python-lsp-server
    portaudio
    pulseaudioFull

    # noto-fonts-cjk-sans        # Noto 中日韩等宽字体（包含等宽版本）
    # noto-fonts-emoji           # 全量Emoji支持
    sarasa-gothic              # 更纱黑体（可选，比Noto更美观，包含等宽版本Sarasa Mono SC）

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ] ++ lib.optionals isLinux [
    # GNU/Linux packages
  ]
  ++ lib.optionals isDarwin [
    # macOS packages
  ]);
}

