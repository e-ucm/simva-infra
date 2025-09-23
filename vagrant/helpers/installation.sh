#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

echo "Updating packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

set -e

echo "=== Checking and installing dependencies ==="

# --- Java (OpenJDK 11) ---
if ! java -version 2>&1 | grep -q "11."; then
  echo "Installing OpenJDK 11..."
  sudo apt-get update -y
  sudo apt-get install -y openjdk-11-jdk gnupg2 ca-certificates lsb-release software-properties-common
else
  echo "OpenJDK 11 already installed."
fi

# --- jq ---
if ! command -v jq >/dev/null 2>&1; then
  echo "Installing jq..."
  sudo apt-get install -y jq
else
  echo "jq already installed."
fi

# --- curl ---
if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  sudo apt-get install -y curl
else
  echo "curl already installed."
fi

# --- sha256sum (usually in coreutils) ---
if ! command -v sha256sum >/dev/null 2>&1; then
  echo "Installing coreutils (sha256sum)..."
  sudo apt-get install -y coreutils
else
  echo "sha256sum already available."
fi

# --- htpasswd (usually in apache2-utils) ---
if ! command -v htpasswd >/dev/null 2>&1; then
  echo "Installing apache2-utils (htpasswd)..."
  sudo apt-get install -y apache2-utils
else
  echo "apache2-utils already available."
fi


# --- Docker ---
if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker CE..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  rm get-docker.sh
  # Allow vagrant user to run docker without sudo
  sudo usermod -aG docker $USER
else
  echo "Docker already installed."
fi

# --- nodejs ---
if ! command -v node >/dev/null 2>&1; then
  echo "Installing nodeJS..."
  sudo apt install nodejs
else
  echo "NodeJS already installed."
fi

# --- NPM ---
if ! command -v npm >/dev/null 2>&1; then
  echo "Installing NPM..."
  sudo apt install npm
else
  echo "NPM already installed."
fi

# --- mkcert installation ---
if ! command -v mkcert >/dev/null 2>&1; then
  echo "🔧 Installing mkcert..."

  # Ensure dependencies
  sudo apt-get update -qq
  sudo apt-get install -y libnss3-tools curl wget

  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR"

  # Try official endpoint first
  set +e
  if ! curl -fsSLo mkcert "https://dl.filippo.io/mkcert/latest?for=linux/amd64"; then
    set -e
    echo "⚠️  dl.filippo.io unreachable, falling back to GitHub releases..."
    LATEST=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest \
      | grep "browser_download_url.*linux-amd64" \
      | cut -d '"' -f 4)
    wget -qO mkcert "$LATEST"
  fi

  chmod +x mkcert
  sudo mv mkcert /usr/local/bin/mkcert

  # Install root CA into trust store
  mkcert -install

  echo "✅ mkcert installed successfully!"
else
  echo "ℹ️ mkcert already installed: $(mkcert --version)"
fi


# --- dos2unix ---
if ! command -v dos2unix >/dev/null 2>&1; then
  echo "Installing dos2unix..."
  sudo apt-get install -y dos2unix
else
  echo "dos2unix already installed."
fi

# --- Verification ---
echo
echo "=== Installed versions ==="
echo "java :"
java -version || true

echo "jq : $(jq --version || true)"

echo "docker : $(docker --version || true)"

echo "mkcert : $(mkcert -version || true)"

echo "sha256sum : $(sha256sum --version || true)"

echo "dos2unix : $(dos2unix --version || true)"

echo "node : $(node -v || true)"

echo "npm : $(npm -v|| true)"