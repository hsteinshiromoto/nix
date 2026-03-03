{ hostname }:

{ config, pkgs, ... }:

let
  # Host-specific sops secret path (dendritic pattern)
  gitlabSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/gitlab.yaml";
  gitlabSshKeyPath = "${config.home.homeDirectory}/.ssh/gitlab_ssh";
in
{
  # GitLab CLI package
  home.packages = [
    pkgs.glab
  ];

  # SOPS secrets configuration for GitLab
  sops = {
    secrets = {
      gitlab_ssh = {
        sopsFile = gitlabSopsFile;
        path = gitlabSshKeyPath;
        mode = "0600";
      };
      gitlab_token = {
        sopsFile = gitlabSopsFile;
      };
      gitlab_host = {
        sopsFile = gitlabSopsFile;
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
    git_protocol: ssh
    token: ${config.sops.placeholder.gitlab_token}

# Default GitLab hostname
host: ${config.sops.placeholder.gitlab_host}

# Additional global settings
editor: nvim
browser: open
git_protocol: ssh
'';
      path = "${config.home.homeDirectory}/.config/glab-cli/config.yml";
      mode = "0600";
    };
  };
}
