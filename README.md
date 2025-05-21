# dotfiles-cloudshell

Dotfiles for GCP Cloudshell

## Quick Install (Cloudshell)

Run this command in your Cloudshell to install these dotfiles:

```
curl -fsSL https://raw.githubusercontent.com/sandcastle/dotfiles-cloudshell/main/install.sh | bash
```

This will copy all configuration files from this repository's `src` directory to your home directory, backing up any existing files.

## Optional Flags

The install script supports the following optional flags:

- `--verbose`: Print detailed information about which files and directories are being copied and backed up.
- `--quiet`: Suppress most output except for errors and essential messages.

You can use these flags by appending them to the install command, for example:

```
curl -fsSL https://raw.githubusercontent.com/sandcastle/dotfiles-cloudshell/main/install.sh | bash -s -- --verbose
```

```
curl -fsSL https://raw.githubusercontent.com/sandcastle/dotfiles-cloudshell/main/install.sh | bash -s -- --quiet
```
