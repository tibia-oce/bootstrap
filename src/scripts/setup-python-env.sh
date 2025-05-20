#!/usr/bin/env bash
# scripts/setup-python-env.sh  (Windows-friendly)

set -euo pipefail
trap 'echo; echo "Interrupted."; exit 130' INT

REQ_FILE="ansible/requirements.txt"
GALAXY_REQ="ansible/requirements.yml"
VENV_DIR=".venv"

err()  { echo -e "❌  $*" >&2; exit 1; }
info() { echo -e "👉  $*"; }
ok()   { echo -e "✅  $*"; }

# -------- Locate Python ≥ 3.10 ------------------------------------
detect_python() {
  for cmd in "python3" "python" "py -3" "python3.11" "python3.10"; do
    type ${cmd%% *} &>/dev/null || continue
    ver=$($cmd --version 2>&1)
    [[ $ver =~ Python\ 3\.(1[0-9]|[3-9]) ]] && { echo "$cmd"; return; }
  done
  return 1
}

PY=$(detect_python) || err "Python 3.10+ not found. Install Python 3.11 and retry."
info "Using interpreter: $PY"

# -------- Create / reuse virtual-env -------------------------------
if [[ ! -d $VENV_DIR ]]; then
  info "Creating virtual environment in $VENV_DIR …"
  $PY -m venv "$VENV_DIR" || err "venv creation failed."
else
  ok "Virtual environment $VENV_DIR exists – reusing."
fi

# Pick the correct activate path (Windows vs Unix)
if [[ -f "$VENV_DIR/Scripts/activate" ]]; then
  ACT="$VENV_DIR/Scripts/activate"
  VENV_PY="$VENV_DIR/Scripts/python.exe"
else
  ACT="$VENV_DIR/bin/activate"
  VENV_PY="$VENV_DIR/bin/python"
fi

# shellcheck source=/dev/null
source "$ACT"

# -------- Upgrade pip / install deps -------------------------------
info "Upgrading pip / setuptools / wheel …"
$VENV_PY -m pip install --quiet --upgrade pip setuptools wheel

[[ -f $REQ_FILE ]] || err "$REQ_FILE not found."

info "Installing Python dependencies from $REQ_FILE …"
$VENV_PY -m pip install --upgrade -r "$REQ_FILE"

# Ensure ansible-core is present even if not in requirements.txt
if ! grep -qiE '^ansible(-core)?' "$REQ_FILE"; then
  $VENV_PY -m pip install --upgrade ansible-core
fi
ok "Python requirements installed."

# -------- Optional: ansible-galaxy roles/collections ---------------
if [[ -f $GALAXY_REQ ]]; then
  if [[ "$OSTYPE" =~ (msys|cygwin|win32) ]]; then
    info "Skipping ansible-galaxy install on Windows; will run inside the VM."
  else
    info "Installing Ansible Galaxy requirements …"
    ansible-galaxy install -r "$GALAXY_REQ" --force
    ok "Galaxy roles/collections installed."
  fi
fi
