SYSTEMD_DIR="/etc/systemd/system"
SBIN_DIR="/usr/sbin"

# Ensure the script is run with sudo or root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

# Check if the 'iptables' command exists
if ! command -v iptables &> /dev/null; then
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


# Function to display the correct way to set the INPUT policy to DROP and add specific rules
display_instructions() {
    echo "To correctly configure your iptables rules, follow the instructions below:"
    echo ""
    echo "Set the default policy for the INPUT chain to DROP:"
    echo "iptables -P INPUT DROP"
    echo ""
    echo "Add necessary rules:"
    echo "iptables -A INPUT -i lo -j ACCEPT"
    echo "iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT"
    echo ""
}

# Check the current policy of the INPUT chain
current_policy=$(iptables -L INPUT -v -n | grep '^Chain INPUT' | awk '{ print $4 }')

# Check if the INPUT chain policy is ACCEPT
if [[ "$current_policy" == "ACCEPT" ]]; then
    echo "Warning: The INPUT chain policy is currently set to ACCEPT. This allows all incoming traffic."
    display_instructions
# else
#     echo "The INPUT chain policy is correctly set to DROP."
fi
