#!/usr/bin/env bash
#
# Minimal inventory generator for key-based SSH with sudo password.
#   • ansible_host
#   • ansible_user
#   • private_key_file
#   • ansible_become_password
#
# File: scripts/generate_inventory.sh

set -e
trap "exit 130" INT

INVENTORY="src/ansible/inventory/hosts.yml"
mkdir -p "$(dirname "$INVENTORY")"

mask() { [[ -n $1 ]] && echo "${1:0:4}******"; }

# Load existing values if the inventory already exists
if [[ -f $INVENTORY ]]; then
  existing_host=$(grep 'ansible_host:' "$INVENTORY" | awk -F': ' '{print $2}')
  existing_user=$(grep 'ansible_user:' "$INVENTORY" | awk -F': ' '{print $2}')
  existing_key=$(grep 'private_key_file:' "$INVENTORY" | awk -F': ' '{print $2}')
  existing_become_pass=$(grep 'ansible_become_password:' "$INVENTORY" | awk -F': ' '{print $2}')
fi

# Host/IP
while true; do
  read -p "🌐 Virtual machine IP (existing: ${existing_host:-none}): " h
  ansible_host=${h:-$existing_host}
  [[ -n $ansible_host ]] && break
  echo "❌ Cannot be empty."
done

# SSH user
while true; do
  read -p "👤 SSH Username (existing: ${existing_user:-none}): " u
  ansible_user=${u:-$existing_user}
  [[ -n $ansible_user ]] && break
  echo "❌ Cannot be empty."
done

# Private-key path (default ~/.ssh/github)
read -p "🔑 Private-key path [${existing_key:-~/.ssh/github}]: " k
ansible_key=${k:-${existing_key:-~/.ssh/github}}

# Sudo password (become)
while true; do
  prompt="🛡  Sudo password (required"
  [[ -n $existing_become_pass ]] && prompt+="; existing: $(mask "$existing_become_pass")"
  prompt+="): "
  read -s -p "$prompt" p; echo
  ansible_become_password=${p:-$existing_become_pass}
  [[ -n $ansible_become_password ]] && break
  echo "❌ Cannot be empty."
done

# ------------------- Write inventory -------------------
cat >"$INVENTORY" <<EOF
---
all:
  hosts:
    mythbound_vm:
      ansible_host: ${ansible_host}
      ansible_user: ${ansible_user}
      ansible_become_password: ${ansible_become_password}
      private_key_file: ${ansible_key}
EOF

echo "✅ Inventory '${INVENTORY}' created/updated."
