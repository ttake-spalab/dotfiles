{ ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "ttake-spalab";
        email = "t.take.spalab@gmail.com";
      };
      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "nvim";
      };
    };
  };
}
