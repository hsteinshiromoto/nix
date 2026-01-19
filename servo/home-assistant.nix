{ config, lib, pkgs, ... }:

{
	services = {
		home-assistant = {
			enable = true;
			extraComponents = [
				# Components required to complete the onboarding
				"analytics"
				"met"
				"radio_browser"
				# Recommended for fast zlib compression
				# https://www.home-assistant.io/integrations/isal
				"isal"
				# Bluetooth support
				"bluetooth"
				"bluetooth_le_tracker"
				# Philips Hue integration
				"hue"
			];
			extraPackages = python3Packages: with python3Packages; [
				bleak
			];
			config = {
				# Includes dependencies for a basic setup
				# https://www.home-assistant.io/integrations/default_config/
				server_host = "::1";
				trusted_proxies = [ "::1" ];
				use_x_forwarded_for = true;
			};
		};

		nginx = {
			enable = true;
			recommendedProxySettings = true;
			virtualHosts."servidor" = {
				forceSSL = true;
				enableACME = true;
				extraConfig = ''
					proxy_buffering off;
				'';
				locations."/" = {
					proxyPass = "http://[::1]:8123";
					proxyWebsockets = true;
				};
			};
		};
	};
}
