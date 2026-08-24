{ pkgs, ... }: {
  home.packages = with pkgs; [
    age # modern file encryption
    bat
    btop  # resource monitor (htop-style) - CPU, mem, disk, net, procs
    dust  # `dust` - intuitive du replacement (tree of what's eating disk).
    fd
    fzf
    gitleaks # scan staged changes for secrets
    jless
    jq
    nerd-fonts.hack
    pipx  # Python-CLI installer.
    ripgrep
    sops  # uses age, encrypts individual properties in files vs whole file
    tldr  # simplified, example-driven man pages (`tldr tar`)
    tree
    wezterm
    xz    # general purpose compression, great for JSON
  ];
}
