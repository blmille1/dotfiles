{ config, lib, pkgs, ... }: {
  imports = [ ./common.nix ];

  home.username = "brandon";
  home.homeDirectory = "/home/brandon";

  sops.secrets."agentsview-mac-token" = {
    key = "AGENTSVIEW_MAC_TOKEN";
  };
  sops.secrets."agentsview-mac-url" = {
    key = "AGENTSVIEW_MAC_URL";
  };

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

  # Keep the remote token and tailnet URL out of Nix and Git. SOPS deploys
  # them as mode-0400 runtime files; this writes the config with mode 600.
  home.activation.agentsviewRemoteHost = lib.hm.dag.entryAfter [ "agentsviewConfig" "sops-nix" ] ''
    token_file="${config.sops.secrets."agentsview-mac-token".path}"
    url_file="${config.sops.secrets."agentsview-mac-url".path}"
    if [ ! -r "$token_file" ] || [ ! -r "$url_file" ]; then
      echo "AgentsView Mac SOPS values are not deployed; add AGENTSVIEW_MAC_TOKEN and AGENTSVIEW_MAC_URL to secrets/home.yaml" >&2
      exit 1
    fi

    token="$(< "$token_file")"
    mac_url="$(< "$url_file")"
    if [ -z "$token" ]; then
      echo "AgentsView Mac token is empty" >&2
      exit 1
    fi
    if [[ ! "$mac_url" =~ ^http://[A-Za-z0-9.-]+:[0-9]+$ ]]; then
      echo "AgentsView Mac URL must be an HTTP hostname and port" >&2
      exit 1
    fi
    token_toml="$(printf '%s' "$token" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"

    config_dir="$HOME/.agentsview"
    config_file="$config_dir/config.toml"
    if [ -L "$config_file" ] || [ ! -f "$config_file" ]; then
      echo "Refusing to update missing or symlinked AgentsView config: $config_file" >&2
      exit 1
    fi

    umask 077
    config_tmp="$(mktemp "$config_dir/config.toml.XXXXXX")"
    trap 'rm -f "$config_tmp"' EXIT
    marker_start="# BEGIN Home Manager AgentsView remote host"
    marker_end="# END Home Manager AgentsView remote host"
    if ! ${pkgs.gawk}/bin/awk -v start="$marker_start" -v end="$marker_end" '
      $0 == start { if (inside) invalid=1; inside=1; starts++; next }
      $0 == end { if (!inside) invalid=1; inside=0; ends++; next }
      !inside { print }
      END { if (inside || invalid || starts != ends || starts > 1) exit 1 }
    ' "$config_file" > "$config_tmp"; then
      echo "Malformed managed AgentsView remote-host block" >&2
      exit 1
    fi

    cat >> "$config_tmp" <<EOF
$marker_start
[[remote_hosts]]
host = "millers-air-m5"
transport = "http"
url = "$mac_url"
token = "$token_toml"
interval = "5m"
$marker_end
EOF
    run chmod 600 "$config_tmp"
    run mv "$config_tmp" "$config_file"
  '';
}
