## Quick start

### SSH key pairs
```zsh
ssh-keygen -t rsa -b 4096 # ignore if already exists
ssh-copy-id [user]@[ip]
```

### Bootstrap
```zsh
task ansible:run namespace=bootstrap playbook=initialise
```
