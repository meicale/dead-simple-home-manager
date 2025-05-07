{ config, pkgs, lib, ... }:
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

  home.stateVersion = "24.11"; # Don't change this. This will not upgrade your home-manager.
  programs.home-manager.enable = true;

  programs.bash = {
  enable = true;
  profileExtra = "exec zsh";
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


  # home.file."alias.sh".source = ../../zsh/alias.sh;
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
  '';


  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "meicale";
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

  xdg.configFile."tmux/tmux.conf".source = ./tmux/.config/tmux/.tmux.conf;
  xdg.configFile."tmux/tmux.conf.local".source = ./tmux/.config/tmux/.tmux.conf.local;


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
    # cargo
    cmake
    conda
    delta
    difftastic
    diff-so-fancy
    entr
    eza
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
    llm-ls
    lunarvim
    micromamba
    mpv
    #neovim
    nodejs_23
# modify config file to use it.
    # proxychains-ng
    opencc
    papis
    poetry
    postgresql
    ripgrep
    rustup
    rsync
    ruff # the 2 app are needed by lint python code
    ruff-lsp
    scc
    sd
    # sesh
    skim
    sox
    sqlite
    stow
    thefuck
    tldr
    tmux
    tre
    unzip
    uv
    watchexec
    xsel
    yarn
    yq-go
    zathura
    zellij
    # zoxide

    zsh
    #zsh plugins
    zsh-vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting

    starship
    fontconfig
    (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    # (pkgs.nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" ]; })
    # lsp
    marksman
    python311Packages.python-lsp-server

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

