#!/usr/bin/env bash
# Runs ansible/playbooks/initialise.yml with the inventory in ansible/inventory/hosts.yml
# Uses the local .venv (works on Git-Bash Windows or Linux).

set -euo pipefail
trap 'echo; echo "Interrupted."; exit 130' INT

cd "$(dirname "$0")/.."          # move to repo root

VENVDIR=".venv"
INV_FILE="ansible/inventory/hosts.yml"
PLAYBOOK="ansible/playbooks/initialise.yml"

[[ -f $INV_FILE ]]  || { echo "❌ $INV_FILE not found."; exit 1; }
[[ -f $PLAYBOOK ]]  || { echo "❌ $PLAYBOOK not found."; exit 1; }
[[ -d $VENVDIR ]]   || { echo "❌ $VENVDIR missing. Run scripts/setup-python-env.sh first."; exit 1; }

# Windows vs Unix venv layout
if [[ -f "$VENVDIR/Scripts/activate" ]]; then
  ACT="$VENVDIR/Scripts/activate"
  APB="$VENVDIR/Scripts/ansible-playbook.exe"
else
  ACT="$VENVDIR/bin/activate"
  APB="$VENVDIR/bin/ansible-playbook"
fi

# shellcheck source=/dev/null
source "$ACT"

echo "🚀 Running playbook $PLAYBOOK ..."
"$APB" -i "$INV_FILE" "$PLAYBOOK" "$@"
