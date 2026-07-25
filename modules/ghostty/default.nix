{ ... }:
{
  home.file = {
    ".config/ghostty".source = ./config;
  };
  programs.ghostty.enable = true;
}
