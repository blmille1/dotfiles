{ config, pkgs, ... }: {
  # Install one shared pre-commit hook for every Git repository on this host.
  # The absolute store path keeps the hook independent of PATH configuration.
  home.file.".config/git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${pkgs.gitleaks}/bin/gitleaks protect --staged --redact
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Brandon Miller";
      user.email = "computerengineer.brandon@gmail.com";
      init.defaultBranch = "main";
      core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
      core.symlinks = false;
      push.autoSetupRemote = true;

      # Sign commits with the local SSH key. Each host signs with its own
      # local key, so all hosts' commits verify against the account's keys.
      gpg.format = "ssh";
      user.signingKey = "~/.ssh/id_ed25519.pub";
      commit.gpgSign = true;
      tag.gpgSign = true;
      # Lets local verification (git log --show-signature) trust our own key.
      "gpg \"ssh\"".allowedSignersFile = "~/.config/git/allowed_signers";
    };
  };
}
