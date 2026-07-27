{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # 2行プロンプトのレイアウト定義
      # 1行目: ` username@hostname path  git_branch [git_status]
      # 2行目: character `> `
      format = ''
         [$username@$hostname](green):$directory $git_branch$git_status
        $character'';

      # プロンプト上の空行を無効化
      add_newline = false;

      # ユーザー名とホスト名設定 (緑色 & 角括弧)
      username = {
        style_user = "green";
        style_root = "red";
        show_always = true;
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false; # SSH接続時以外も常時表示
        style = "green";
        format = "[$hostname]($style)";
      };

      # 作業ディレクトリ設定 (~ や相対パス表示)
      directory = {
        style = "cyan";
        truncation_length = 0; # パスを省略せずに表示（必要に応じて 3 等に変更可）
        truncate_to_repo = false;
        format = "[$path]($style)";
      };

      # Gitブランチ表示の設定
      git_branch = {
        style = "#f5bde6";
        format = "[$symbol$branch]($style) ";
      };

      # Git status 表示
      git_status = {
        format = "[\\[$all_status$ahead_behind\\]]($style)";
      };

      # 2行目の入力記号（一般ユーザーは '% ', rootは '# ' などカスタマイズ可能）
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
    };
  };
}
