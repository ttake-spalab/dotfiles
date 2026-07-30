{ config, pkgs, ... }:

{
  home.username = "ttake";
  home.homeDirectory = "/Users/ttake";
  home.stateVersion = "26.05";
  home.sessionPath = [
    "/usr/local/bin"
  ];

  imports = [
    # ../modules/ghostty/default.nix
    ../modules/nvim/default.nix
    ../modules/starship/default.nix
    ../modules/zsh/default.nix
  ];

  home.packages = with pkgs; [];

  home.file = {};

  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
  };

  programs.home-manager.enable = true;
}

