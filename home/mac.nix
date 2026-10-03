{ lib, pkgs, ... }:
let
  agentsviewLauncher = pkgs.writeShellScript "agentsview-launcher" ''
    tailscale_bin="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
      if [ -x "$tailscale_bin" ] && TAILSCALE_BE_CLI=1 "$tailscale_bin" ip -4 >/dev/null 2>&1; then
        exec ${pkgs.mise}/bin/mise exec -- agentsview daemon start
      fi
      /bin/sleep 2
    done
    exit 1
  '';
in
rec {
  imports = [ ./common.nix ];
  home.username = "blmille1";
  home.homeDirectory = "/Users/blmille1";

  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
  # Tailscale's Mac App Store build bundles its CLI inside the app.
  programs.zsh.shellAliases.tailscale =
    "TAILSCALE_BE_CLI=1 /Applications/Tailscale.app/Contents/MacOS/Tailscale";

  # Start the existing App Store client at each GUI login. Its network extension
  # handles the VPN connection; no separate Homebrew daemon is needed.
  launchd.agents.tailscale = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-a" "/Applications/Tailscale.app" ];
      RunAtLoad = true;
    };
  };

  # Keep the Mac available as an authenticated HTTP sync source while it is
  # awake. The daemon itself is detached, so launchd only starts it at login.
  launchd.agents.agentsview = {
    enable = true;
    config = {
      ProgramArguments = [ "${agentsviewLauncher}" ];
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
    };
  };

  # Preserve AgentsView's generated credentials while managing only the
  # Tailscale listener and daemon lifetime settings.
  home.activation.agentsviewRemoteAccess = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="$HOME/.agentsview"
    config_file="$config_dir/config.toml"
    run mkdir -p "$config_dir"
    run chmod 700 "$config_dir"

    if [ -L "$config_file" ]; then
      echo "Refusing to manage symlinked AgentsView config: $config_file" >&2
      exit 1
    elif [ -e "$config_file" ]; then
      run chmod 600 "$config_file"
    else
      umask 077
      cat > "$config_file" <<'EOF'
require_auth = true
daemon_idle_timeout = "0s"
EOF
      run chmod 600 "$config_file"
    fi

    set_toml_value() {
      key="$1"
      value="$2"
      config_tmp="$(mktemp "$config_dir/config.toml.XXXXXX")"
      if grep -Eq "^[[:space:]]*''${key}[[:space:]]*=" "$config_file"; then
        sed -E "s|^[[:space:]]*''${key}[[:space:]]*=.*|''${key} = ''${value}|" "$config_file" > "$config_tmp"
      else
        printf '%s = %s\n' "$key" "$value" > "$config_tmp"
        cat "$config_file" >> "$config_tmp"
      fi
      run chmod 600 "$config_tmp"
      run mv "$config_tmp" "$config_file"
    }

    set_toml_value require_auth true
    set_toml_value daemon_idle_timeout '"0s"'

    tailscale_ip=""
    tailscale_bin="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
    if [ -x "$tailscale_bin" ]; then
      tailscale_ip="$(TAILSCALE_BE_CLI=1 "$tailscale_bin" ip -4 2>/dev/null || true)"
    fi

    if [[ "$tailscale_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      set_toml_value host "\"$tailscale_ip\""
      set_toml_value public_url "\"http://$tailscale_ip:8080\""
    else
      echo "Tailscale IPv4 unavailable; preserving the current AgentsView network settings"
    fi
  '';

  programs.zsh.initContent = lib.mkOrder 1200 ''
    # Put the Nix profile ahead of macOS path_helper's /usr/bin. Needed because
    # long-running servers (herdr, tmux) inherit __ETC_PROFILE_NIX_SOURCED, which makes
    # nix-daemon.sh skip its one-shot prepend — so we assert it ourselves.
    path=("$HOME/.nix-profile/bin" "/nix/var/nix/profiles/default/bin" $path)

    export HOMEBREW_PREFIX=/opt/homebrew
    export PATH="$HOME/.local/bin:$PATH"
    test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"
  '';
}
