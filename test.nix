{ pkgs ? import <nixpkgs> {}}:
let
  sources = import ./default.nix { sourcesFile = ./nix/sources.json; };
in
pkgs.mkShell {
  SELF_SRC = sources.niv-util;
}
