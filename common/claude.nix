{ hostname }:

{ config, pkgs, ... }:

let
  # Host-specific sops secret paths (dendritic pattern)
  bedrockSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/bedrock.yaml";
  bedrockSecretPath = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/bedrock";

  # MCP servers configuration (conditional per host)
  # - github: all hosts that import claude.nix
  # - atlassian: mbp2025 only
  # - gitlab: mbp2025 and mbp2023
  mcpServers =
    {
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
      };
			mcp-obsidian = {
				command= "uvx";
				args =  [
					"mcp-obsidian"
				];
				env = {
					OBSIDIAN_API_KEY = "<your_api_key_here>";
					OBSIDIAN_HOST = "<your_obsidian_host>";
					OBSIDIAN_PORT = "<your_obsidian_port>";
				};
			};
    }
    // (if hostname == "mbp2025" then {
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
      };
    } else {})
    // (if builtins.elem hostname ["mbp2025" "mbp2023"] then {
      gitlab = {
        type = "http";
        url = "https://gitlab.2bos.ai/api/v4/mcp";
      };
    } else {});
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
    "pyright-lsp@claude-plugins-official": true,
    "lua-lsp@claude-plugins-official": true
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

  # MCP servers configuration written to ~/.mcp.json (Claude Code user-level MCP config)
  home.file.".mcp.json" = {
    text = builtins.toJSON { mcpServers = mcpServers; };
  };

  # Set environment variable for shell access
  home.sessionVariables = {
    AWS_BEARER_TOKEN_BEDROCK = "$(cat ${bedrockSecretPath} 2>/dev/null || echo '')";
  };
}
