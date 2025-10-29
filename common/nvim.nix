{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
		docker-language-server
    lua-language-server
    markdown-oxide
		nodePackages_latest.vscode-json-languageserver
		systemd-language-server
    texlab
		yaml-language-server
  ];
}
