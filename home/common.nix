{ config, ... }: {
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
}
