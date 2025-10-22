{ config, pkgs, ... }:

{
	programs = {

		nushell = {
			enable = true;
		};

	};

	# Create tool integration init files
	xdg.configFile."nushell-integrations/starship.nu".text = ''
		${builtins.readFile (pkgs.runCommand "starship-init" {} ''
			${pkgs.starship}/bin/starship init nu > $out
		'')}
	'';

	xdg.configFile."nushell-integrations/zoxide.nu".text = ''
		${builtins.readFile (pkgs.runCommand "zoxide-init" {} ''
			${pkgs.zoxide}/bin/zoxide init nushell > $out
		'')}
	'';

	xdg.configFile."nushell-integrations/atuin.nu".text = ''
		${builtins.readFile (pkgs.runCommand "atuin-init" {
			HOME = "/tmp/atuin-build-home";
		} ''
			mkdir -p $HOME/.config/atuin
			${pkgs.atuin}/bin/atuin init nu > $out
		'')}
	'';

	# Manually create nushell config files using xdg.configFile
	xdg.configFile."nushell/config.nu".text = ''
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

		# Tool integrations
		source ~/.config/nushell-integrations/starship.nu
		source ~/.config/nushell-integrations/zoxide.nu
		source ~/.config/nushell-integrations/atuin.nu
	'';

	xdg.configFile."nushell/env.nu".text = ''
		# Nushell environment (env.nu)
		# Export environment variables
		$env.EDITOR = "nvim"
	'';
}
