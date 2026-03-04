{ hostname, usePersonalAccount ? false }:

{ config, pkgs, lib, ... }:

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

  # Local skills cloned from Git repositories into ~/.claude/skills/
  # Each entry: { name, repo, setupScript }
  #   name        = directory name under ~/.claude/skills/
  #   repo        = HTTPS clone URL
  #   setupScript = shell commands to run after clone/pull (cwd = skill dir)
  localSkills = [
    {
      name = "excalidraw-diagram";
      repo = "https://github.com/coleam00/excalidraw-diagram-skill.git";
      setupScript = "cd references && uv sync && uv run playwright install chromium";
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
      DISABLE_PROMPT_CACHING = "1";
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    };
    enabledPlugins = enabledPluginsAttr;
    permissions = permissionsAttr;
  };

in
# --- Merge common + conditional blocks via the module system ---
lib.mkMerge [
  # --- Common config (plugins activation, shared across both paths) ---
  {
  # Declarative Claude Code plugin management
  # Installs community marketplace plugins on every home-manager activation.
  # Runs after sops-nix so that ~/.claude/settings.json exists.
  # Network failures are absorbed (|| true) to avoid breaking the rebuild.
  # Registers community marketplaces so the CLI knows where to find them.
  # The actual enabledPlugins config is managed declaratively via settings.json,
  # so `plugin install` is not needed (and would fail on the Nix store symlink).
  home.activation.installClaudePlugins = config.lib.dag.entryAfter
    (["writeBoundary"] ++ (if usePersonalAccount then [] else ["sops-nix"])) ''
    CLAUDE_BIN="${config.home.homeDirectory}/.local/state/nix/profiles/profile/bin/claude"
    GIT_BIN="${pkgs.git}/bin/git"
    MARKETPLACE_DIR="${config.home.homeDirectory}/.claude/marketplaces"
    if [ -x "$CLAUDE_BIN" ]; then
      echo "Registering Claude Code community marketplaces..."
      $DRY_RUN_CMD mkdir -p "$MARKETPLACE_DIR"
      ${builtins.concatStringsSep "\n      " (builtins.map (p:
        let marketplaceDir = "$MARKETPLACE_DIR/${p.marketplace}"; in
        ''if [ ! -d "${marketplaceDir}" ]; then
          $DRY_RUN_CMD "$GIT_BIN" clone "https://github.com/${p.repo}.git" "${marketplaceDir}" || true
        else
          $DRY_RUN_CMD "$GIT_BIN" -C "${marketplaceDir}" pull || true
        fi
        $DRY_RUN_CMD "$CLAUDE_BIN" plugin marketplace add "${marketplaceDir}" || true''
      ) communityPlugins)}
    else
      echo "Claude CLI not found at $CLAUDE_BIN, skipping marketplace registration"
    fi
  '';

  # Declarative Claude Code local skill management
  # Clones skill repos into ~/.claude/skills/ and runs setup scripts.
  # Clone-once, pull-later strategy for idempotency.
  # Network failures are absorbed (|| true) to avoid breaking the rebuild.
  home.activation.installClaudeSkills = config.lib.dag.entryAfter
    (["writeBoundary"] ++ (if usePersonalAccount then [] else ["sops-nix"])) ''
    SKILLS_DIR="${config.home.homeDirectory}/.claude/skills"
    GIT_BIN="${pkgs.git}/bin/git"
    PROFILE_BIN="${config.home.homeDirectory}/.local/state/nix/profiles/profile/bin"
    UV_BIN="${pkgs.uv}/bin"
    if [ -d "$SKILLS_DIR" ]; then
      echo "Installing Claude Code local skills..."
      ${builtins.concatStringsSep "\n      " (builtins.map (s:
        let skillDir = "$SKILLS_DIR/${s.name}"; in
        ''if [ ! -d "${skillDir}" ]; then
          $DRY_RUN_CMD "$GIT_BIN" clone "${s.repo}" "${skillDir}" || true
        else
          $DRY_RUN_CMD "$GIT_BIN" -C "${skillDir}" pull || true
        fi
        ( cd "${skillDir}" && export PATH="$UV_BIN:$PROFILE_BIN:$PATH" && $DRY_RUN_CMD ${s.setupScript} ) || true''
      ) localSkills)}
    else
      echo "Skills directory $SKILLS_DIR not found, skipping skill installation"
    fi
  '';
  }
  # --- Conditional config: corporate vs personal ---
  (if usePersonalAccount then {
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
]
