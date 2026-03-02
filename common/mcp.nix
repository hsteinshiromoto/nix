{ hostname }:

{ config, ... }:

let
  hostsWithSecretBackedMcp = ["mbp2023" "mbp2025"];
  useSecretBackedMcp = builtins.elem hostname hostsWithSecretBackedMcp;
  useGithubAndReadwise = hostname == "mbp2023";
  useObsidian = useSecretBackedMcp;

  githubSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/github.yaml";
  obsidianSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/obsidian.yaml";
  readwiseSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/${hostname}/readwise.yaml";

  githubToken = config.sops.placeholder.GITHUB_PERSONAL_ACCESS_TOKEN;
  obsidianApiKey = config.sops.placeholder.OBSIDIAN_API_KEY;
  obsidianHost = config.sops.placeholder.OBSIDIAN_HOST;
  obsidianPort = config.sops.placeholder.OBSIDIAN_PORT;
  readwiseToken = config.sops.placeholder.READWISE_TOKEN;

  mcpServers =
    # GitHub and Readwise MCPs: mbp2023 only
    (if useGithubAndReadwise then {
      github = {
        command = "npx";
        args = ["-y" "@modelcontextprotocol/server-github"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = githubToken;
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
    # Obsidian MCP: mbp2023 and mbp2025
    // (if useObsidian then {
      mcp-obsidian = {
        command = "uvx";
        args = ["mcp-obsidian"];
        env = {
          OBSIDIAN_API_KEY = obsidianApiKey;
          OBSIDIAN_HOST = obsidianHost;
          OBSIDIAN_PORT = obsidianPort;
        };
      };
    } else {})
    // (if hostname == "mbp2025" then {
      atlassian = {
        type = "http";
        url = "https://mcp.atlassian.com/v1/mcp";
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
{}
// (if useSecretBackedMcp then {
  sops = {
    secrets =
      # GitHub + Readwise secrets: mbp2023 only
      (if useGithubAndReadwise then {
        GITHUB_PERSONAL_ACCESS_TOKEN = {
          sopsFile = githubSopsFile;
          key = "mcp_token";
        };
        READWISE_TOKEN = {
          sopsFile = readwiseSopsFile;
          key = "READWISE_API_KEY";
        };
      } else {})
      # Obsidian secrets: all hostsWithSecretBackedMcp hosts
      // (if useObsidian then {
        OBSIDIAN_API_KEY.sopsFile = obsidianSopsFile;
        OBSIDIAN_HOST.sopsFile = obsidianSopsFile;
        OBSIDIAN_PORT.sopsFile = obsidianSopsFile;
      } else {});

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
