#!/usr/bin/env bash
set -euo pipefail
trap "echo; echo 'Interrupted.'; exit 130" INT

INV="src/ansible/inventory/hosts.yml"
KNOWN="$HOME/.ssh/known_hosts";  mkdir -p "$(dirname "$KNOWN")"

die(){ echo "❌ $*" >&2; exit 1; }
info(){ echo "👉 $*"; }
ok(){   echo "✅ $*"; }

# -------- Extract inventory values --------
host=$(awk '/ansible_host:/ {print $2; exit}' "$INV")   || die "Missing ansible_host."
user=$(awk '/ansible_user:/ {print $2; exit}' "$INV")   || die "Missing ansible_user."
key=$(awk '/private_key_file:/ {print $2; exit}' "$INV"); key=${key:-~/.ssh/github}

# -------- Ensure key pair locally ---------
if [[ ! -f $key ]]; then
  info "Generating key $key …"
  mkdir -p "$(dirname "$key")"
  ssh-keygen -t ed25519 -f "$key" -C "github-key" -N '' || die "ssh-keygen failed."
fi
pub="$key.pub"; ok "Private key exists: $key"

# -------- Trust VM host key ---------------
if ! ssh-keygen -F "$host" &>/dev/null; then
  info "Adding $host to known_hosts …"
  ssh-keyscan -H "$host" >>"$KNOWN" || die "ssh-keyscan failed (host unreachable?)"
fi; ok "Host '$host' trusted."

# -------- Copy pub key (password once) ----
if ! ssh -i "$key" -o BatchMode=yes "$user@$host" true 2>/dev/null; then
  echo "🔑 Key not yet accepted – you’ll be prompted for the VM password once."
  ssh-copy-id -i "$pub" "$user@$host" || die "ssh-copy-id failed (bad password?)."
  # extra safety: append manually & fix perms
  cat "$pub" | ssh "$user@$host" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    grep -qxF \"$(cat "$pub")\" ~/.ssh/authorized_keys || \
    (echo \"$(cat "$pub")\" >> ~/.ssh/authorized_keys) && chmod 600 ~/.ssh/authorized_keys"
fi
ok "Public key authorised on VM."

# -------- Verify key-only login -----------
ssh -i "$key" -o BatchMode=yes "$user@$host" true \
  || die "Key still rejected – check ~/.ssh/authorized_keys on VM."

# -------- Ensure local git config ---------
g_name=$(git config --global user.name || true)
g_email=$(git config --global user.email || true)
if [[ -z $g_name || -z $g_email ]]; then
  read -rp "📝 Git name  : " g_name
  read -rp "📝 Git email : " g_email
  git config --global user.name  "$g_name"
  git config --global user.email "$g_email"
fi; ok "Git global config present (name: $g_name, email: $g_email)."

# Create ~/.gitconfig if missing (some shells don’t create it)
[[ -f $HOME/.gitconfig ]] || git config --global --list >/dev/null

# -------- Copy key(s) + gitconfig to VM ---
info "Copying keys and git config to VM …"
scp -q -i "$key" "$key"          "$user@$host":~/.ssh/github
scp -q -i "$key" "$pub"          "$user@$host":~/.ssh/github.pub
scp -q -i "$key" "$HOME/.gitconfig" "$user@$host":~/.gitconfig
ssh  -i "$key" "$user@$host" "chmod 600 ~/.ssh/github ~/.ssh/github.pub"
ok "Keys and .gitconfig copied."

# -------- Post-generation hint ------------------------------------
# Test key against GitHub *silently* (no prompt). GitHub always exits 1,
# so check the banner text instead.
if ! ssh -i "$key" -o BatchMode=yes -T git@github.com 2>&1 \
        | grep -q "successfully authenticated"; then

  BLUE='\e[34m'; BOLD='\e[1m'; NC='\e[0m'

  echo -e "\n${BOLD}🔑  Your new SSH key isn't registered with GitHub yet.${NC}"
  echo -e "   1. Open ${BLUE}https://github.com/settings/ssh/new${NC} in your browser."
  echo -e "   2. Run:\n\n      ${BOLD}cat $pub${NC}\n\n      …and copy the entire line."
  echo    "   3. Paste that into the *Key* box, name it 'mythbound-dev',"
  echo    "      then click **Add SSH key**."
  echo
  echo -e "   Verify afterward with:\n"
  echo    "      ssh -i ~/.ssh/github -T git@github.com"
  echo
else
  ok "Key already recognised by GitHub — no action needed."
fi
