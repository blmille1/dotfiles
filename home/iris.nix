{ lib, ... }: {
  imports = [ ./common.nix ];

  home.username = "brandon";
  home.homeDirectory = "/home/brandon";

  # Seed a writable runtime config. AgentsView persists its auth token here, so
  # do not symlink this file from the repository or put secrets in the template.
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
      echo "Preserving existing AgentsView config at $config_file"
    else
      umask 077
      cat > "$config_file" <<'EOF'
# Iris's initial local-only server configuration.
# Set host to Iris's Tailscale IP during remote-access onboarding.
require_auth = true
daemon_idle_timeout = "0s"
EOF
      run chmod 600 "$config_file"
    fi
  '';
}
