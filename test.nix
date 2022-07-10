{ pkgs ? import <nixpkgs> {}}:
let
  sources = import ./nix/sources.nix { sourcesFile = ./nix/sources.json; };
in
pkgs.mkShell {
  SELF_SRC = sources.niv-util;
}
