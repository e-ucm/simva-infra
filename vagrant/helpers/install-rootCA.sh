#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Default values
ROOTCA_PATH="${ROOTCA_PATH:-}"  # Use $ROOTCA_PATH environment variable if set
REMOVE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--certPath)
            ROOTCA_PATH="$2"
            shift 2
            ;;
        -r|--remove)
            REMOVE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Example usage
echo "Cert path: $ROOTCA_PATH"
echo "Remove flag: $REMOVE"

echo "🔑 Installing mkcert Root CA from $ROOTCA_PATH"

FINGERPRINT=$(openssl x509 -in "$ROOTCA_PATH" -noout -sha1 -fingerprint | cut -d'=' -f2 | tr -d ':')

# Linux functions
install_linux() {
    local dest="/usr/local/share/ca-certificates/simva-root-ca.crt"
    if [ ! -f "$dest" ]; then
        sudo cp "$ROOTCA_PATH" "$dest"
        sudo update-ca-certificates
        echo "✅ Installed into /usr/local/share/ca-certificates"
    else
        echo "✅ RootCA already present in /usr/local/share/ca-certificates."
    fi
}

remove_linux() {
    local dest="/usr/local/share/ca-certificates/simva-root-ca.crt"
    if [ -f "$dest" ]; then
        sudo rm "$dest"
        sudo update-ca-certificates --fresh
        echo "✅ RootCA removed from /usr/local/share/ca-certificates"
    else
        echo "ℹ️ RootCA not found in /usr/local/share/ca-certificates"
    fi
}

# macOS functions
install_macos() {
    if security find-certificate -a -Z -p /Library/Keychains/System.keychain | grep -qi "$FINGERPRINT"; then
        echo "✅ RootCA already in macOS System keychain."
    else
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$ROOTCA_PATH"
        echo "✅ Installed into macOS System keychain"
    fi
}

remove_macos() {
    if security find-certificate -a -Z -p /Library/Keychains/System.keychain | grep -qi "$FINGERPRINT"; then
        sudo security delete-certificate -Z "$FINGERPRINT" /Library/Keychains/System.keychain
        echo "✅ RootCA removed from macOS System keychain"
    else
        echo "ℹ️ RootCA not found in macOS System keychain"
    fi
}

# Main logic
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🪟 Linux detected"
    if $REMOVE; then
        remove_linux
    else
        install_linux
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🪟 macOS detected"
    if $REMOVE; then
        remove_macos
    else
        install_macos
    fi
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi