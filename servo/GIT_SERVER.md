# Git Server Documentation

## Overview

Your NixOS server `servidor` is configured with a lightweight, SSH-based git server. This provides secure git hosting without the overhead of web interfaces like GitLab or Gitea.

## Architecture

- **Git user**: `git` (system user)
- **Home directory**: `/var/lib/git-server`
- **Shell**: `git-shell` (restricted, secure shell)
- **Access method**: SSH with authorized keys
- **Port**: 22 (standard SSH)

## Initial Setup

### 1. Deploy the Configuration

After making changes to the configuration, rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#servidor
```

### 2. Add SSH Keys for Git Access

The git user's authorized keys are managed through the `.ssh/authorized_keys` file in the `servo/` directory.

1. Edit `/Users/hsteinshiromoto/Projects/nix/servo/.ssh/authorized_keys`
2. Add public SSH keys (one per line)
3. Rebuild the system to apply changes

**Note**: The same keys are used for both your regular user and the git user. You can differentiate them later if needed.

## Repository Management

The git server includes four helper commands for managing repositories:

### Create a Repository

```bash
sudo git-create-repo <repo-name> [description]
```

**Examples:**
```bash
# Basic usage
sudo git-create-repo myproject.git

# With description
sudo git-create-repo myproject.git "My awesome project"

# .git extension is optional (will be added automatically)
sudo git-create-repo myproject "Another project"
```

This command:
- Creates a bare git repository at `/var/lib/git-server/<repo-name>.git`
- Sets up webhook support (post-receive hook)
- Sets proper permissions

### List All Repositories

```bash
git-list-repos
```

Shows all repositories with their descriptions and clone URLs.

### Delete a Repository

```bash
sudo git-delete-repo <repo-name>
```

**Example:**
```bash
sudo git-delete-repo myproject.git
```

This command:
- Asks for confirmation (you must type 'yes')
- Deletes the repository directory
- Removes associated webhook configuration

### Configure Webhooks

```bash
sudo git-configure-webhook <repo-name> <webhook-url> [script-path]
```

**Examples:**
```bash
# HTTP webhook
sudo git-configure-webhook myproject.git https://api.example.com/webhook

# Custom script execution
sudo git-configure-webhook myproject.git "" /usr/local/bin/deploy.sh

# Both webhook URL and script
sudo git-configure-webhook myproject.git https://api.example.com/webhook /usr/local/bin/deploy.sh
```

## Using the Git Server

### Clone a Repository

From any machine with SSH access:

```bash
git clone git@servidor:<repo-name>.git
```

**Example:**
```bash
git clone git@servidor:myproject.git
```

If using an IP address or different hostname:

```bash
git clone git@192.168.1.100:myproject.git
```

### Push Changes

Standard git workflow:

```bash
cd myproject
git add .
git commit -m "My changes"
git push origin main
```

### Add as Remote to Existing Repository

```bash
cd existing-repo
git remote add origin git@servidor:myproject.git
git push -u origin main
```

## Webhooks

Webhooks trigger automatically on `git push` events. They can:
- Send HTTP POST requests to specified URLs
- Execute custom scripts
- Both

### Webhook Payload

When using HTTP webhooks, the following JSON payload is sent:

```json
{
  "repository": "myproject",
  "branch": "main",
  "commit": "abc123def456...",
  "action": "push"
}
```

### Custom Webhook Scripts

Scripts receive four arguments:

```bash
script.sh <repo-name> <branch> <commit> <action>
```

**Example script** (`/usr/local/bin/deploy.sh`):

```bash
#!/usr/bin/env bash

REPO=$1
BRANCH=$2
COMMIT=$3
ACTION=$4

echo "Received push to $REPO on branch $BRANCH"

if [ "$BRANCH" = "main" ]; then
  echo "Deploying commit $COMMIT..."
  # Your deployment logic here
fi
```

Make your script executable:

```bash
sudo chmod +x /usr/local/bin/deploy.sh
```

### Webhook Configuration Files

Webhook configurations are stored in:
```
/var/lib/git-server/webhooks/<repo-name>.conf
```

Format:
```bash
WEBHOOK_URL="https://api.example.com/webhook"
WEBHOOK_SCRIPT="/path/to/script.sh"
```

## Git Shell Commands

When logged in as the git user (limited shell), these commands are available:

```bash
ssh git@servidor help  # Show help
ssh git@servidor list  # List repositories
```

## Security Features

1. **Restricted Shell**: Git user can only execute git commands
2. **No Forwarding**: TCP and agent forwarding disabled
3. **No TTY**: Interactive login disabled
4. **Key-based Auth Only**: Password authentication disabled
5. **Limited Permissions**: Git user has minimal system access

## Troubleshooting

### Cannot Push/Pull

1. Check SSH key is in authorized_keys:
   ```bash
   cat servo/.ssh/authorized_keys
   ```

2. Test SSH connection:
   ```bash
   ssh -T git@servidor
   ```
   You should see: `Hi! You've successfully authenticated, but git-shell does not provide shell access.`

3. Verify repository exists:
   ```bash
   git-list-repos
   ```

### Webhooks Not Triggering

1. Check webhook configuration:
   ```bash
   sudo cat /var/lib/git-server/webhooks/<repo-name>.conf
   ```

2. Check post-receive hook exists and is executable:
   ```bash
   ls -l /var/lib/git-server/<repo-name>.git/hooks/post-receive
   ```

3. Test webhook manually:
   ```bash
   cd /var/lib/git-server/<repo-name>.git
   sudo -u git hooks/post-receive
   ```

### Permission Denied Errors

Ensure directories have correct ownership:
```bash
sudo chown -R git:git /var/lib/git-server
```

## Backup Recommendations

Regularly backup the git server directory:

```bash
sudo tar -czf git-server-backup-$(date +%Y%m%d).tar.gz /var/lib/git-server
```

Or use syncthing/rsync to continuously sync:

```bash
rsync -avz /var/lib/git-server/ backup-location/git-server/
```

## Advanced Usage

### Multiple Authorized Keys with Restrictions

You can add command restrictions to authorized keys:

```
command="git-shell -c \"$SSH_ORIGINAL_COMMAND\"" ssh-rsa AAAAB3...
```

### Custom Git Hooks

Add additional hooks to repositories:

```bash
sudo nano /var/lib/git-server/<repo>.git/hooks/pre-receive
```

Make executable:
```bash
sudo chmod +x /var/lib/git-server/<repo>.git/hooks/pre-receive
sudo chown git:git /var/lib/git-server/<repo>.git/hooks/pre-receive
```

### Repository Mirroring

Mirror to another git server:

```bash
cd /var/lib/git-server/<repo>.git
sudo -u git git remote add --mirror=push backup git@backup-server:repo.git
```

Add to post-receive hook:
```bash
git push backup
```

## Configuration Files

- **Main module**: `servo/git-server.nix`
- **Authorized keys**: `servo/.ssh/authorized_keys`
- **System config**: `servo/configuration.nix` (imports git-server.nix)

## References

- [NixOS Wiki: Git](https://nixos.wiki/wiki/Git#Serve_Git_repos_via_SSH)
- [Git Documentation: git-shell](https://git-scm.com/docs/git-shell)
- [Pro Git Book: Git on the Server](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server)
