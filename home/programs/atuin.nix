{ ... }:
{
  # Shell history: SQLite-backed, searchable. Lives in common.nix's world so
  # BOTH Mac and WSL get it. The HM module installs the binary and wires the
  # zsh hooks (Ctrl-R search + up-arrow) — no manual `eval "$(atuin init)"`.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # Keep the up-arrow bound to zsh's own history (prefix recall of the current
    # session), so only Ctrl-R invokes atuin. Without this, atuin hijacks the
    # up-arrow too, which feels like it "takes over" the shell.
    flags = [ "--disable-up-arrow" ];

    # Local-only by default (no sync server). Drop `atuin login` + a
    # sync_address here later if you want cross-machine history.
    settings = {
      # Keep the shell's own up-arrow (prefix search of local session)
      # instead of atuin taking it over; Ctrl-R still opens atuin.
      enter_accept = false;

      # Don't take over the terminal: render the search UI inline just above the
      # prompt instead of fullscreen, and cap its height to a few lines.
      #style = "compact";
      inline_height = 5;

      # Hide the help row (atuin version + update notice, keymap hint, history
      # count). It's the line that shows the version; off for a cleaner UI.
      show_help = true;

      # Stop the "N seconds ago" timers from ticking live every second - a
      # distracting redraw. The relative time is still shown, just static.
      prefers_reduced_motion = true;

      # Drop the top tabs row (Search / Inspect header) for a cleaner UI.
      show_tabs = false;

      # Use vim keys in the search box, but START in insert mode so typing goes
      # straight into the query. "auto" would inherit zsh's vi-mode and open in
      # NORMAL mode, where keystrokes are motions and nothing you type appears.
      # Esc still drops to normal mode for j/k navigation.
      keymap_mode = "vim-insert";

      # No outbound update check: nixpkgs owns the atuin version, so the notice
      # is useless and we keep this local-only install from phoning home.
      update_check = false;

      # ── secret hygiene ──
      # Refuse to record commands matching atuin's built-in secret patterns
      # (AWS keys, GitHub/Slack tokens, private-key headers, etc.). This is the
      # upstream default, but pin it explicitly so a default change can't
      # silently start capturing secrets.
      secrets_filter = true;

      # Never store commands matching these regexes. Backstops secrets_filter
      # for our own patterns: anything mentioning tokens/passwords/secrets, and
      # the AWS creds helpers from zsh.nix that could echo sensitive values.
      history_filter = [
        "(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key)"
        "AWS_SECRET_ACCESS_KEY"
        "AWS_SESSION_TOKEN"
      ];
    };
  };
}
