{ config, lib, pkgs, ... }: {
  imports = [
    ./packages.nix
    ./programs/atuin.nix
    ./programs/mise.nix
    ./programs/git.nix
    ./programs/delta.nix
    ./programs/neovim.nix
    ./programs/herdr.nix
    ./programs/zsh.nix
    ./files.nix           # raw dotfiles
  ];

  home.stateVersion = "26.11"; # set once, leave it alone

  programs.home-manager.enable = true; # let HM manage its own command

  sops = {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
    defaultSopsFile = ../secrets/home.yaml;
    secrets = {
      # declare each key here or it won't deploy
      # OPENROUTER_API_KEY = { }; # When what used this is found, uncomment
      # test = {};
    };
  };

  # sops-nix tries to restart its user service before linkGeneration installs
  # the unit on a first Home Manager switch. Install the links and reload the
  # user manager before restarting it.
  home.activation.sops-nix = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    lib.mkForce (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      systemd_status="$(${config.systemd.user.systemctlPath} --user is-system-running 2>&1 || true)"
      if [[ "$systemd_status" == running || "$systemd_status" == degraded ]]; then
        ${config.systemd.user.systemctlPath} --user daemon-reload
        ${config.systemd.user.systemctlPath} --user restart sops-nix
      fi
    '')
  );
}
