{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in {
  home.file.".config/herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/files/herdr/config.toml";
}
