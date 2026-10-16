{ lib, pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };

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

    # No outbound update check: mise owns the Atuin version.
    update_check = false;

    # Refuse to record commands matching Atuin's built-in secret patterns.
    secrets_filter = true;

    # Backstop built-in secret filtering with patterns specific to this setup.
    history_filter = [
      "(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key)"
      "AWS_SECRET_ACCESS_KEY"
      "AWS_SESSION_TOKEN"
    ];
  };
in
{
  # Keep Nix-managed settings, but install the upstream prebuilt binary through
  # mise's Aqua backend rather than adding pkgs.atuin to the Nix closure.
  xdg.configFile."atuin/config.toml".source = tomlFormat.generate "atuin-config" settings;

  # Run after `mise activate zsh` so `atuin` resolves to mise's Aqua install.
  # Home Manager's programs.atuin integration hardcodes its Nix package path.
  programs.zsh.initContent = lib.mkOrder 1500 ''
    if [[ $options[zle] = on ]]; then
      eval "$(atuin init zsh --disable-up-arrow)"
    fi
  '';
}
