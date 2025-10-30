# SOPS SSH Keys Setup Guide

## Overview

Your SSH authorized_keys are now managed securely using SOPS (Secrets OPerationS). The keys are encrypted and stored at `~/.config/sops/secrets/ssh.yaml` on the server.

## Prerequisites

1. SOPS installed (already in your system packages)
2. Age key generated at `/home/hsteinshiromoto/.config/sops/keys/age`

## Initial Setup

### 1. Generate Age Key (if not already done)

On your **server**:

```bash
# Create directory
mkdir -p ~/.config/sops/keys

# Generate age key
age-keygen -o ~/.config/sops/keys/age

# View your public key
cat ~/.config/sops/keys/age | grep "# public key:"
```

**Important**: Save the public key (starts with `age1...`). You'll need it to encrypt secrets.

### 2. Create .sops.yaml Configuration

On your **server**, create `~/.config/sops/.sops.yaml`:

```yaml
creation_rules:
  - path_regex: .*/ssh\.yaml$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Replace `age1xxx...` with your actual age public key from step 1.

### 3. Get Your SSH Public Key

On your **Mac** (or wherever you connect from):

```bash
# Get your YubiKey public key
ssh-add -L

# Or if using a regular SSH key
cat ~/.ssh/id_ed25519.pub
# or
cat ~/.ssh/id_rsa.pub
```

Copy the output (the entire line starting with `ssh-rsa` or `ssh-ed25519`).

### 4. Create Encrypted SSH Keys File

On your **server**:

```bash
# Create directory
mkdir -p ~/.config/sops/secrets

# Create the unencrypted file first
cat > /tmp/ssh_temp.yaml <<EOF
ssh:
  authorized_keys: |
    YOUR_SSH_PUBLIC_KEY_HERE
EOF
```

Replace `YOUR_SSH_PUBLIC_KEY_HERE` with your actual public key from step 3.

**Example:**
```yaml
ssh:
  authorized_keys: |
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... cardno:14 702 655
```

### 5. Encrypt with SOPS

```bash
# Encrypt the file
sops --config ~/.config/sops/.sops.yaml \
     --encrypt /tmp/ssh_temp.yaml > ~/.config/sops/secrets/ssh.yaml

# Remove temporary file
rm /tmp/ssh_temp.yaml

# Verify encryption
cat ~/.config/sops/secrets/ssh.yaml
```

You should see encrypted content like:
```yaml
ssh:
    authorized_keys: ENC[AES256_GCM,data:xxx...]
sops:
    kms: []
    ...
```

### 6. Test Decryption

```bash
# View decrypted content
sops --decrypt ~/.config/sops/secrets/ssh.yaml
```

This should show your plaintext public key.

### 7. Rebuild NixOS

```bash
cd ~/nix  # or wherever your config is
sudo nixos-rebuild switch --flake .#servidor
```

NixOS will now:
1. Decrypt the SOPS secret at boot time to `/run/secrets/ssh/authorized_keys`
2. Run the `sops-ssh-keys-sync` systemd service
3. Copy the decrypted keys to both users' authorized_keys:
   - `/home/hsteinshiromoto/.ssh/authorized_keys`
   - `/var/lib/git-server/.ssh/authorized_keys`

### 8. Verify It Works

```bash
# Check the secret was decrypted
cat /run/secrets/ssh/authorized_keys

# Check hsteinshiromoto's authorized_keys
cat ~/.ssh/authorized_keys

# Check git user's authorized_keys
sudo cat /var/lib/git-server/.ssh/authorized_keys
```

All three should contain your public key!

### 9. Test SSH Connection

From your **Mac**:

```bash
# Test regular user
ssh hsteinshiromoto@100.114.205.2

# Test git user
ssh git@100.114.205.2
# Should see: "Hi! You've successfully authenticated, but git-shell does not provide shell access."

# Test git clone
git clone git@100.114.205.2:test_1.git
```

## Adding More Keys

To add additional SSH keys:

```bash
# Edit the encrypted file
sops ~/.config/sops/secrets/ssh.yaml
```

This opens your editor. Add more keys like:

```yaml
ssh:
  authorized_keys: |
    ssh-rsa AAAAB3Nza... first-key
    ssh-ed25519 AAAAC3Nza... second-key
    ssh-rsa AAAAB3Nza... third-key
```

Save and exit. SOPS will re-encrypt automatically.

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#servidor
```

## Troubleshooting

### Permission Denied When Connecting

```bash
# Check if secret is decrypted
ls -la /run/secrets/ssh/
cat /run/secrets/ssh/authorized_keys

# Check if sync service ran successfully
sudo systemctl status sops-ssh-keys-sync.service

# Check if authorized_keys files exist
cat ~/.ssh/authorized_keys
sudo cat /var/lib/git-server/.ssh/authorized_keys

# Check permissions
ls -la ~/.ssh/
sudo ls -la /var/lib/git-server/.ssh/

# Manually trigger the sync service
sudo systemctl restart sops-ssh-keys-sync.service
```

### SOPS Decryption Fails

```bash
# Verify age key exists
cat ~/.config/sops/keys/age

# Test manual decryption
SOPS_AGE_KEY_FILE=~/.config/sops/keys/age sops --decrypt ~/.config/sops/secrets/ssh.yaml
```

### Secret Not Found During Build

```bash
# Check SOPS configuration in NixOS config
grep -A 10 "sops = {" ~/nix/servo/configuration.nix

# Verify file path
ls -la ~/.config/sops/secrets/ssh.yaml
```

## Security Notes

1. **Never commit** `~/.config/sops/keys/age` (your private key) to git
2. **Never commit** decrypted yaml files to git
3. The encrypted `ssh.yaml` is safe to commit if you want version control
4. Each server should have its own age key
5. Back up your age private key securely

## File Locations

- Age private key: `/home/hsteinshiromoto/.config/sops/keys/age`
- SOPS config: `/home/hsteinshiromoto/.config/sops/.sops.yaml`
- Encrypted secrets: `/home/hsteinshiromoto/.config/sops/secrets/ssh.yaml`
- Runtime secret: `/run/secrets/ssh/authorized_keys` (created by NixOS)
- User authorized_keys: `/home/hsteinshiromoto/.ssh/authorized_keys` (symlink or copy)
- Git user authorized_keys: `/var/lib/git-server/.ssh/authorized_keys` (symlink or copy)

## Quick Reference

```bash
# Edit encrypted file
sops ~/.config/sops/secrets/ssh.yaml

# View decrypted content
sops --decrypt ~/.config/sops/secrets/ssh.yaml

# Rebuild and apply
sudo nixos-rebuild switch --flake .#servidor

# Test connection
ssh git@100.114.205.2
```
