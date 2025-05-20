# Windows → VMware → Ubuntu → Mythbound 🚀

> **Note:** This project is designed for Windows users new to development, using VMWare Workstation with Ubuntu 24.04 Desktop.

A **zero‑to‑hero** guide for absolute beginners. By the end you will have:

1. An Ubuntu 24.04 LTS virtual machine named **`mythbound`** running in VMware Workstation on Windows 10/11.
2. Secure SSH access between your Windows control node and the Linux VM.
3. A Mythbound development workstation — with pre-installed libraries, compiled game server, client, website, proxies, and tools (i.e.: map editor)

---

## Quick Links

- [Requirements](#requirements)
- [VM Setup (Ubuntu 24.04 LTS)](#vm-setup-ubuntu-2404-lts)
- [Control Node Setup (Windows 10)](#control-node-setup-windows-10)
- [Installation Scripts](#installation-scripts)
- [Security Notes](#security-notes)
- [Troubleshooting](#troubleshooting)

---

## Requirements

### Virtrual machine hardware (minimum)

| Resource    | Recommended |
| ----------- | ----------- |
| **CPU**     | 4 cores     |
| **RAM**     | 10 GB       |
| **Storage** | 100 GB free |

### Software (download first)

| Purpose                                 | Link                                                                                                                  |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Git for Windows                         | <https://github.com/git-for-windows/git/releases/latest>                                                              |
| VMware Workstation **Player** 17 (Free) | <https://customerconnect.vmware.com/en/downloads/info/slug/desktop_end_user_computing/vmware_workstation_player/17_0> |
| Ubuntu 24.04 LTS ISO                    | <https://releases.ubuntu.com/24.04/>                                                                                  |
| Python 3.12 (Microsoft Store)           | <https://apps.microsoft.com/detail/9NCVDN91XZQP?hl=en-us&gl=AU&ocid=pdpshare>                                         |

---

## VM Setup (Ubuntu 24.04 LTS)

1. **Create the VM**

   | VMware Wizard Page           | Setting               |
   | ---------------------------- | --------------------- |
   | _Installer disc image (ISO)_ | Ubuntu 24.04 ISO      |
   | _Guest OS_                   | Linux → Ubuntu 64‑bit |
   | _VM name_                    | `mythbound`           |
   | _Processors / Cores_         | 4                     |
   | _Memory_                     | **10240 – 12288 MB**  |
   | _Network_                    | **NAT**               |
   | _Disk Size_                  | 100 GB (single file)  |

2. **Install Ubuntu**

   - Choose **Minimal installation**.
   - Create the primary user **`mythbound`** (password of your choice).
   - Keep **automatic security updates** enabled.

3. **Enable SSH in the VM**

   ```bash
   sudo apt update
   sudo apt install -y openssh-server
   sudo ufw allow OpenSSH
   sudo systemctl enable --now ssh
   ```

4. **Find the VM’s IP**

   ```bash
   hostname -I
   ```

   Note the address (e.g. `192.168.187.128`).

---

## Control Node Setup (Windows 10)

> Commands are in **PowerShell**. Run the first session as **Administrator**.

### 1 . Verify Git & OpenSSH

```powershell
git --version
ssh -V
```

### 2 . Install Python 3.12

Microsoft Store → search **Python 3.12** → _Get_. Validate:

```powershell
python --version   # Python 3.12.x
```

### 3 . Install the Justfile runner

[Justfile](https://github.com/casey/just) will be used to shortcut all future commands.

```powershell
winget install --id Casey.Just --exact
exit
```

Add the public key to GitHub: **Settings → SSH and GPG keys → New SSH key**

## Installation Scripts

> Commands built for **Git Bash**. Run the session as **Administrator**.

1. **Configure inventory & secrets**  
   Run `just setup` – adds your VM details to Ansible inventory and prepares any required secret files.
   Add the public key to GitHub: **Settings → SSH and GPG keys → New SSH key**

2. **Set up Python, Ansible & Provision the VM**  
   Run `just bootstrap` – launches the Ansible playbook that bootstraps the Mythbound development stack inside the VM.

---

## Troubleshooting

| Symptom                                                     | Fix                                                                                           |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `ssh : connect to host … port 22: Connection timed out`     | Check VM network mode and ensure `sshd` is running.                                           |
| `Permission denied (publickey)`                             | Re‑copy key, verify correct `-i` path and `authorized_keys` permissions.                      |
| VMware “out of memory” warnings                             | Assign 10 GB instead of 12 GB RAM or close other apps.                                        |
| AttributeError: module 'os' has no attribute 'get_blocking' | Ensure python 3.12 is installed and previous versions aren't running the ansible environment. |
