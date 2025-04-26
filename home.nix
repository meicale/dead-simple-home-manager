{ config, pkgs, inputs, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "bill";
  home.homeDirectory = "/home/bill";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # direnv
    antibody
    aria2
    bat
    black
    # cargo
    # cmake
    conda
    delta
    difftastic
    diff-so-fancy
    entr
    eza
    fd
    ffmpeg-full
    # fzf
    # gcc
# this is requiored by cuda 11.7 which is required by pytorch1.13
    # gcc11
    # gnumake
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
    nodejs_20
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
    watchexec
    xsel
    yarn
    youtube-dl
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
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/bill/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    bash.enable = true; # see note on other shells below
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

  xdg.configFile."lf/icons".source = ./icons;

  programs.lf = {
    enable = true;
    commands = {
      dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
      editor-open = ''$$EDITOR $f'';
      mkdir = ''

      ''${{
        printf "Directory Name: "
        read DIR

        mkdir $DIR
      }}
      '';
    };

    keybindings = {

      "\\\"" = "";
      o = "";
      c = "mkdir";
      "." = "set hidden!";
      "`" = "mark-load";
      "\\'" = "mark-load";
      "<enter>" = "open";


      do = "dragon-out";

      "g~" = "cd";
      gh = "cd";
      "g/" = "/";

      ee = "editor-open";
      V = ''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';

      # ...
    };

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      # icons = false;
      icons = true;
      ignorecase = true;
    };

    extraConfig =

    let
      previewer =

        pkgs.writeShellScriptBin "pv.sh" ''
        file=$1
        w=$2
        h=$3
        x=$4
        y=$5

        if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
            ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
            exit 1
        fi

        ${pkgs.pistol}/bin/pistol "$file"
      '';
      cleaner = pkgs.writeShellScriptBin "clean.sh" ''

        ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
      '';
    in
    ''
      set cleaner ${cleaner}/bin/clean.sh
      set previewer ${previewer}/bin/pv.sh
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
};

# Comment this on wsl to use vscode installed in windows
#   programs.vscode = {
#   enable = true;
#   package = pkgs.vscodium.fhs;
#   extensions = with pkgs.vscode-extensions; [
#     dracula-theme.theme-dracula
#     yzhang.markdown-all-in-one
#   ];
# };

}

