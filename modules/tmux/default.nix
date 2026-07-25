{ ... }:
{
  home.file = {
    ".config/tmux".source = ./config;
  };
  programs.tmux.enable = true;
}
