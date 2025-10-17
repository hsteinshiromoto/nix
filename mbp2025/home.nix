{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.claude-code
		pkgs.gemini-cli
		pkgs.nushellPlugins.highlight
	];

	programs {
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
					edit_mode: "vi";
					buffer_editor: "vim"
				}

				# Register nu-plugin-highlight
				plugin add ${pkgs.nushellPlugins.highlight}/bin/nu_plugin_highlight

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
