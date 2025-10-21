{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.glab
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

		opencode = {
			enable = true;
		};

		starship = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
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

	# SOPS secrets configuration
	sops = {
		age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
		defaultSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/gitlab.yaml";
		# Disable build-time validation to avoid sandbox permission issues on Darwin
		validateSopsFiles = false;

		secrets = {
			gitlab_token = {
				path = "${config.home.homeDirectory}/.config/sops/secrets/gitlab_token";
			};
			gitlab_host = {
				path = "${config.home.homeDirectory}/.config/sops/secrets/gitlab_host";
			};
		};

		# Use sops templates to generate glab-cli config with secrets
		templates."glab-cli/config.yml" = {
			content = ''
# GitLab CLI configuration
hosts:
  ${config.sops.placeholder.gitlab_host}:
    api_protocol: https
    api_host: ${config.sops.placeholder.gitlab_host}
    git_protocol: https
    # Token is read from GITLAB_TOKEN environment variable (set via sops)

# Default GitLab hostname
host: ${config.sops.placeholder.gitlab_host}

# Additional global settings
editor: nvim
browser: open
git_protocol: https
'';
			path = "${config.home.homeDirectory}/.config/glab-cli/config.yml";
			mode = "0600";
		};
	};

	# Set environment variables from sops secrets
	home.sessionVariables = {
		GITLAB_TOKEN = "$(cat ${config.sops.secrets.gitlab_token.path})";
		GITLAB_HOST = "$(cat ${config.sops.secrets.gitlab_host.path})";
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
