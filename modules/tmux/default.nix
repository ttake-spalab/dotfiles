{ pkgs, ... }:

let
  # GitHubのraw URLから直接設定ファイルをFetchする
  icebergMinimalTmuxConf = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg_minimal.tmux.conf";
    hash = "sha256-HyGUSznvhTPZrnmCv/wdY2jCJIjM+haGtt+j6RA9wBU="; 
  };
in

{
  home.file = {
    ".config/tmux/tmux.conf".source = ./config/tmux.conf;
    # Fetchしたテーマファイルを ~/.config/tmux/iceberg.tmux.conf として配置
    ".config/tmux/iceberg_minimal.tmux.conf".source = icebergMinimalTmuxConf;
  };
  programs.tmux.enable = false;
}
