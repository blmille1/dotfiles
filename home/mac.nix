{ lib, ... }:
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
