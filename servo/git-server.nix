{ config, pkgs, lib, ... }:

let
  gitHome = "/var/lib/git-server";
  gitUser = "git";
  webhookScript = pkgs.writeScriptBin "git-webhook" ''
    #!${pkgs.bash}/bin/bash
    # Git webhook dispatcher
    # This script is called from post-receive hooks to trigger webhooks

    set -e

    REPO_PATH="$1"
    REPO_NAME=$(basename "$REPO_PATH" .git)

    # Webhook configuration directory
    WEBHOOK_DIR="${gitHome}/webhooks"
    WEBHOOK_CONFIG="$WEBHOOK_DIR/$REPO_NAME.conf"

    if [ ! -f "$WEBHOOK_CONFIG" ]; then
      echo "No webhook configuration found for $REPO_NAME"
      exit 0
    fi

    # Source the webhook configuration
    source "$WEBHOOK_CONFIG"

    # Get the latest commit information
    while read oldrev newrev refname; do
      if [ "$newrev" = "0000000000000000000000000000000000000000" ]; then
        # Branch deletion
        ACTION="delete"
        COMMIT="$oldrev"
      else
        # New commit or branch creation
        ACTION="push"
        COMMIT="$newrev"
      fi

      BRANCH=$(echo "$refname" | sed 's/refs\/heads\///')

      # Prepare webhook payload
      PAYLOAD=$(${pkgs.jq}/bin/jq -n \
        --arg repo "$REPO_NAME" \
        --arg branch "$BRANCH" \
        --arg commit "$COMMIT" \
        --arg action "$ACTION" \
        '{repository: $repo, branch: $branch, commit: $commit, action: $action}')

      # Send webhook if URL is configured
      if [ -n "$WEBHOOK_URL" ]; then
        echo "Sending webhook for $REPO_NAME ($BRANCH)"
        ${pkgs.curl}/bin/curl -X POST \
          -H "Content-Type: application/json" \
          -d "$PAYLOAD" \
          "$WEBHOOK_URL" || echo "Webhook failed"
      fi

      # Execute custom script if configured
      if [ -n "$WEBHOOK_SCRIPT" ] && [ -x "$WEBHOOK_SCRIPT" ]; then
        echo "Executing webhook script: $WEBHOOK_SCRIPT"
        "$WEBHOOK_SCRIPT" "$REPO_NAME" "$BRANCH" "$COMMIT" "$ACTION"
      fi
    done
  '';

  gitCreateRepo = pkgs.writeScriptBin "git-create-repo" ''
    #!${pkgs.bash}/bin/bash
    # Create a new git repository

    set -e

    if [ $# -eq 0 ]; then
      echo "Usage: git-create-repo <repo-name> [description]"
      echo "Example: git-create-repo myproject.git \"My awesome project\""
      exit 1
    fi

    REPO_NAME="$1"
    DESCRIPTION="''${2:-}"

    # Ensure .git extension
    if [[ ! "$REPO_NAME" =~ \.git$ ]]; then
      REPO_NAME="$REPO_NAME.git"
    fi

    REPO_PATH="${gitHome}/$REPO_NAME"

    if [ -d "$REPO_PATH" ]; then
      echo "Error: Repository $REPO_NAME already exists"
      exit 1
    fi

    echo "Creating repository: $REPO_NAME"
    sudo -u ${gitUser} ${pkgs.git}/bin/git init --bare --initial-branch=main "$REPO_PATH"

    # Set description if provided
    if [ -n "$DESCRIPTION" ]; then
      echo "$DESCRIPTION" | sudo tee "$REPO_PATH/description" > /dev/null
    fi

    # Create post-receive hook for webhooks
    POST_RECEIVE_HOOK="$REPO_PATH/hooks/post-receive"
    cat > "$POST_RECEIVE_HOOK" <<'EOF'
    #!/usr/bin/env bash
    ${webhookScript}/bin/git-webhook "$PWD"
    EOF

    sudo chmod +x "$POST_RECEIVE_HOOK"
    sudo chown ${gitUser}:${gitUser} "$POST_RECEIVE_HOOK"

    echo "Repository created successfully!"
    echo "Clone with: git clone ${gitUser}@servidor:$REPO_NAME"
  '';

  gitDeleteRepo = pkgs.writeScriptBin "git-delete-repo" ''
    #!${pkgs.bash}/bin/bash
    # Delete a git repository (with confirmation)

    set -e

    if [ $# -eq 0 ]; then
      echo "Usage: git-delete-repo <repo-name>"
      exit 1
    fi

    REPO_NAME="$1"

    # Ensure .git extension
    if [[ ! "$REPO_NAME" =~ \.git$ ]]; then
      REPO_NAME="$REPO_NAME.git"
    fi

    REPO_PATH="${gitHome}/$REPO_NAME"

    if [ ! -d "$REPO_PATH" ]; then
      echo "Error: Repository $REPO_NAME does not exist"
      exit 1
    fi

    echo "WARNING: This will permanently delete repository: $REPO_NAME"
    read -p "Are you sure? (type 'yes' to confirm): " CONFIRM

    if [ "$CONFIRM" != "yes" ]; then
      echo "Deletion cancelled"
      exit 0
    fi

    echo "Deleting repository: $REPO_NAME"
    sudo rm -rf "$REPO_PATH"

    # Remove webhook configuration if exists
    WEBHOOK_CONFIG="${gitHome}/webhooks/$REPO_NAME.conf"
    if [ -f "$WEBHOOK_CONFIG" ]; then
      sudo rm "$WEBHOOK_CONFIG"
    fi

    echo "Repository deleted successfully"
  '';

  gitListRepos = pkgs.writeScriptBin "git-list-repos" ''
    #!${pkgs.bash}/bin/bash
    # List all git repositories

    echo "Git repositories on servidor:"
    echo "=============================="

    for repo in ${gitHome}/*.git; do
      if [ -d "$repo" ]; then
        REPO_NAME=$(basename "$repo")
        DESCRIPTION=""

        if [ -f "$repo/description" ]; then
          DESCRIPTION=$(cat "$repo/description")
        fi

        echo ""
        echo "Repository: $REPO_NAME"
        if [ -n "$DESCRIPTION" ]; then
          echo "  Description: $DESCRIPTION"
        fi
        echo "  Clone URL: ${gitUser}@servidor:$REPO_NAME"
      fi
    done
  '';

  gitConfigureWebhook = pkgs.writeScriptBin "git-configure-webhook" ''
    #!${pkgs.bash}/bin/bash
    # Configure webhook for a repository

    set -e

    if [ $# -lt 2 ]; then
      echo "Usage: git-configure-webhook <repo-name> <webhook-url> [script-path]"
      echo "Example: git-configure-webhook myproject.git https://api.example.com/webhook"
      echo "Example with script: git-configure-webhook myproject.git \"\" /path/to/script.sh"
      exit 1
    fi

    REPO_NAME="$1"
    WEBHOOK_URL="$2"
    WEBHOOK_SCRIPT="''${3:-}"

    # Ensure .git extension
    if [[ ! "$REPO_NAME" =~ \.git$ ]]; then
      REPO_NAME="$REPO_NAME.git"
    fi

    REPO_PATH="${gitHome}/$REPO_NAME"

    if [ ! -d "$REPO_PATH" ]; then
      echo "Error: Repository $REPO_NAME does not exist"
      exit 1
    fi

    # Create webhooks directory if it doesn't exist
    WEBHOOK_DIR="${gitHome}/webhooks"
    sudo mkdir -p "$WEBHOOK_DIR"

    # Create webhook configuration
    WEBHOOK_CONFIG="$WEBHOOK_DIR/$(basename "$REPO_NAME" .git).conf"

    sudo tee "$WEBHOOK_CONFIG" > /dev/null <<EOF
    # Webhook configuration for $REPO_NAME
    WEBHOOK_URL="$WEBHOOK_URL"
    WEBHOOK_SCRIPT="$WEBHOOK_SCRIPT"
    EOF

    sudo chown ${gitUser}:${gitUser} "$WEBHOOK_CONFIG"
    sudo chmod 600 "$WEBHOOK_CONFIG"

    echo "Webhook configured for $REPO_NAME"
    if [ -n "$WEBHOOK_URL" ]; then
      echo "  URL: $WEBHOOK_URL"
    fi
    if [ -n "$WEBHOOK_SCRIPT" ]; then
      echo "  Script: $WEBHOOK_SCRIPT"
    fi
  '';

in {
  # Git server user and group
  users.groups.git = {};
  users.users.git = {
    isSystemUser = true;
    group = "git";
    home = gitHome;
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";

    # SSH authorized_keys managed by sops-ssh-keys-sync systemd service
    # (same keys as hsteinshiromoto user)
  };

  # SSH configuration for git user
  services.openssh.extraConfig = ''
    Match user git
      AllowTcpForwarding no
      AllowAgentForwarding no
      PasswordAuthentication no
      PermitTTY no
      X11Forwarding no
  '';

  # Add helper scripts to system packages
  environment.systemPackages = [
    gitCreateRepo
    gitDeleteRepo
    gitListRepos
    gitConfigureWebhook
    webhookScript
  ];

  # Ensure git-shell-commands directory exists with helpful commands
  # Note: The mount point /var/lib/git-server is created by disko with its own partition
  systemd.tmpfiles.rules = [
    # Set ownership of the mount point itself (disko creates it as root)
    "z ${gitHome} 0755 ${gitUser} ${gitUser} -"
    "d ${gitHome}/.ssh 0700 ${gitUser} ${gitUser} -"
    "d ${gitHome}/git-shell-commands 0755 ${gitUser} ${gitUser} -"
    "d ${gitHome}/webhooks 0700 ${gitUser} ${gitUser} -"
  ];

  # Create helpful git-shell commands
  environment.etc."git-shell-commands/help" = {
    text = ''
      #!/bin/sh
      cat <<EOF
      Git Server on servidor
      ======================

      Available commands:
        help     - Show this help message
        list     - List all repositories

      To create a repository, contact your administrator or use:
        sudo git-create-repo <name>

      To clone a repository:
        git clone git@servidor:<repository-name>.git
      EOF
    '';
    mode = "0755";
  };

  environment.etc."git-shell-commands/list" = {
    text = ''
      #!/bin/sh
      cd ${gitHome}
      for repo in *.git; do
        if [ -d "$repo" ]; then
          echo "$repo"
        fi
      done
    '';
    mode = "0755";
  };
}
