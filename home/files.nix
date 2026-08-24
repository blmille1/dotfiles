{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = repoPath: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/files/${repoPath}";
in {
  # AGENTS.md file linkage to all the agent harnesses
  home.file.".claude/CLAUDE.md".source = link "AGENTS.md";
  home.file.".copilot/copilot-instructions.md".source = link "AGENTS.md";
  home.file.".pi/agent/AGENTS.md".source = link "AGENTS.md";
  home.file.".claude/settings.json".source = link "claude/settings.json";

  home.file.".claude/statusline-command.sh".source = link "claude/statusline-command.sh";
  home.file.".config/git/ignore".source = link "git/ignore";
  # Maps commit email -> signing pubkey so local `git log --show-signature` and
  # `git verify-commit` can validate our own SSH-signed commits. Public key
  # material only (safe to commit). Same on every host since they share the key.
  home.file.".config/git/allowed_signers".source = link "git/allowed_signers";
  home.file.".config/wezterm/wezterm.lua".source = link "wezterm/wezterm.lua";
  # Only references key files (~/.ssh/**); the keys themselves are not tracked.
  home.file.".ssh/config".source = link "ssh/config";
}
