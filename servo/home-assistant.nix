{ config, lib, pkgs, ... }:

{
	# Ensure nginx starts after self-signed certificates are generated
	systemd.services.nginx = {
		after = [ "nginxSelfSignedCert.service" ];
		wants = [ "nginxSelfSignedCert.service" ];
	};

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
				homeassistant = {
					external_url = "https://servidor/home_assistant";
				};
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
				sslCertificate = "/var/lib/nginx/certs/servidor.crt";
				sslCertificateKey = "/var/lib/nginx/certs/servidor.key";
				extraConfig = ''
					proxy_buffering off;
				'';
				locations."/home_assistant/" = {
					proxyPass = "http://[::1]:8123/";
					proxyWebsockets = true;
				};
			};
		};
	};
}
