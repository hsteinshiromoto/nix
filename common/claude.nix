{ hostname, usePersonalAccount ? false }:

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

  # Build the enabledPlugins JSON fragment (for corporate sops template)
  officialEntries = builtins.map (name:
    ''"${name}@claude-plugins-official": true''
  ) officialPlugins;

  communityEntries = builtins.map (p:
    ''"${p.name}@${p.marketplace}": true''
  ) communityPlugins;

  allPluginEntries = officialEntries ++ communityEntries;
  enabledPluginsJson = builtins.concatStringsSep ",\n    " allPluginEntries;

  # Build enabledPlugins as a Nix attrset (for personal builtins.toJSON)
  enabledPluginsAttr = builtins.listToAttrs (
    (builtins.map (name: {
      name = "${name}@claude-plugins-official";
      value = true;
    }) officialPlugins)
    ++ (builtins.map (p: {
      name = "${p.name}@${p.marketplace}";
      value = true;
    }) communityPlugins)
  );

  # Shared permissions
  permissionsAttr = {
    allow = [
      "Bash(grep:*)"
      "Read(//Users/hsteinshiromoto/Library/Fonts/**)"
      "Read(//Library/Fonts/**)"
      "Read(~/.config/nix/**)"
      "Read(~/dotfiles/**)"
      "Bash(find:*)"
    ];
    deny = [];
  };

  # Personal account settings (plain JSON, no secrets)
  personalSettingsJson = builtins.toJSON {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    env = {
      ANTHROPIC_MODEL = "claude-opus-4-6";
      ANTHROPIC_SMALL_FAST_MODEL = "claude-haiku-4-5";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS = "1";
    };
    enabledPlugins = enabledPluginsAttr;
    permissions = permissionsAttr;
  };

in
# --- Common config (plugins activation, shared across both paths) ---
{
  # Declarative Claude Code plugin management
  # Installs community marketplace plugins on every home-manager activation.
  # Runs after sops-nix so that ~/.claude/settings.json exists.
  # Network failures are absorbed (|| true) to avoid breaking the rebuild.
  home.activation.installClaudePlugins = config.lib.dag.entryAfter
    (["writeBoundary"] ++ (if usePersonalAccount then [] else ["sops-nix"])) ''
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
# --- Conditional config: corporate vs personal ---
// (if usePersonalAccount then {
  # Personal account: plain file, no SOPS secrets needed
  # Auth handled via `claude login` (browser OAuth)
  home.file.".claude/settings.json" = {
    text = personalSettingsJson;
    force = true;
  };
} else {
  # Corporate account: SOPS secrets + templates (existing behavior)
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
	"$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
		"ANTHROPIC_BASE_URL": "https://litellm.sandbox-01.2bos.ai",
    "ANTHROPIC_AUTH_TOKEN": "${config.sops.placeholder.AWS_BEARER_TOKEN_BEDROCK}",
		"ANTHROPIC_MODEL": "claude-opus-4-6",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-haiku-4-5",
    "DISABLE_PROMPT_CACHING": "1",
		"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
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
})
