#!/bin/bash
ssh_config="/etc/ssh/sshd_config"
enable_ssh_password() {
    # Prompt the user for a password
    read -sp "Enter a root password: " root_password


    # Set the root password
    echo "password you Enter is: $root_password"

    while true; do
        read -p "Do you want to set it?(y/n): " y_n
        case $y_n in
            [Yy]* ) 
                # Set the root password
                echo "root:$root_password" | sudo chpasswd
                break
                ;;
            [Nn]* ) 
                return 0
                ;;
            * ) 
                echo "Please answer yes or no."
                ;;
        esac
    done

    # Enable root login with password in SSH configuration
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' $ssh_config
    # Restart the SSH service to apply changes
    sudo systemctl restart sshd
    echo "Root password has been set and SSH login with password has been Enabled."
    read -p "Press Enter To Continue"
}
disable_ssh_password() {
    ROOT_SSH_DIR="/root/.ssh"
    ROOT_AUTH_KEYS="$ROOT_SSH_DIR/authorized_keys"

    # Ensure the /root/.ssh directory exists with proper permissions
    if [ ! -d "$ROOT_SSH_DIR" ]; then
        echo "/root/.ssh directory not found. Creating it..."
        sudo mkdir -p "$ROOT_SSH_DIR"
        sudo chmod 700 "$ROOT_SSH_DIR"
    fi

    # Check if the authorized_keys file exists and contains at least one SSH key.
    # This regex checks for keys that typically start with ssh-rsa, ssh-ed25519, etc.
    if [ ! -f "$ROOT_AUTH_KEYS" ] || ! sudo grep -qE "^(ssh-(rsa|dss)|ecdsa-|ssh-ed25519)" "$ROOT_AUTH_KEYS"; then
        echo "No SSH key found in /root/.ssh/authorized_keys."
        echo "Please paste your public SSH key (e.g., starting with ssh-rsa or ssh-ed25519):"
        read -r SSH_KEY
        if [ -z "$SSH_KEY" ]; then
            echo "No SSH key entered. Aborting disabling password login."
            return 1
        fi
        echo "$SSH_KEY" | sudo tee -a "$ROOT_AUTH_KEYS" > /dev/null
        sudo chmod 600 "$ROOT_AUTH_KEYS"
        echo "SSH key added for root."
    fi    
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' $ssh_config

    # Restart the SSH service to apply changes
    sudo systemctl restart sshd

    echo "SSH login with password has been Disabled."  
    read -p "Press Enter To Continue"
}
remove_ssh_key() {
    ROOT_SSH_DIR="/root/.ssh"
    ROOT_AUTH_KEYS="$ROOT_SSH_DIR/authorized_keys"

    # Check if the authorized_keys file exists
    if [ ! -f "$ROOT_AUTH_KEYS" ]; then
        echo "No authorized_keys file found in /root/.ssh. Nothing to remove."
        read -p "Press Enter to continue..."
        return
    fi

    echo "The following SSH keys exist in /root/.ssh/authorized_keys:"
    sudo cat "$ROOT_AUTH_KEYS"
    echo

    while true; do
        read -p "Do you want to remove all SSH keys? (y/n): " answer
        case "$answer" in
            [Yy]* )
                # Remove the authorized_keys file
                sudo rm -f "$ROOT_AUTH_KEYS"
                echo "SSH keys removed from /root/.ssh/authorized_keys."
                break
                ;;
            [Nn]* )
                echo "Aborting removal of SSH keys."
                break
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
    read -p "Press Enter to continue..."
}
enable_root_login() {

    CONFIG_FILE="/etc/cloud/cloud.cfg"
    SEARCH_STRING="disable_root: true"
    REPLACE_STRING="disable_root: false"

    # Check if the file exists
    if [[ -f "$CONFIG_FILE" ]]; then
        # Replace the 'disable_root: true' with 'disable_root: false'
        sudo sed -i "s/$SEARCH_STRING/$REPLACE_STRING/" "$CONFIG_FILE"

        echo "Updated $CONFIG_FILE to enable root user."
        sudo cloud-init clean -r
        echo "cloud-init has been cleaned and re-run."
    else
        echo "Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    read -p "Press Enter To Continue"
}
set_new_ssh_key() {
    ROOT_SSH_DIR="/root/.ssh"
    ROOT_AUTH_KEYS="$ROOT_SSH_DIR/authorized_keys"

    # Ensure the /root/.ssh directory exists with proper permissions
    if [ ! -d "$ROOT_SSH_DIR" ]; then
        echo "/root/.ssh directory not found. Creating it..."
        sudo mkdir -p "$ROOT_SSH_DIR"
        sudo chmod 700 "$ROOT_SSH_DIR"
    fi

    echo "Please paste your new public SSH key (e.g., starting with ssh-rsa or ssh-ed25519):"
    read -r new_key
    if [ -z "$new_key" ]; then
        echo "No SSH key entered. Aborting."
        read -p "Press Enter to continue..."
        return 1
    fi

    echo "$new_key" | sudo tee -a "$ROOT_AUTH_KEYS" > /dev/null
    sudo chmod 600 "$ROOT_AUTH_KEYS"
    echo "New SSH key added to /root/.ssh/authorized_keys."
    read -p "Press Enter to continue..."
}
enable_ipv6_gcore() {
# Backup existing netplan config
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak

# Auto-detect primary interface
INTERFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
[ -z "$INTERFACE" ] && INTERFACE=enp3s0

# Detect all MAC addresses for the interface
declare -a MAC_ADDRESSES=($(ip link show $INTERFACE 2>/dev/null | awk '/link\/ether/ {print $2}'))

# Auto-select first MAC if multiple found
if [ ${#MAC_ADDRESSES[@]} -gt 1 ]; then
    echo "Multiple MAC addresses detected. Using first MAC: ${MAC_ADDRESSES[0]}"
    MAC_ADDRESS=${MAC_ADDRESSES[0]}
elif [ ${#MAC_ADDRESSES[@]} -eq 1 ]; then
    MAC_ADDRESS=${MAC_ADDRESSES[0]}
else
    echo "No MAC address detected for $INTERFACE"
    read -p "Enter MAC address manually (format: aa:bb:cc:dd:ee:ff): " MAC_ADDRESS
fi

# Validate MAC format
if ! [[ "$MAC_ADDRESS" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
    echo "Error: Invalid MAC address format"
    exit 1
fi

# Get IPv6 address from user
read -p "Enter IPv6 address with CIDR (e.g., 2a03:90c0:92:1::366/64): " IPV6_ADDRESS
if ! [[ "$IPV6_ADDRESS" =~ ^[0-9a-fA-F:]+/[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IPv6 format"
    exit 1
fi

# Auto-detect IPv6 gateway
IPV6_GATEWAY=$(ip -6 route show default | awk '/default/{print $3}' | head -n1)
if [ -z "$IPV6_GATEWAY" ]; then
    echo "Warning: No IPv6 gateway detected automatically!"
    read -p "Enter IPv6 gateway manually: " IPV6_GATEWAY
fi

# Generate netplan config
cat << EOF | sudo tee /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        $INTERFACE:
            accept-ra: true
            dhcp4: true
            dhcp6: false
            match:
                macaddress: $MAC_ADDRESS
            mtu: 1500
            set-name: $INTERFACE
            addresses:
                - $IPV6_ADDRESS
            routes:
                - to: ::/0
                  via: $IPV6_GATEWAY
EOF

# Apply configuration
sudo netplan generate
sudo netplan apply

# Verification with failure detection
echo -e "\nVerification:"
ip -6 addr show $INTERFACE
ip -6 route show default

echo -e "\nTesting IPv6 connectivity..."
ping6 -c 4 2001:4860:4860::8888

if [ $? -ne 0 ]; then
    echo -e "\n\033[31mIPv6 connectivity failed! Possible causes:"
    echo "1. Incorrect MAC address selection"
    echo "2. Wrong IPv6 gateway"
    echo "3. Provider-side configuration issues"
    echo -e "\033[0mCheck these and re-run the script if needed."
else
    echo -e "\n\033[32mIPv6 configuration successful!\033[0m"
fi
}
# Function to show the menu
show_menu() {
    echo "Please choose an option:"
    echo "1) Enable SSH Password Login"
    echo "2) Disable Password Login "
    echo "3) Set a New SSH Key"
    echo "4) Remove Existing SSH Key"
    echo "5) Enable Root Login"
    echo "6) Enable IPv6 on Gcore"
    echo "9) Exit"
}
# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Enter choice [1-5]: " choice
    case $choice in
        1)
            enable_ssh_password
            ;;
        2)
            disable_ssh_password
            ;;
        3)
            set_new_ssh_key
            ;;
        4)
            remove_ssh_key
            ;;
        5)
            enable_root_login
            ;;
        6)
            enable_ipv6_gcore
            ;;
        9)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
done
