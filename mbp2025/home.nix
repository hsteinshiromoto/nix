{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.age
		pkgs.claude-code
		pkgs.gemini-cli
		pkgs.glab
		pkgs.sops
	];

	programs = {
		eza = {
			enable = true;
			enableNushellIntegration = false;
			enableZshIntegration = true;
		};
		nushell = {
			enable = true;
			configFile.text = ''
				# Nushell configuration
				$env.config = {
					completions: {
						case_sensitive: false
						algorithm: "fuzzy"
					},
					edit_mode: "vi",
					buffer_editor: "vim"
				}

				# Aliases
				alias lg = lazygit
				alias get_arn = aws sts get-caller-identity --query Arn --output text
				alias cat = bat
				alias get_aws_id = aws sts get-caller-identity | from json
			'';
			envFile.text = ''
				# Nushell environment (env.nu)
				# Export environment variables
				$env.EDITOR = "nvim"
			'';
		};
	};

	programs.starship = {
		enable = true;
		enableNushellIntegration = true;
		enableZshIntegration = true;
	};

	programs.atuin = {
		enable = true;
		enableNushellIntegration = true;
		enableZshIntegration = true;
	};

	programs.bat = {
		enable = true;
	};

	# SOPS secrets configuration
	sops = {
		age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
		defaultSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/secrets.yaml";

		secrets = {
			gitlab_token = {
				path = "${config.home.homeDirectory}/.config/sops/secrets/gitlab_token";
			};
		};
	};

	# GitLab CLI configuration
	xdg.configFile."glab-cli/config.yml".text = ''
		# GitLab CLI configuration
		hosts:
		  gitlab.2bos.ai:
		    api_protocol: https
		    api_host: gitlab.2bos.ai
		    git_protocol: https
		    # Token is read from GITLAB_TOKEN environment variable (set via sops)

		# Default GitLab hostname
		host: gitlab.2bos.ai

		# Additional global settings
		editor: nvim
		browser: open
		git_protocol: https
	'';

	# Set GITLAB_TOKEN from sops secret
	home.sessionVariables = {
		GITLAB_TOKEN = "$(cat ${config.sops.secrets.gitlab_token.path})";
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
