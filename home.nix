{ config, pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in
{
  imports = [
    ## Modularize your home.nix by moving statements into other files
  ];

  home.username = "bill";
  home.homeDirectory =
    if isLinux then "/home/bill" else
    if isDarwin then "/Users/bill" else unsupported;

  home.stateVersion = "24.05"; # Don't change this. This will not upgrade your home-manager.
  programs.home-manager.enable = true;

  home.packages = with pkgs; ([
    # Common packages
    hello
    # just
    # neovim
    # proxychains-ng
    # fzf
    # fd
  ] ++ lib.optionals isLinux [
    # GNU/Linux packages
  ]
  ++ lib.optionals isDarwin [
    # macOS packages
  ]);
}

