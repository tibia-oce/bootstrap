# Symlinks

Symlinks allow the otclient to use the assets repository's things directory without needing a separate copy. Any changes made in assets/things are automatically reflected in otclient/data/things because the symlink points directly to the assets directory.

- Branch Switching: When you switch branches in the assets repository, the otclient directory will automatically update to reflect the files from the current branch.
- Making Changes: Modifications in assets/things—whether adding, editing, or deleting files—will instantly appear in otclient/data/things.
- Commits and Branches: Committing changes or switching branches in assets will update the content in otclient accordingly.

The symlink effectively makes /repos/otclient/data/things a mirror of /repos/assets/things, ensuring that otclient always uses the latest assets without duplicating files.