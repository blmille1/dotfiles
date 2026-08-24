# Personal dotfiles

Personal macOS and Linux workstation configuration managed with Nix flakes.

The macOS setup uses [Determinate Nix](https://determinate.systems/nix/) to install and operate Nix, [nix-darwin](https://github.com/nix-darwin/nix-darwin) for system settings, and [Home Manager](https://github.com/nix-community/home-manager) for user packages and dotfiles.

## macOS bootstrap

These instructions are for a fresh Apple Silicon Mac. This flake currently targets `aarch64-darwin`.

### 1. Install Determinate Nix

Install the [Determinate Nix macOS package](https://docs.determinate.systems/getting-started/installation/) and follow its setup prompts. The command-line installer is also available:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

Open a new terminal after installation, then verify Nix and flakes:

```sh
nix --version
nix flake --help
```

Determinate Nix owns the Nix installation and its daemon. This repository deliberately sets `nix.enable = false` in the nix-darwin configuration, so nix-darwin does not try to manage or replace Determinate Nix.

### 2. Clone the repository

```sh
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
```

Replace `<repository-url>` with the URL of this repository.

### 3. Bootstrap nix-darwin

The first invocation uses nix-darwin's `darwin-rebuild` directly because it is not installed in the shell yet. The flake lock file pins the nix-darwin version used by this configuration.

```sh
sudo nix run nix-darwin#darwin-rebuild -- switch --flake .#<darwin-host>
```

This applies the macOS system configuration and installs the configured Homebrew packages and casks. Confirm the host name if this command fails:

```sh
scutil --get LocalHostName
```

The name after `#` must match a key in `darwinConfigurations` in `flake.nix`. For a different Mac, update the host key and `nixpkgs.hostPlatform` in the configuration before running the command.

### 4. Activate Home Manager

Home Manager is configured as a standalone flake output, separate from nix-darwin. Bootstrap its command directly from the Home Manager flake:

```sh
nix run home-manager -- switch --flake .#<username>@<hostname>
```

This installs the user packages and links the managed dotfiles. It also installs the `home-manager` command for later use.

After the first activation, use:

```sh
home-manager switch --flake ~/.dotfiles#<username>@<hostname>
```

The Home Manager configuration installs a global Git pre-commit hook that runs Gitleaks against staged changes.

## Daily commands

Apply macOS system changes:

```sh
sudo darwin-rebuild switch --flake ~/.dotfiles#<darwin-host>
```

Apply user and dotfile changes:

```sh
home-manager switch --flake ~/.dotfiles#<username>@<hostname>
```

Update flake inputs intentionally, then review the resulting lock-file changes:

```sh
nix flake update
home-manager switch --flake ~/.dotfiles#<username>@<hostname>
```

Check all flake outputs without activating anything:

```sh
nix flake check --all-systems
```

## Secrets

The repository contains SOPS-encrypted values in `secrets/home.yaml`. Never commit the private age identity or SSH private keys. The local SOPS identity must exist before enabling any secret in `home/common.nix`:

```text
~/.config/sops/age/keys.txt
~/.ssh/id_ed25519
```

The public encryption recipients and encrypted ciphertext are safe to publish, but the private identities are not. Machine-specific files such as the local npm configuration are ignored by Git.

## Other hosts

On a new host, install Determinate Nix first, clone the repository, and activate the matching output:

```sh
nix run home-manager -- switch --flake ~/.dotfiles#<username>@<hostname>
```

## Layout

- `flake.nix` - pinned inputs and system/user outputs
- `darwin/configuration.nix` - macOS system settings and Homebrew packages
- `home/` - Home Manager modules and user configuration
- `home/files/` - public dotfiles linked into the home directory
- `secrets/home.yaml` - SOPS-encrypted personal values
- `archive/` - older configuration retained for reference
