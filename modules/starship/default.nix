{ config, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    settings = pkgs.lib.importTOML ./config/starship.toml;
  };
}
