{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lua-language-server
    marksman
    texlab
  ];
}
