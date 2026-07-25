{ ... }:
{
  home.file = {
    ".config/nvim".source = ./config;
  };
  programs.neovim.enable = true;
}
