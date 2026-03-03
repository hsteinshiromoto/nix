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
    };

    # Use sops templates to generate glab-cli config with secrets
    templates."glab-cli/config.yml" = {
      content = ''
# GitLab CLI configuration
hosts:
  gitlab.akordi.com:
    api_protocol: https
    api_host: www.gitlab.com
    git_protocol: ssh
    token: ""

# Default GitLab hostname
host: www.gitlab.com

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
