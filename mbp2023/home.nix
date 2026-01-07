{ config, pkgs, ... }:

let
  iris-cli = pkgs.rustPlatform.buildRustPackage rec {
    pname = "iris-cli";
    version = "1.3.6";

    src = pkgs.fetchFromGitHub {
      owner = "lordaimer";
      repo = "iris";
      rev = "v${version}";
      hash = "sha256-g42W+XMN9K4yAt9YRCuuYFf3zOoEISXy1M3E5liKhBg=";
    };

    cargoHash = "sha256-7HyaJDxOv0gs+CujH8FERufaTiv+m2j1go514HC3Jk0=";

    # Tests require filesystem access which is not available in the Nix sandbox
    doCheck = false;

    meta = with pkgs.lib; {
      description = "A fast, minimal, config-driven file organizer built with Rust";
      homepage = "https://github.com/lordaimer/iris";
      license = licenses.mit;
      mainProgram = "iris";
    };
  };
in
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
		pkgs.ffmpeg-headless
		pkgs.gitflow
		pkgs.pyright
		pkgs.regex-tui
		pkgs.serie
		pkgs.spotify-player
		iris-cli
		pkgs.tailscale
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
			theme = "tokyonight";
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

	# Configure SOPS for secrets management
	sops = {
		gnupg.home = "${config.home.homeDirectory}/.gnupg";
		defaultSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2023/authorized_keys.yaml";

		secrets.authorized_keys = {
			path = "${config.home.homeDirectory}/.ssh/authorized_keys";
			mode = "0600";
		};
	};

	# Set environment variables
	home.sessionVariables = {
		XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
		TERMINFO_DIRS = "${config.home.homeDirectory}/.terminfo:/Applications/Ghostty.app/Contents/Resources/terminfo:/usr/share/terminfo";
	};

	# LaunchAgent for auto-mounting Time Machine Samba share
	launchd.agents.timemachine-mount = {
		enable = true;
		config = {
			ProgramArguments = [
				"${pkgs.bash}/bin/bash"
				"-c"
				''
					# Check if already mounted
					if mount | grep -q 'TimeMachine'; then
						echo "TimeMachine already mounted"
						exit 0
					fi

					# Try to get servidor IP from Tailscale
					# First try using Tailscale CLI if available
					if command -v tailscale &> /dev/null; then
						SERVER_IP=$(tailscale status --json | ${pkgs.jq}/bin/jq -r '.Peer[] | select(.HostName == "servidor") | .TailscaleIPs[0]' 2>/dev/null)
					fi

					# If tailscale command not found or didn't return IP, try hostname
					if [ -z "$SERVER_IP" ]; then
						# Try Tailscale MagicDNS hostname
						if ping -c 1 -W 1 servidor &> /dev/null; then
							SERVER_IP="servidor"
						fi
					fi

					echo "Attempting to mount TimeMachine from $SERVER_IP"
					/usr/bin/open "smb://$SERVER_IP/TimeMachine"
				''
			];
			RunAtLoad = true;
			StartInterval = 3600;  # Check every hour (3600 seconds)
			StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/timemachine-mount.err.log";
			StandardOutPath = "${config.home.homeDirectory}/Library/Logs/timemachine-mount.out.log";
		};
	};

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
