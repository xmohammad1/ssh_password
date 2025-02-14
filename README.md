# SSH Management Script

A Bash script for managing SSH access configurations on Linux systems. This tool provides a simple interface to manage root login settings, SSH password authentication, and SSH key management.

## Features

- Enable/disable SSH password authentication
- Configure root login settings
- Manage SSH keys (add/remove)
- Enable root user access in cloud environments
- Interactive menu-driven interface

## Quick Start

Run the script directly using curl:

```bash
bash <(curl -LS https://raw.githubusercontent.com/xmohammad1/ssh_password/main/ssh.sh)
```

**Note:** Replace `USERNAME` and `TOKEN` with your GitHub credentials.

## Menu Options

1. **Enable SSH Password Login**
   - Sets root password
   - Enables password-based SSH authentication
   - Modifies SSH daemon configuration

2. **Disable Password Login**
   - Switches to key-based authentication
   - Automatically creates `.ssh` directory if needed
   - Prompts for SSH public key if none exists
   - Configures SSH daemon for key-only access

3. **Enable Root Login**
   - Modifies cloud-init configuration
   - Enables root user access
   - Resets cloud-init settings

4. **Set a New SSH Key**
   - Adds new SSH public key to authorized_keys
   - Creates required directories with proper permissions
   - Validates key format

5. **Remove Existing SSH Key**
   - Displays current SSH keys
   - Option to remove all authorized keys
   - Confirmation required before deletion

## System Requirements

- Linux-based operating system
- Root/sudo privileges
- `systemctl` for service management
- `cloud-init` (for cloud environment features)

## File Locations

- SSH Configuration: `/etc/ssh/sshd_config`
- Cloud Configuration: `/etc/cloud/cloud.cfg`
- SSH Keys Directory: `/root/.ssh/`
- Authorized Keys: `/root/.ssh/authorized_keys`

## Security Considerations

- Always maintain at least one working SSH key before disabling password authentication
- Keep your SSH private keys secure
- Regularly rotate SSH keys and passwords
- Consider security implications before enabling root login
- Review all changes to SSH configuration files

## Troubleshooting

If you encounter issues:

1. Check system logs: `journalctl -u sshd`
2. Verify SSH service status: `systemctl status sshd`
3. Ensure proper file permissions:
   - `/root/.ssh` should be 700
   - `/root/.ssh/authorized_keys` should be 600

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is open source and available under the MIT License.

## Author

Mohammad (xmohammad1)

## Disclaimer

This script modifies system security settings. Use with caution and ensure you understand the implications of each option before running the script.
