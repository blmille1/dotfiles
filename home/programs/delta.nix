{ ... }: {
  # git-delta: syntax-highlighted, navigable diffs. Home-manager installs the
  # `delta` package and, with enableGitIntegration, wires up git's core.pager,
  # interactive.diffFilter, and the [delta] config section for us.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;   # n / N to jump between diff hunks
      line-numbers = true;
      side-by-side = true;  # flip to true if you prefer two columns
      syntax-theme = "Dracula";
    };
  };
}
