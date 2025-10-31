{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/home/hsteinshiromoto";

	home.packages = with pkgs; [
    age
  ];

	programs = {
		atuin = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		bat = {
			enable = true;
		};

		claude-code = {
			enable = true;
		};

		eza = {
			enable = true;
			enableNushellIntegration = false;
			enableZshIntegration = true;
		};

		gemini-cli = {
			enable = true;
		};

		opencode = {
			enable = true;
		};

		ruff = {
			enable = true;
			settings = {
				lint = {
					task-tags = ["INFO" "NOTE" "ALERT" "WARNING"];
					extra-standard-library = ["path"];
					required-imports = ["from __future__ import annotations"];
				};
				docstring-code-format = true;
				future-annotations = true;
			};
		};

		starship = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		uv = {
			enable = true;
		};

		yazi = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		zoxide = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};


	};

	# Adding sops
	# References:
	#		[1] https://zohaib.me/managing-secrets-in-nixos-home-manager-with-sops/
	# sops = {
	#    age.keyFile = "/home/hsteinshiromoto/.config/sops/age/keys.txt"; # must have no password!
	#
	#    defaultSopsFile = "/home/hsteinshiromoto/.config/sops/secrets/example.yaml";
	#    defaultSymlinkPath = "/run/user/1000/secrets";
	#    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
	#
	#    secrets.openai_api_key = {
	#      # sopsFile = ./secrets.yml.enc; # optionally define per-secret files
	#      path = "${config.sops.defaultSymlinkPath}/openai_api_key";
	#    };
	#  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

