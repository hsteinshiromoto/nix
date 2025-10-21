{ config, pkgs, ... }:

{
  # SOPS configuration for git secrets
  sops = {
    secrets = {
      git_signingkey = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/gitconfig.yaml";
        path = "${config.home.homeDirectory}/.config/sops/secrets/git_signingkey";
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;

    userName = "Humberto STEIN SHIROMOTO";
    userEmail = "humberto.shiromoto@akordi.com";

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
  };

  # Use SOPS template to inject signing key into gitconfig
  sops.templates."gitconfig-signingkey" = {
    content = ''
[user]
	signingkey = ${config.sops.placeholder.git_signingkey}
'';
    path = "${config.home.homeDirectory}/.config/git/config.d/signingkey";
    mode = "0600";
  };

  # Ensure git config.d directory structure exists
  # Git will include files from ~/.config/git/config.d/ if they exist
  home.file.".config/git/config".text = ''
[include]
	path = config.d/signingkey
'';
}
