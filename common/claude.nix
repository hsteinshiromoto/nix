{ config, pkgs, ... }:

{
  # SOPS secrets configuration for Claude Code
  sops = {
    secrets = {
      AWS_BEARER_TOKEN_BEDROCK = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/bedrock.yaml";
        path = "${config.home.homeDirectory}/.config/sops/secrets/bedrock";
      };
    };

    # Use sops templates to generate Claude settings.json with secrets
    templates."claude/settings.json" = {
      content = ''
{
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "ap-southeast-2",
    "AWS_PROFILE": "sandbox",
    "ANTHROPIC_MODEL": "arn:aws:bedrock:ap-southeast-2:058264223017:inference-profile/global.anthropic.claude-opus-4-5-20251101-v1:0",
    "ANTHROPIC_SMALL_FAST_MODEL": "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-haiku-4-5-20251001-v1:0",
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

  # Set environment variable for shell access
  home.sessionVariables = {
    AWS_BEARER_TOKEN_BEDROCK = "$(cat ${config.home.homeDirectory}/.config/sops/secrets/bedrock 2>/dev/null || echo '')";
  };
}
