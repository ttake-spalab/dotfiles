{ config, pkgs, ... }:

{
  home.username = "ttake";
  home.homeDirectory = "/Users/ttake";
  home.stateVersion = "26.05";
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
  ];

  imports = [
    ../modules/direnv/default.nix
    ../modules/gh/default.nix
    # ../modules/ghostty/default.nix
    ../modules/git/default.nix
    ../modules/nvim/default.nix
    ../modules/starship/default.nix
    ../modules/tmux/default.nix
    ../modules/uv/default.nix
    ../modules/zsh/default.nix
  ];

  home.packages = with pkgs; [
    ffmpeg
    jq
    mactop
    sox
    tree
  ];

  home.file = {
    ".config/gh/config.yaml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/gh/config.yaml";
  };

  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
  };

  programs.home-manager.enable = true;
}
