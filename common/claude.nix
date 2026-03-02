{ hostname }:

{ config, pkgs, ... }:

let
  # Host-specific sops secret paths (dendritic pattern)
  bedrockSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/bedrock.yaml";
  bedrockSecretPath = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/bedrock";

  # Community plugins from third-party marketplaces
  # Each entry: { name, marketplace, repo }
  #   name        = plugin name as it appears in the marketplace
  #   marketplace = marketplace identifier (derived from repo by CLI)
  #   repo        = GitHub "owner/repo" for the marketplace
  communityPlugins = [
    {
      name = "claude-reflect";
      marketplace = "claude-reflect-marketplace";
      repo = "bayramannakov/claude-reflect";
    }
  ];

  # Official plugins (registered via the built-in marketplace)
  # These need only enabledPlugins config; no CLI install needed
  officialPlugins = [
    "pyright-lsp"
    "lua-lsp"
    "serena"
    "gitlab"
    "code-review"
  ];

  # Build the enabledPlugins JSON fragment
  officialEntries = builtins.map (name:
    ''"${name}@claude-plugins-official": true''
  ) officialPlugins;

  communityEntries = builtins.map (p:
    ''"${p.name}@${p.marketplace}": true''
  ) communityPlugins;

  allPluginEntries = officialEntries ++ communityEntries;
  enabledPluginsJson = builtins.concatStringsSep ",\n    " allPluginEntries;
in
{
  # SOPS secrets configuration for Claude Code
  sops = {
    secrets = {
      AWS_BEARER_TOKEN_BEDROCK = {
        sopsFile = bedrockSopsFile;
        path = bedrockSecretPath;
      };
    };

    # Use sops templates to generate Claude settings.json with secrets
    templates."claude/settings.json" = {
      content = ''
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "ap-southeast-2",
    "AWS_PROFILE": "sandbox",
    "ANTHROPIC_MODEL": "arn:aws:bedrock:ap-southeast-2:058264223017:inference-profile/global.anthropic.claude-opus-4-6-v1",
    "ANTHROPIC_SMALL_FAST_MODEL": "arn:aws:bedrock:ap-southeast-2:058264223017:inference-profile/au.anthropic.claude-haiku-4-5-20251001-v1:0",
    "AWS_BEARER_TOKEN_BEDROCK": "${config.sops.placeholder.AWS_BEARER_TOKEN_BEDROCK}"
  },
  "enabledPlugins": {
    ${enabledPluginsJson}
  },
  "awsAuthRefresh": "aws sso login --profile sandbox",
  "permissions": {
    "allow": [
      "Bash(grep:*)",
      "Read(//Users/hsteinshiromoto/Library/Fonts/**)",
      "Read(//Library/Fonts/**)",
      "Read(//Users/hsteinshiromoto/.config/nix/**)",
      "Read(//Users/hsteinshiromoto/dotfiles/**)",
      "Bash(find:*)"
    ],
    "deny": []
  }
}
'';
      path = "${config.home.homeDirectory}/.claude/settings.json";
      mode = "0600";
    };
  };

  # Set environment variable for shell access
  home.sessionVariables = {
    AWS_BEARER_TOKEN_BEDROCK = "$(cat ${bedrockSecretPath} 2>/dev/null || echo '')";
  };

  # Declarative Claude Code plugin management
  # Installs community marketplace plugins on every home-manager activation.
  # Runs after sops-nix so that ~/.claude/settings.json exists.
  # Network failures are absorbed (|| true) to avoid breaking the rebuild.
  home.activation.installClaudePlugins = config.lib.dag.entryAfter ["writeBoundary" "sops-nix"] ''
    CLAUDE_BIN="${config.home.homeDirectory}/.local/state/nix/profiles/profile/bin/claude"
    if [ -x "$CLAUDE_BIN" ]; then
      echo "Installing Claude Code community plugins..."
      ${builtins.concatStringsSep "\n      " (builtins.map (p:
        "$DRY_RUN_CMD \"$CLAUDE_BIN\" plugin marketplace add ${p.repo} || true"
      ) communityPlugins)}
      ${builtins.concatStringsSep "\n      " (builtins.map (p:
        "$DRY_RUN_CMD \"$CLAUDE_BIN\" plugin install ${p.name}@${p.marketplace} || true"
      ) communityPlugins)}
    else
      echo "Claude CLI not found at $CLAUDE_BIN, skipping plugin installation"
    fi
  '';
}
