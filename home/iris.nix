{ lib, ... }: {
  imports = [ ./common.nix ];

  home.username = "brandon";
  home.homeDirectory = "/home/brandon";

  # Seed a writable runtime config and update only its network fields. AgentsView
  # persists its auth token here, so never symlink the file or put secrets in the template.
  home.activation.agentsviewConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_dir="$HOME/.agentsview"
    config_file="$config_dir/config.toml"
    run mkdir -p "$config_dir"
    run chmod 700 "$config_dir"

    if [ -L "$config_file" ]; then
      echo "Refusing to manage symlinked AgentsView config: $config_file" >&2
      exit 1
    elif [ -e "$config_file" ]; then
      run chmod 600 "$config_file"
      echo "Preserving existing AgentsView credentials and settings"
    else
      umask 077
      cat > "$config_file" <<'EOF'
# Iris's local AgentsView server settings.
require_auth = true
daemon_idle_timeout = "0s"
EOF
      run chmod 600 "$config_file"
    fi

    tailscale_ip=""
    tailscale_bin="/usr/bin/tailscale"
    if [ -x "$tailscale_bin" ]; then
      tailscale_ip="$("$tailscale_bin" ip -4 2>/dev/null || true)"
    fi

    set_toml_string() {
      key="$1"
      value="$2"
      config_tmp="$(mktemp "$config_dir/config.toml.XXXXXX")"
      if grep -Eq "^[[:space:]]*''${key}[[:space:]]*=" "$config_file"; then
        sed -E "s|^[[:space:]]*''${key}[[:space:]]*=.*|''${key} = \"''${value}\"|" \
          "$config_file" > "$config_tmp"
      else
        printf '%s = "%s"\n' "$key" "$value" > "$config_tmp"
        cat "$config_file" >> "$config_tmp"
      fi
      run chmod 600 "$config_tmp"
      run mv "$config_tmp" "$config_file"
    }

    if [[ "$tailscale_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      set_toml_string host "$tailscale_ip"
      set_toml_string public_url "http://iris-server:8080"
    else
      echo "Tailscale IPv4 unavailable; preserving the current AgentsView network settings"
    fi
  '';
}
