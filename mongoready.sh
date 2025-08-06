#!/usr/bin/env bash
set -e

clear
echo -e "\e[1;36m"
cat << "EOF"
    __  ___                           ____                 __     
   /  |/  /___  ____  ____ _____     / __ \___  ____ _____/ /_  __
  / /|_/ / __ \/ __ \/ __ `/ __ \   / /_/ / _ \/ __ `/ __  / / / /
 / /  / / /_/ / / / / /_/ / /_/ /  / _, _/  __/ /_/ / /_/ / /_/ / 
/_/  /_/\____/_/ /_/\__, /\____/  /_/ |_|\___/\__,_/\__,_/\__, /  
                   /____/                                /____/   

EOF
echo -e "\e[0m"
echo -e "             🔧 Open-source MongoDB + Mongoose Installer"
echo -e "             🌐 Repo: \e[4;34mhttps://github.com/BlackHatDevX/MongoReady\e[0m"
echo ""
sleep 2

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID; VER=$VERSION_ID
else
  echo "Unsupported OS"; exit 1
fi

echo "Detected OS: $OS $VER"

install_mongodb_ubuntu(){
  sudo apt-get update
  sudo apt-get install -y gnupg curl
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
  echo "deb [ arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/8.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org
}

install_mongodb_rhel(){
  sudo yum install -y \
    https://repo.mongodb.org/yum/redhat/$VER/mongodb-org/8.0/x86_64/RPMS/mongodb-org-server-8.0*.rpm \
    mongodb-org-shell mongodb-org-tools mongodb-org-mongosh
  sudo yum install -y mongodb-org
}

install_mongo(){
  case "$OS" in
    ubuntu|debian)
      install_mongodb_ubuntu;;
    rhel|centos|rocky|almalinux)
      install_mongodb_rhel;;
    *)
      echo "Unsupported distro: $OS"; exit 1;;
  esac
}

echo "Installing MongoDB 8.0..."
install_mongo


if lsof -Pi :27017 -sTCP:LISTEN >/dev/null; then
  echo "Port 27017 already in use. Attempting to kill conflicting process..."
  sudo fuser -k 27017/tcp || echo "Could not kill process on port 27017"
fi


echo "Fixing MongoDB log directory permissions..."
if [ ! -d /var/log/mongodb ]; then
  echo "Creating /var/log/mongodb"
  sudo mkdir -p /var/log/mongodb
fi
sudo chown -R mongodb:mongodb /var/log/mongodb 2>/dev/null || sudo chown -R root:root /var/log/mongodb
sudo chmod 755 /var/log/mongodb

# Start MongoDB
echo "Enabling and restarting mongod service..."
sudo systemctl enable mongod
sudo systemctl restart mongod

sleep 3
if ! systemctl is-active --quiet mongod; then
  echo "MongoDB failed to start. Showing logs:"
  sudo journalctl -u mongod --no-pager | tail -n 50
  exit 1
fi

if ! systemctl is-active --quiet mongod; then
  echo "MongoDB failed to start. Showing logs:"
  sudo journalctl -u mongod --no-pager | tail -n 50
  exit 1
fi
echo "MongoDB is running on port 27017."

if [ ! -d /data/db ]; then
  echo "Ensuring /data/db exists..."
  sudo mkdir -p /data/db
  sudo chown -R $USER /data/db
  sudo chmod -R 755 /data/db
fi

echo "MongoDB installed and running."


if ! command -v node >/dev/null; then
  echo "Node.js not found. Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs \
    || curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash - && sudo yum install -y nodejs
fi

echo "Node.js version: $(node -v), npm version: $(npm -v)"

echo "Installing latest mongoose via npm..."
npm install -g mongoose@latest

echo "If you're in a project directory, run: npm install mongoose"

echo "Verifying mongoose installation:"
mongoose --version || echo "No mongoose CLI; verify via npm list mongoose"

echo "✅ Installation complete."

echo "== Applying additional patches in script =="

if ! apt-key list | grep -q 'MongoDB 8.0 Release Signing Key'; then
  echo "Adding MongoDB GPG public key..."
  curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
fi

if dpkg -l | grep -qw '^ii .*mongodb\b'; then
  echo "Removing legacy Ubuntu mongodb package to avoid conflict..."
  sudo apt-get remove -y mongodb mongodb-server mongodb-server-core mongodb-clients || true
fi


DBDIR=$(grep '^ *dbPath:' /etc/mongod.conf | awk '{print $2}') || DBDIR="/var/lib/mongodb"
echo "Ensuring data directory ${DBDIR} exists with correct permissions..."
sudo mkdir -p "$DBDIR"
sudo chown -R mongodb:mongodb "$DBDIR"
if [ -f "$DBDIR/mongod.lock" ]; then
  echo "Removing stale lock file..."
  sudo rm -f "$DBDIR/mongod.lock"
fi


SOCK="/tmp/mongodb-27017.sock"
if [ -e "$SOCK" ]; then
  echo "Ensuring socket file ownership..."
  sudo chown mongodb:mongodb "$SOCK" || true
fi


sudo mkdir -p /var/log/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb
sudo chmod 755 /var/log/mongodb


if command -v getenforce >/dev/null && [ "$(getenforce)" = "Enforcing" ]; then
  echo "⚠ SELinux is enforcing — custom data/log directories may need proper SELinux context (use semanage or chcon)"
fi


CURRENT_UL=$(ulimit -n)
if [ "$CURRENT_UL" -lt 64000 ]; then
  echo "⚠ ulimit -n is $CURRENT_UL, recommended >= 64000 for MongoDB. Consider updating limits.conf."
fi


sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl restart mongod
sleep 3
if ! systemctl is-active --quiet mongod; then
  echo "After patches, MongoDB still failed to start. Logs:"
  sudo journalctl -u mongod --no-pager | tail -n 100
  exit 1
fi
echo "✔ MongoDB started successfully after applying patches."
