{ hostname }:

{ config, ... }:

let
  mcpServers =
    (if builtins.elem hostname ["mbp2023" "mbp2025"] then {
      github = {
        command = "npx";
        args = ["-y" "@modelcontextprotocol/server-github"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "<your-github-pat>";
        };
      };
      mcp-obsidian = {
        command = "uvx";
        args = ["mcp-obsidian"];
        env = {
          OBSIDIAN_API_KEY = "<your_api_key_here>";
          OBSIDIAN_HOST = "<your_obsidian_host>";
          OBSIDIAN_PORT = "<your_obsidian_port>";
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
in
{
  # MCP client configuration
  programs.claude-code = {
    enable = true;
  };

  # MCP server registry
  home.file.".mcp.json" = {
    text = builtins.toJSON { mcpServers = mcpServers; };
  };
}
