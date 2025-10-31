#!/usr/bin/env bash
# nvim-remote.sh - Connect to remote Neovim server via SSH tunnel
#
# Usage: nvim-remote.sh [SERVER_NAME_OR_IP] [PORT]
# Defaults: SERVER_NAME_OR_IP=servidor, PORT=9000
#
# SERVER_NAME_OR_IP can be:
#   - A Tailscale hostname (e.g., "servidor")
#   - An IP address

set -e

# Configuration
SERVER_NAME_OR_IP="${1:-servidor}"
PORT="${2:-9000}"
TUNNEL_CHECK_RETRIES=10
TUNNEL_CHECK_DELAY=0.5

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

# Find tailscale command
find_tailscale() {
    if command -v tailscale &> /dev/null; then
        echo "tailscale"
    elif [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
        echo "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    else
        return 1
    fi
}

# Resolve server address (supports Tailscale hostnames)
resolve_server() {
    local input="$1"

    # If it's already an IP address, use it directly
    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$input"
        return 0
    fi

    # Try to find tailscale command
    local tailscale_cmd=$(find_tailscale)

    if [ -n "$tailscale_cmd" ]; then
        log_info "Resolving Tailscale hostname: $input"

        # Try using tailscale ip command (most reliable)
        local ts_ip=$($tailscale_cmd ip -4 "$input" 2>/dev/null | head -1)
        if [ -n "$ts_ip" ] && [[ "$ts_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            log_info "Resolved to: $ts_ip"
            echo "$ts_ip"
            return 0
        fi

        # Fallback: try parsing tailscale status
        ts_ip=$($tailscale_cmd status 2>/dev/null | grep -w "$input" | awk '{print $1}' | head -1)
        if [ -n "$ts_ip" ] && [[ "$ts_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            log_info "Resolved to: $ts_ip"
            echo "$ts_ip"
            return 0
        fi
    fi

    # If all resolution fails, return error
    log_error "Failed to resolve hostname: $input"
    log_error "Tailscale CLI not found or hostname not in network"
    return 1
}

# Check if SSH tunnel is already running
is_tunnel_running() {
    pgrep -f "ssh -L ${PORT}:127.0.0.1:${PORT} ${RESOLVED_SERVER}" > /dev/null
}

# Kill existing SSH tunnel
kill_tunnel() {
    if is_tunnel_running; then
        log_info "Killing SSH tunnel..."
        pkill -f "ssh -L ${PORT}:127.0.0.1:${PORT} ${RESOLVED_SERVER}" || true
        sleep 1
    fi
}

# Start SSH tunnel
start_tunnel() {
    log_info "Starting SSH tunnel to ${RESOLVED_SERVER}:${PORT}..."
    ssh -L ${PORT}:127.0.0.1:${PORT} ${RESOLVED_SERVER} -N -f

    # Wait for tunnel to be ready
    for i in $(seq 1 ${TUNNEL_CHECK_RETRIES}); do
        if nc -z 127.0.0.1 ${PORT} 2>/dev/null; then
            log_info "SSH tunnel established successfully"
            return 0
        fi
        sleep ${TUNNEL_CHECK_DELAY}
    done

    log_error "Failed to establish SSH tunnel after ${TUNNEL_CHECK_RETRIES} attempts"
    return 1
}

# Connect to Neovim
connect_nvim() {
    log_info "Connecting to Neovim server..."
    nvim --server 127.0.0.1:${PORT} --remote-ui
}

# Cleanup function
cleanup() {
    log_info "Neovim exited, cleaning up..."
    kill_tunnel
    log_info "Done"
}

# Main execution
main() {
    # Resolve server address
    RESOLVED_SERVER=$(resolve_server "$SERVER_NAME_OR_IP")

    if [ -z "$RESOLVED_SERVER" ]; then
        log_error "Failed to resolve server address: $SERVER_NAME_OR_IP"
        exit 1
    fi

    # Set trap to cleanup on exit
    trap cleanup EXIT INT TERM

    # Kill any existing tunnel
    if is_tunnel_running; then
        log_warning "Existing SSH tunnel found, killing it..."
        kill_tunnel
    fi

    # Start new tunnel
    if ! start_tunnel; then
        log_error "Failed to start SSH tunnel"
        exit 1
    fi

    # Connect to Neovim
    connect_nvim
}

# Run main function
main "$@"
