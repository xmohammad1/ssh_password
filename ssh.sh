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
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' $ssh_config

    # Restart the SSH service to apply changes
    sudo systemctl restart sshd

    echo "SSH login with password has been Disabled."  
    read -p "Press Enter To Continue"
}
# Function to show the menu
show_menu() {
    echo "Please choose an option:"
    echo "1) Enable SSH Password Login"
    echo "2) Disable SSh Password Login"
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
        9)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
done
