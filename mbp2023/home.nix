{ config, pkgs, ... }:

{
  imports = [
    ../common/gitconfig.nix
    ../common/nu.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.delta
		pkgs.gitflow
		pkgs.ollama
		pkgs.spotify-player
	];

	programs = {
				atuin = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		awscli = {
			enable = true;
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
					isort = {
						extra-standard-library = ["path"];
						required-imports = ["from __future__ import annotations"];
					};
				};
				format = {
					docstring-code-format = true;
				};
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

	# Using home-manager to clone and manage plugins is not the best (see e.g. [1])
	#
	# References:
	#		[1] https://discourse.nixos.org/t/make-home-manager-clone-some-git-repos-for-my-dotfiles/32591
	#
	# home.file = {
	# 		"/Users/hsteinshiromoto/.zgenom".source = builtins.fetchGit {
	# 			url = "https://github.com/jandamm/zgenom";
	# 			ref = "main"; # Or your desired branch/commit
	# 	};
	# };

	# Set environment variables
	home.sessionVariables = {
		XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
	};

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
