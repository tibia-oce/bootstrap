#!/usr/bin/env bash
# scripts/ping_vm.sh
# --------------------------------------------
# Reads ansible/inventory/hosts.yml and tries
# an SSH echo → prints green ✅ or red ❌.
# --------------------------------------------

set -euo pipefail

INV="ansible/inventory/hosts.yml"

die() { printf "\e[31m❌  %s\e[0m\n" "$*" >&2; exit 1; }
ok()  { printf "\e[32m✅  %s\e[0m\n" "$*\n"; }

host=$(awk '/ansible_host:/ {print $2; exit}' "$INV") || die "ansible_host missing."
user=$(awk '/ansible_user:/ {print $2; exit}' "$INV") || die "ansible_user missing."
key=$(awk '/private_key_file:/ {print $2; exit}' "$INV")
key=${key:-$HOME/.ssh/github}

echo "🔗 Testing SSH connection to $user@$host ..."
if ssh -i "$key" -o BatchMode=yes -o ConnectTimeout=5 "$user@$host" 'echo pong' >/dev/null 2>&1
then
  ok "SSH connection successful."
else
  die "SSH connection failed."
fi
