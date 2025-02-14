# SSH Password & Root Login Manager

A professional Bash script to manage SSH root login settings on your Linux system. This interactive tool helps you:

- Enable SSH password login for root.
- Disable SSH password login (with an option to add an SSH key).
- Enable root login via cloud configuration.
- Set or remove SSH keys for the root user.

> **Note:** This script requires `sudo` privileges and is intended for Linux systems with systemd and cloud-init.

## Features

- **Interactive Menu:** A user-friendly, color-enhanced terminal interface.
- **Flexible Options:** Enable or disable SSH password login, configure SSH keys, and update cloud configuration for root access.
- **Robust & Modular:** Each function is encapsulated for easy maintenance and updates.

## Requirements

- **Operating System:** Linux (Ubuntu, Debian, CentOS, etc.)
- **Dependencies:** `bash`, `sudo`, `systemctl`, and (optionally) `cloud-init`.
- **Privileges:** Root or sudo privileges are required to make system-level changes.

## Installation

You can directly download and run the script using `curl` or `wget`.

### Using `curl`

```bash
curl -sSL https://raw.githubusercontent.com/xmohammad1/ssh_password/refs/heads/main/ssh.sh -o ssh.sh
chmod +x ssh.sh
sudo ./ssh.sh
