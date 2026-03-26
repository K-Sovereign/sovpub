#!/usr/bin/env bash
# setup.sh — Install Docker, Dockhand, UFW and update all packages
# Tested on Ubuntu/Debian. Must be run as root or with sudo.

set -euo pipefail

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

require_root() {
  [[ $EUID -eq 0 ]] || error "This script must be run as root (or with sudo)."
}

# ─────────────────────────────────────────────
# 1. Update & upgrade all packages
# ─────────────────────────────────────────────
update_packages() {
  info "Updating package lists and upgrading installed packages…"
  apt update -y
  apt upgrade -y
  apt autoremove -y
  info "System packages are up to date."
}

# ─────────────────────────────────────────────
# 2. Install Docker (official install script)
# ─────────────────────────────────────────────
install_docker() {
  if command -v docker &>/dev/null; then
    warn "Docker is already installed ($(docker --version)). Skipping."
    return
  fi

  info "Installing Docker…"
  apt install -y ca-certificates curl gnupg lsb-release

  # Add Docker's official GPG key
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the Docker apt repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt update -y
  apt install -y docker-ce docker-ce-cli containerd.io \
                     docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker
  info "Docker installed: $(docker --version)"
}

# ─────────────────────────────────────────────
# 3. Install Dockhand (runs as a Docker container)
# ─────────────────────────────────────────────
install_dockhand() {
  if docker ps -a --format '{{.Names}}' | grep -q "^dockhand$"; then
    warn "Dockhand container already exists. Skipping."
    return
  fi

  info "Installing Dockhand…"

  COMPOSE_DIR="/opt/dockhand"
  mkdir -p "$COMPOSE_DIR"

  cat > "${COMPOSE_DIR}/docker-compose.yml" << 'COMPOSE'
services:
  dockhand:
    image: fnsys/dockhand:latest
    container_name: dockhand
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - dockhand_data:/app/data

volumes:
  dockhand_data:
    driver: local
COMPOSE

  docker compose -f "${COMPOSE_DIR}/docker-compose.yml" up -d

  info "Dockhand is running at http://$(hostname -I | awk '{print $1}'):3000"
}

# ─────────────────────────────────────────────
# 4. Install & enable UFW
# ─────────────────────────────────────────────
install_ufw() {
  if command -v ufw &>/dev/null; then
    warn "UFW is already installed. Skipping package install."
  else
    info "Installing UFW…"
    apt install -y ufw
  fi

  # Safe defaults: deny in, allow out, permit SSH so we don't lock ourselves out
  info "Configuring UFW defaults…"
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH

  ufw --force enable
  ufw status verbose
  info "UFW installed and enabled."
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
  require_root
  update_packages
  install_docker
  install_dockhand
  install_ufw
  info "✅  All done! Docker, Dockhand, and UFW are installed and configured."
}

main "$@"
