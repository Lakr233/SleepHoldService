#!/bin/zsh

set -e

sudo echo "[*] Fetching SleepHoldService..."

RELEASE_FILE_NAME="SleepHoldService-macOS.tar.gz"
RELEASE_FILE_PATH="/tmp/${RELEASE_FILE_NAME}"
rm -rf "${RELEASE_FILE_PATH}"
curl -s https://api.github.com/repos/Lakr233/SleepHoldService/releases/latest |
    jq -r '.assets[] | select(.name == "'${RELEASE_FILE_NAME}'") | .browser_download_url' |
    xargs -I {} curl -L -o "${RELEASE_FILE_PATH}" {}

if [[ ! -f "${RELEASE_FILE_PATH}" ]]; then
    echo "[-] Failed to download the latest release of SleepHoldService."
    exit 1
fi

mkdir -p /tmp/sleepholdservice.install
pushd /tmp/sleepholdservice.install
tar -xzf "${RELEASE_FILE_PATH}"

echo "[*] Installing SleepHoldService..."
sudo xattr -cr SleepHoldService
sudo codesign --force --deep --sign - SleepHoldService
sudo chmod 755 SleepHoldService
sudo chown root:wheel SleepHoldService
if [[ ! -d "/usr/local/sbin" ]]; then
    sudo mkdir -p /usr/local/sbin
fi
sudo rm -rf /usr/local/sbin/SleepHoldService
sudo cp -f SleepHoldService /usr/local/sbin/SleepHoldService

echo "[*] Installing LaunchDaemon..."
sudo xattr -cr launched.sleepholdservice.plist
sudo rm -rf /Library/LaunchDaemons/launched.sleepholdservice.plist
sudo chmod 644 launched.sleepholdservice.plist
sudo chown root:wheel launched.sleepholdservice.plist
sudo cp -f launched.sleepholdservice.plist /Library/LaunchDaemons/launched.sleepholdservice.plist

echo "[*] Loading LaunchDaemon..."
sudo launchctl unload /Library/LaunchDaemons/launched.sleepholdservice.plist 2>/dev/null 1>/dev/null || true
sudo launchctl load /Library/LaunchDaemons/launched.sleepholdservice.plist

echo "[*] Testing connection..."
sleep 3
TESTING_URL="http://127.0.0.1:8180/ping"
if curl -s "${TESTING_URL}" | grep -q "pong"; then
    echo "[*] connection is OK"
else
    echo "[!] connection failed, please try again later."
    exit 1
fi

popd

sudo rm -rf /tmp/sleepholdservice.install
sudo rm -rf "${RELEASE_FILE_PATH}"

echo "[*] SleepHoldService has been installed successfully."
