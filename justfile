import 'src/scripts/colours.just'

# ------------------------------------------------------
# Default Command
# ------------------------------------------------------
default:
    @just help


# ------------------------------------------------------
# Help Command
# ------------------------------------------------------
help:
    @just _echo-white "OVH Cloud Ansible CLI"
    @echo
    @just _echo-white "Usage:"
    @echo "  just [COMMAND]"
    @echo
    @just _echo-yellow "Environment Setup Commands:"
    @echo
    @just _echo-magenta "  setup"
    @just _echo-white "        Checks Docker, config, SSH keys directory (generates new key if empty),"
    @just _echo-white "        and prompts for inventory details."
    @echo
    @just _echo-yellow "Playbook Commands:"
    @echo
    @just _echo-magenta "  ping"
    @just _echo-white "        Runs 'ansible all -m ping' to test connectivity to all inventory hosts."
    @echo
    @just _echo-magenta "  bootstrap"
    @just _echo-white "        Applies the bootstrap.yml playbook (initial server hardening)."
    @echo

# ------------------------------------------------------
# Setup
# ------------------------------------------------------
setup:
    @just check-docker
    @echo
    @just check-empty-inventory
    @echo
    @just setup-common
    @echo
    @just _echo-cyan "🔑 Ensuring keys exits and git is configure ..."
    @bash src/scripts/add-known-host.sh
    @echo
    @just _echo-info "Setup completed successfully..."
    @just _echo-success "Try running 'just ping' to test access to the server."

# ------------------------------------------------------
# Check Docker
# ------------------------------------------------------
check-docker:
    @just _echo-cyan "🐋 Ensuring docker is installed and avaialble ..."
    @if command -v docker >/dev/null 2>&1; then \
      echo "✅ Docker is already installed; skipping installation" ; \
    else \
      just _echo-error "❌ Docker is not installed. Please install Docker Desktop:"; \
      just _echo-error "   https://www.docker.com/products/docker-desktop/"; \
      exit 1; \
    fi


# ------------------------------------------------------
# Prompt Inventory
# ------------------------------------------------------
prompt-inventory:
    @just _echo-cyan "📄 Prompting for inventory (hosts.yml)..."
    @bash src/scripts/inventory.sh

check-empty-inventory:
    @just _echo-cyan "📄 Ensuring ansible inventory file exists ..."
    @if [ ! -f src/ansible/inventory/hosts.yml ]; then \
      just _echo-warning "No inventory file found at src/ansible/inventory/hosts.yml. Creating a new one..."; \
      just prompt-inventory; \
    else \
      echo "✅ Inventory file already exists; skipping creation." ; \
    fi


# ------------------------------------------------------
# Check if Keys Directory is Empty
# ------------------------------------------------------
check-empty-keys:
    @if find src/ansible/keys -maxdepth 1 -type f -name '*.pub' -print -quit | grep -q .; then \
      just _echo-info "🔑 SSH public key(s) already exist in src/ansible/keys."; \
    else \
      just _echo-warning "No SSH public keys (*.pub) found in src/ansible/keys."; \
      bash src/scripts/select-or-generate-key.sh; \
    fi

# ------------------------------------------------------
# Setup Common
# ------------------------------------------------------
setup-common:
    @just _echo-cyan "📦 Ensuring ansible image cytopia/ansible:2.13 ..."
    @if ! docker image inspect cytopia/ansible:2.13 > /dev/null 2>&1; then \
          docker pull cytopia/ansible:2.13 ; \
      else \
          echo "✅ Image already present — skipping pull." ; \
      fi


# ------------------------------------------------------
# Ansible: Running Playbooks
# ------------------------------------------------------
run-playbook playbook:
    @just _echo-cyan "🛠 Running playbook {{playbook}}..."
    @docker-compose -f src/docker/docker-compose.yaml run --rm ansible \
      ansible-playbook "{{playbook}}"

ping:
    @docker-compose -f src/docker/docker-compose.yaml run --rm ansible \
      ansible all -m ping

bootstrap:
    @just run-playbook playbooks/bootstrap.yml
