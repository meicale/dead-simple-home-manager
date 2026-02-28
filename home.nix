{ config, pkgs, lib,  ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in
{
  imports = [
    ## Modularize your home.nix by moving statements into other files
    ./nixvim.nix
    ./lf.nix
  ];

  home.username = "bill";
  home.homeDirectory =
    if isLinux then "/home/bill" else
    if isDarwin then "/Users/bill" else unsupported;

  home.stateVersion = "25.11"; # Don't change this. This will not upgrade your home-manager.
  programs.home-manager.enable = true;

  programs.atuin = {
    enable = true;
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
    lfs.enable = true;
    settings.user.name = "meicale";
    # userEmail = "test@163.com";
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

  xdg.configFile."atuin/config.toml".source = ./extras/atuin.config.toml;

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
    proxychains-ng
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

