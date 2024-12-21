{ pkgs, inputs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/home/fng";
  home.sessionVariables = { BROWSER = "wslview"; };
  home.packages = with pkgs;
    [
      wslu # for wslview
    ];
}
