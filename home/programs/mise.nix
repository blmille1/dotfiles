{ pkgs, lib, ... }: {
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      # Declarative inventory of floating-version CLIs managed independently
      # of the flake-pinned packages. This is the single source of truth. Add
      # or remove a line, then `hms` - the hook below reconciles.
      tools = {
        "claude-code" = { version = "latest"; minimum_release_age = "8h"; };
        copilot = { version = "latest"; minimum_release_age = "8h"; };
        "npm:@earendil-works/pi-coding-agent" = { version = "latest"; minimum_release_age = "8h"; };
      };
    };
  };

  # Reconcile mise on every `hms`. `mise activate` does NOT lazily auto-install
  # (that only happens in shims mode), so we install declared-but-missing tools
  # here, then prune anything installed that's no longer in the config above.
  # Net effect: this config file is authoritative — ad-hoc `mise use` installs
  # will be removed on the next switch.
  home.activation.miseSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # The npm-backed Pi install needs Node/npm in non-interactive activation.
    export PATH="${pkgs.nodejs_26}/bin:${pkgs.pipx}/bin:${pkgs.python3}/bin:$PATH"
    run ${pkgs.mise}/bin/mise install --yes
    run ${pkgs.mise}/bin/mise prune --yes
  '';
}
