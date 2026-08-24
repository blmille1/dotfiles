{ ... }:
{
  # Portable zsh — lives in common.nix's world, so BOTH Mac and WSL get it.
  programs.zsh = {
    enable = true;

    # ── oh-my-zsh: provisioned from the Nix store (no ~/.oh-my-zsh clone) ──
    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      plugins = [
        "vi-mode" "z" "git" "macos" "docker" "terraform"
      ];
    };

    # Plugins from Nixpkgs (replace the Homebrew `source` lines)
    autosuggestion.enable     = true;
    syntaxHighlighting.enable  = true;

    # ── global aliases (zsh `alias -g`) ──
    shellGlobalAliases = {
      NUL = "> /dev/null 2>&1";
      L   = "| less";
    };

    # ── ordinary aliases ──
    shellAliases = {
      dir     = "ls";
      gs      = "git status";
      reload  = "source ~/.zshrc";

      # nix
      hms     = "home-manager switch --flake ~/.dotfiles";
      drs     = "sudo darwin-rebuild switch --flake ~/.dotfiles";

      docker_clean_images = "docker rmi $(docker images -a --filter=dangling=true -q)";
      docker_clean_ps     = "docker rm $(docker ps --filter=status=exited --filter=status=created -q)";

      json2yaml = "ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read))'";

      si = "ssh brandon@iris-server";
      gi = "ssh -N -L 18789:127.0.0.1:18789 brandon@iris-server";
    };

    # ── everything without a dedicated option ──
    initContent = ''
      set -o inc_append_history

      # suffix aliases
      alias -s json="jless"
      alias -s js="$EDITOR"
      alias -s yml="bat -l yaml"
      alias -s txt="$EDITOR"
      alias -s toml="$EDITOR"
      alias -s md="bat"
      alias -s nix="$EDITOR"

      autoload zmv
      alias mmv='noglob zmv -W'

      # completion styling
      unsetopt LIST_BEEP
      zstyle ':completion:*:descriptions' format '%B%d%b'
      zstyle ':completion:*:messages' format %d
      zstyle ':completion:*:warnings' format 'No matches for: %d'
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*' completer _expand _complete _correct
      zstyle ':completion:*:cd:*' ignore-parents parent pwd

      # nvm (kept as-is for now; a nix-native node is a later option)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      unalias - - 2>/dev/null

      # git-commit skeleton widget: keymap-independent (vi-mode safe), lands the
      # cursor between the quotes. A `bindkey -s` macro would push back \C-b,
      # which self-inserts under the vi keymap instead of moving the cursor.
      function git-commit-skeleton {
        LBUFFER='git commit -m "'
        RBUFFER='"'
      }
      zle -N git-commit-skeleton

      # keybindings + right prompt
      bindkey '^Q' push-line-or-edit
      bindkey '\eQ' push-line-or-edit
      bindkey '^Xgc' git-commit-skeleton
      RPS1="%F{red}%(?..(%?%))%f %D %F{yellow}%*%f"
    '';
  };
}
