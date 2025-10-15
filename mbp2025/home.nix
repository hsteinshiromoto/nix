{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.claude-code
		pkgs.gemini-cli
	];

	programs.nushell = {
		enable = true;
		configFile.text = ''
			# Nushell configuration
			$env.config = {
				completions: {
					case_sensitive: false
					algorithm: "fuzzy"
				}
			}

			# Aliases
			alias lg = lazygit
		'';
		envFile.text = ''
			# Nushell environment (env.nu)
			# Export environment variables
			$env.EDITOR = "nvim"
		'';
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
