{ ... }: {
  # Determinite Nix owns Nix itself - nix-darwin, hands off
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    onActivation = {
      # Do not remove Homebrew packages automatically. Review removals manually;
      # cleanup is a delicate operation on a machine with existing applications.
      cleanup = "none";
      upgrade = false;
    };

    taps = [ ];

    brews = [
      # Use Homebrew's complete package; the Nix package rewrites the guest
      # init script's shebang to a host-only Nix store path.
      "container"
      "ollama"
      "gnupg"
    ];

    casks = [
      # "bitwarden" # Re-enable deliberately after reviewing Homebrew cleanup behavior.
      "davit"
      "fluidvoice"
      "raspberry-pi-imager"
      "visual-studio-code"
    ];

    # Manage the already-installed Mac App Store variant. Do not replace it with
    # the standalone Homebrew cask; Tailscale warns against mixing variants.
    masApps = {
      "Tailscale" = 1475387142;
    };
  };

  system = {
    primaryUser = "blmille1";
    stateVersion = 7;

    defaults = {
      finder = {
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv"; # list view by default
        FXRemoveOldTrashItems = true;
        CreateDesktop = false;         # Clean desktop
      };

      dock = {
        autohide = true;
        mineffect = "scale";
        show-recents = true;
        tilesize = 64;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;

        # Keyboard
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      trackpad = {
        Clicking = false; # tap to click
      };

      # When you know you have a preference that should exist, but nix-darwin doesn't allow you to set it, put it here.
      CustomUserPreferences = {
        #NSGlobalDomain.NSUserDictionaryReplacementItems = [
        #  { on = true; replace = "omw"; "with" = "On my way!"; }
        #];

        # FluidVoice
        "com.FluidApp.app" = {
          HotkeyMode = "automatic";
          PressAndHoldMode = false;
        };
      };
    };
  };
}
