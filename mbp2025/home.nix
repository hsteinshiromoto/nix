{ config, pkgs, sqlit, ... }:

{
  imports = [
    ../common/gitconfig.nix
    ../common/gitlab.nix
    ../common/claude.nix
    ../common/nu.nix
    ./aws.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hsteinshiromoto";
  home.homeDirectory = "/Users/hsteinshiromoto";

	home.packages = [
		pkgs.delta
		pkgs.gitflow
		pkgs.jnv
		pkgs.just
		pkgs.pyright
		pkgs.regex-tui
		pkgs.serie
		sqlit.packages.aarch64-darwin.default
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
				format = {
					docstring-code-format = true;
				};
				lint = {
					task-tags = ["INFO" "NOTE" "ALERT" "WARNING"];
					future-annotations = true;
					isort = {
						extra-standard-library = ["path"];
						required-imports = ["from __future__ import annotations"];
					};
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

	# Set environment variables
	home.sessionVariables = {
		XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
		UV_PREBUILT = "1";
		TERMINFO_DIRS = "${config.home.homeDirectory}/.terminfo:/Applications/Ghostty.app/Contents/Resources/terminfo:/usr/share/terminfo";
		# Export GitLab secrets to shell environment (mbp2025 only)
		# The secret files are decrypted by sops-nix at activation time
		GITLAB_TOKEN = "$(cat ${config.home.homeDirectory}/.config/sops/secrets/gitlab_token 2>/dev/null || echo '')";
		GITLAB_HOST = "$(cat ${config.home.homeDirectory}/.config/sops/secrets/gitlab_host 2>/dev/null || echo '')";
	};

	# Configure SOPS to use GPG instead of age
	sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";

	# Override sops paths for gitconfig (mbp2025 uses different path than common config)
	sops.secrets.git_signingkey.sopsFile = pkgs.lib.mkForce "${config.home.homeDirectory}/.config/sops/secrets/gitconfig.yaml";
	sops.secrets.user_email.sopsFile = pkgs.lib.mkForce "${config.home.homeDirectory}/.config/sops/secrets/gitconfig.yaml";
	# Workaround for sops-nix PATH bug on macOS
	# The launchd service sets PATH="" which breaks getconf lookup
	# Extract binary path dynamically from the launchd plist
	home.activation.runSopsNix = config.lib.dag.entryAfter ["writeBoundary" "setupLaunchAgents" "sops-nix"] ''
		SOPS_NIX_BIN=$(grep -A1 "<key>Program</key>" ~/Library/LaunchAgents/org.nix-community.home.sops-nix.plist 2>/dev/null | grep string | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
		if [ -x "$SOPS_NIX_BIN" ]; then
			PATH="/usr/bin:/bin:/usr/sbin:/sbin" SOPS_GPG_EXEC="/usr/local/MacGPG2/bin/gpg" "$SOPS_NIX_BIN" || true
		fi
	'';

	# Install Ghostty terminfo for tmux compatibility
	home.activation.installGhosttyTerminfo = config.lib.dag.entryAfter ["writeBoundary"] ''
		if [ -d "/Applications/Ghostty.app/Contents/Resources/terminfo" ]; then
			$DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.terminfo
			$DRY_RUN_CMD ${pkgs.ncurses}/bin/infocmp -x xterm-ghostty > /tmp/xterm-ghostty.info 2>/dev/null || true
			if [ -f /tmp/xterm-ghostty.info ]; then
				$DRY_RUN_CMD ${pkgs.ncurses}/bin/tic -x -o ${config.home.homeDirectory}/.terminfo /tmp/xterm-ghostty.info 2>/dev/null || true
				$DRY_RUN_CMD rm -f /tmp/xterm-ghostty.info
			fi
		fi
	'';

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
