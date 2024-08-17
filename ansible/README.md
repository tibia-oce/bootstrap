# Ansible

## Prerequisites

### Unix environment
WSL on windows

### Ansible
A UNIX environment: https://docs.ansible.com/ansible/latest/installation_guide/index.html

### Python environemnt
The `netaddr` Python library needs to be installed on the control machine

### SSH key pairs
Generate an RSA SSH key pair.
```zsh
ssh-keygen -t rsa -b 4096
```

To enable passwordless SSH authentication, you need to copy the public key (id_rsa.pub) to each managed node.
```zsh
ssh-copy-id [user]@[ip]
```

## Get started

### Install some requirements for ansible
```zsh
ansible-galaxy install -r ./ansible/requirements.yml
```
