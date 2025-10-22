{ config, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;

    userName = "Humberto STEIN SHIROMOTO";
    # userEmail is managed via git config file template below
    # to allow runtime secret injection from SOPS

    extraConfig = {
      # User configuration with SOPS-managed signing key
      user = {
        # Signing key is managed via git config file template below
        # to allow runtime secret injection
      };

      # Core settings
      core = {
        editor = "nvim";
        excludesfile = "~/.gitignore_global";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        pager = "delta";
        hooksPath = "~/.git-hooks";
      };

      # Initialize settings
      init = {
        defaultBranch = "main";
      };

      # Checkout settings
      checkout = {
        defaultRemote = "origin";
      };

      # Push settings
      push = {
        autoSetupRemote = true;
        followTags = true;
      };

      # Fetch settings
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      # Color settings
      color = {
        ui = "auto";
      };

      # Column settings
      column = {
        ui = "auto";
      };

      # Delta configuration
      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
        features = "decorations line-numbers";
      };

      "delta \"decorations\"" = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
      };

      # Commit settings
      commit = {
        gpgsign = true;
      };

      # Git-flow configuration
      gitflow = {
        branch = {
          master = "main";
          develop = "dev";
        };
        prefix = {
          feature = "feature/";
          bugfix = "bugfix/";
          release = "release/";
          hotfix = "hotfix/";
          support = "support/";
          versiontag = "v";
        };
      };

      # Aliases
      alias = {
        gs = "git status";
        gd = "git diff --name-only --relative --diff-filter=d | xargs batcat --diff";
        gc = "git commit -m '.'";
        gP = "git push";
        gp = "git pull";
        gfb = "git flow bugfix start";
        gfh = "git flow hotfix start";
        gfr = "git flow release start";
        gff = "git flow feature start";
      };
    };

    # Include SOPS-managed signing key configuration
    includes = [
      {
        path = "~/.config/git/config.d/signingkey";
        condition = null;
      }
    ];
  };

  # SOPS configuration for git signing key and user email
  sops = {
    secrets = {
      git_signingkey = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/gitconfig.yaml";
        path = "${config.home.homeDirectory}/.config/sops/secrets/git_signingkey";
      };
      user_email = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/gitconfig.yaml";
        path = "${config.home.homeDirectory}/.config/sops/secrets/user_email";
      };
    };

    # Generate gitconfig user settings file with SOPS
    templates."gitconfig-signingkey" = {
      content = ''
[user]
	email = ${config.sops.placeholder.user_email}
	signingkey = ${config.sops.placeholder.git_signingkey}
'';
      path = "${config.home.homeDirectory}/.config/git/config.d/signingkey";
      mode = "0600";
    };
  };
}
