{ config, pkgs, ... }:

{
  imports = [
    ../common/gitconfig.nix
    ../common/gitlab.nix
    ../common/nu.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.delta
		pkgs.gitflow
		pkgs.pyright
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

		password-store = {
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

	# Set environment variables
	home.sessionVariables = {
		XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
		UV_PREBUILT = "1";
		# Export GitLab secrets to shell environment (mbp2025 only)
		# The secret files are decrypted by sops-nix at activation time
		GITLAB_TOKEN = "$(cat ${config.home.homeDirectory}/.config/sops/secrets/gitlab_token 2>/dev/null || echo '')";
		GITLAB_HOST = "$(cat ${config.home.homeDirectory}/.config/sops/secrets/gitlab_host 2>/dev/null || echo '')";
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
