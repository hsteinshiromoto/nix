{ config, lib, pkgs, ... }:

{
	# Open port 8123 for Home Assistant direct access
	networking.firewall.allowedTCPPorts = [ 8123 ];

	services.home-assistant = {
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
			default_config = {};
			http = {
				server_host = "0.0.0.0";  # Listen on all interfaces
				server_port = 8123;
			};
		};
	};
}
