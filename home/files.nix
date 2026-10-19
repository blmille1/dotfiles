{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = repoPath: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/files/${repoPath}";
in {
  # AGENTS.md file linkage to the configured agent harnesses
  home.file.".copilot/copilot-instructions.md".source = link "AGENTS.md";
  home.file.".pi/agent/AGENTS.md".source = link "AGENTS.md";
  # Maps commit email -> signing pubkey so local `git log --show-signature` and
  # `git verify-commit` can validate our own SSH-signed commits. Public key
  # material only (safe to commit). Same on every host since they share the key.
  home.file.".config/git/allowed_signers".source = link "git/allowed_signers";
  home.file.".config/wezterm/wezterm.lua".source = link "wezterm/wezterm.lua";
  # Only references key files (~/.ssh/**); the keys themselves are not tracked.
  home.file.".ssh/config".source = link "ssh/config";
}
