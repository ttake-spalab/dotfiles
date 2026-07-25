{ ... }:
{
  programs.uv = {
    enable = true;
    python = {
      versions = [
        "3.13"
        "3.12"
      ];
      default = "3.13";
    };
    tool = {
      packages = [
        "ruff"
        "ty"
      ];
    };
  };
}
