{ ... }: rec {
  imports = [ ./common.nix ];

  home.username = "brandon";
  home.homeDirectory = "/home/brandon";

  # WSL logs you into bash and standalone HM can't rewrite /etc/passwd.
  # So the moment an interactive login bash starts, hand off to zsh.
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
        exec zsh -l
      fi
    '';
  };
}
