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
  ];

  home.username = "bill";
  home.homeDirectory =
    if isLinux then "/home/bill" else
    if isDarwin then "/Users/bill" else unsupported;

  home.stateVersion = "24.11"; # Don't change this. This will not upgrade your home-manager.
  programs.home-manager.enable = true;

  # programs.nixvim = {
  #   enable = true;
  #   plugins.easyescape.enable = true;
  #   plugins.flash.enable = true;
  #   extraConfigLua = ''
  #     -- Print a little welcome message when nvim is opened!
  #     print("Hi, I'm nixvim!")
  #   '';
  # };

  programs.bash = {
  enable = true;
  profileExtra = "exec zsh";
  };


  home.packages = with pkgs; ([
    # Common packages
    # neovim
    hello
    zsh
  ] ++ lib.optionals isLinux [
    # GNU/Linux packages
  ]
  ++ lib.optionals isDarwin [
    # macOS packages
  ]);
}

