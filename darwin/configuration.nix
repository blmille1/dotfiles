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
      "ollama"
      "gnupg"
    ];

    casks = [
      # "bitwarden" # Re-enable deliberately after reviewing Homebrew cleanup behavior.
      "opensuperwhisper"
      "visual-studio-code"
    ];
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

        # OpenSuperWhisper (cask). Only the portable config keys - window
        # frame + onboarding flag are UI state, left out on purpose. The
        # KeyboardShortcuts_* values are JSON stored AS a string, so they
        # must stay plain strings here, not Nix attrsets.
        "ru.starmel.OpenSuperWhisper" = {
          KeyboardShortcuts_toggleRecord = ''{"carbonKeyCode":50,"carbonModifiers":2048}'';
          KeyboardShortcuts_escape = ''{"carbonKeyCode":53,"carbonModifiers":0}'';
          initialPrompt = "template.yaml => template.yml";
          modifierOnlyHotkey = "rightOption";
          selectedEngine = "whisper";
          whisperLanguage = "en";
        };
      };
    };
  };
}
