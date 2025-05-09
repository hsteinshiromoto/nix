{ pkgs, ... }:

{
  # Linux-specific configuration goes here
  home.packages = [
    pkgs.tailscale
		pkgs.tailscalesd
  ];
}
