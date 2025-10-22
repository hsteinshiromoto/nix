{ config, pkgs, ... }:

{
  # GitLab CLI package
  home.packages = [
    pkgs.glab
  ];

  # SOPS secrets configuration for GitLab
  sops = {
    # Use GPG for decryption (age key not available)
    # age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/gitlab.yaml";
    # Disable build-time validation to avoid sandbox permission issues on Darwin
    validateSopsFiles = false;
    # Use GPG for decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

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
    token: ${config.sops.placeholder.gitlab_token}

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

  # Set environment variables
  home.sessionVariables = {
    # Note: GITLAB_TOKEN and GITLAB_HOST are managed by glab-cli config
    # via sops templates above (see templates."glab-cli/config.yml")
  };
}
