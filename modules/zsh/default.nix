{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    setOptions = [
      "PRINT_EIGHT_BIT"
      "INTERACTIVE_COMMENTS"
      "EXTENDED_GLOB"
    ];

    history = {
      size = 1000000;
      save = 1000000;
      path = "$HOME/.zsh_history";
      share = true;
    };

    shellAliases = {
      la = "ls -a";
      ll = "ls -lh";
      lla = "ls -lah";
    };

    envExtra = ''
    if [ -f "$HOME/.cargo/env" ]; then
      . "$HOME/.cargo/env"
    fi
    '';

    profileExtra = ''
    '';

    initContent = ''
      stty -ixon
  
      bindkey '^R' history-incremental-pattern-search-backward
  
      # PROMPTをstarshipに移行したらautoloadは不要になりそう
      autoload -Uz colors
      colors
      PROMPT="%{''${fg[green]}%}[%n@%m]%{''${reset_color}%} %~
      %# "
    '';

  };
}
