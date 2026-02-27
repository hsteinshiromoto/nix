{ hostname }:

{ config, ... }:

let
  hostsWithSecretBackedMcp = ["mbp2023"];
  useSecretBackedMcp = builtins.elem hostname hostsWithSecretBackedMcp;

  githubSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2023/github.yaml";
  obsidianSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/obsidian.yaml";
  readwiseSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/readwise.yaml";

  githubToken = config.sops.placeholder.GITHUB_PERSONAL_ACCESS_TOKEN;
  obsidianApiKey = config.sops.placeholder.OBSIDIAN_API_KEY;
  obsidianHost = config.sops.placeholder.OBSIDIAN_HOST;
  obsidianPort = config.sops.placeholder.OBSIDIAN_PORT;
  readwiseToken = config.sops.placeholder.READWISE_TOKEN;

  mcpServers =
    (if useSecretBackedMcp then {
      github = {
        command = "npx";
        args = ["-y" "@modelcontextprotocol/server-github"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = githubToken;
        };
      };
      mcp-obsidian = {
        command = "uvx";
        args = ["mcp-obsidian"];
        env = {
          OBSIDIAN_API_KEY = obsidianApiKey;
          OBSIDIAN_HOST = obsidianHost;
          OBSIDIAN_PORT = obsidianPort;
        };
      };
      "readwise-reader" = {
        command = "node";
        args = ["/path/to/your/reader_readwise_mcp/dist/index.js"];
        env = {
          READWISE_TOKEN = readwiseToken;
        };
      };
    } else {})
    // (if hostname == "mbp2025" then {
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
      };
    } else {})
    // (if builtins.elem hostname ["mbp2023" "mbp2025"] then {
      gitlab = {
        type = "http";
        url = "https://gitlab.2bos.ai/api/v4/mcp";
      };
    } else {})
    // (if hostname == "mbp2023" then {
      hledger-mcp = {
        command = "npx";
        args = ["-y" "@iiatlas/hledger-mcp" "${config.home.homeDirectory}/hledger/main.journal"];
      };
    } else {})
    // (if hostname == "servidor" then {
      hledger-mcp = {
        command = "npx";
        args = ["-y" "@iiatlas/hledger-mcp" "--read-only" "${config.home.homeDirectory}/hledger/master.journal"];
      };
    } else {});

  mcpJsonContent = builtins.toJSON { mcpServers = mcpServers; };
in
{
  # MCP client configuration
  programs.claude-code = {
    enable = true;
  };
}
// (if useSecretBackedMcp then {
  sops = {
    secrets = {
      GITHUB_PERSONAL_ACCESS_TOKEN = {
        sopsFile = githubSopsFile;
        key = "mcp_token";
      };
      OBSIDIAN_API_KEY.sopsFile = obsidianSopsFile;
      OBSIDIAN_HOST.sopsFile = obsidianSopsFile;
      OBSIDIAN_PORT.sopsFile = obsidianSopsFile;
      READWISE_TOKEN = {
        sopsFile = readwiseSopsFile;
        key = "READWISE_API_KEY";
      };
    };

    templates."mcp.json" = {
      content = mcpJsonContent;
      path = "${config.home.homeDirectory}/.mcp.json";
      mode = "0600";
    };
  };
} else {
  home.file.".mcp.json" = {
    text = mcpJsonContent;
  };
})
