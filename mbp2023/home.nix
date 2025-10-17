{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.claude-code
		pkgs.codex
		pkgs.gemini-cli
		pkgs.ollama
		pkgs.spotify-player
		pkgs.nushellPlugins.highlight
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
					};
					buffer_editor: "vim"
				}

				# Register nu-plugin-highlight
				plugin add ${pkgs.nushellPlugins.highlight}/bin/nu_plugin_highlight

				# Aliases
				alias lg = lazygit
				alias cat = bat
			'';

			envFile.text = ''
				# Nushell environment (env.nu)
				# Export environment variables
				$env.EDITOR = "nvim"
			'';
		};

		starship = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		atuin = {
			enable = true;
			enableNushellIntegration = true;
			enableZshIntegration = true;
		};

		bat = {
			enable = true;
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
