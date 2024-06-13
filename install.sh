SYSTEMD_DIR="/etc/systemd/system"
SBIN_DIR="/usr/sbin"

# Ensure the script is run with sudo or root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

# Check if the 'iptables' command exists
if ! command -v file &> /dev/null; then
    echo "Error: 'iptables' command not found"
    exit 1
fi

echo "Copying files..."
cp ./port_manager.service "$SYSTEMD_DIR/"
cp ./port_manager.sh "$SBIN_DIR/"

echo "Set +x privileges"
chmod +x "$SBIN_DIR/port_manager.sh"

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling and starting Port Manager"
systemctl enable port_manager
systemctl start port_manager

echo "Installation complete."
