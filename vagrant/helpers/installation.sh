#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

echo "Updating packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== Checking and installing dependencies ==="

# --- Java (OpenJDK 11) ---
if ! java -version 2>&1 | grep -q "11."; then
  echo "Installing OpenJDK 11..."
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
  sudo apt-get install docker-ce=5:28.5.2-1~ubuntu.22.04~jammy docker-ce-cli=5:28.5.2-1~ubuntu.22.04~jammy containerd.io docker-buildx-plugin docker-compose-plugin
  #curl -fsSL https://get.docker.com -o get-docker.sh
  #sudo sh get-docker.sh
  #rm get-docker.sh
  # Allow vagrant user to run docker without sudo
  sudo usermod -aG docker $USER
else
  echo "Docker already installed."
fi
sudo apt-mark hold docker-ce docker-ce-cli

# --- nodejs ---
if ! command -v node >/dev/null 2>&1; then
  echo "Installing nodeJS..."
  # 2. Add NodeSource repo for Node.js 20.x (LTS)
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

  # 3. Install Node.js (includes npm)
  sudo apt install -y nodejs
else
  echo "NodeJS and npm already installed."
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

ls /home/vagrant/
cd /home/vagrant/
if [ ! -d /home/vagrant/simva ]; then
  git clone https://github.com/e-ucm/simva.git
  chown -R vagrant:vagrant simva
fi
if [ ! -d /home/vagrant/simva-front ]; then
  git clone https://github.com/e-ucm/simva-front.git
  chown -R vagrant:vagrant simva-front
fi
if [ ! -d /home/vagrant/simva-trace-allocator ]; then
  git clone https://github.com/e-ucm/simva-trace-allocator.git
  chown -R vagrant:vagrant simva-trace-allocator
fi
if [ ! -d /home/vagrant/t-mon ]; then
  git clone https://github.com/e-ucm/t-mon.git
  chown -R vagrant:vagrant t-mon
fi
ls /home/vagrant/

# Copy the host gitconfig to vagrant home
if [ -f /home/vagrant/.gitconfig.host ]; then
  cp /home/vagrant/.gitconfig.host /home/vagrant/.gitconfig
fi
# Replace core.editor line with 'code --wait'
if [ -f /home/vagrant/.gitconfig ]; then
  sed -i 's#editor = .*#editor = code --wait#' /home/vagrant/.gitconfig
  chown vagrant:vagrant /home/vagrant/.gitconfig
  chmod 644 /home/vagrant/.gitconfig
fi