{ pkgs ? import <nixpkgs> {}}:
let
  sources = import ./nix/sources.nix { sourcesFile = ./nix/sources.json; };
  sourcesWithOverride = (import ./nix/sources.nix { sourcesFile = ./nix/sources.json; })
    .mergeOptionals [ ./test/local.nix ./test/missing.nix ];
in
pkgs.mkShell {
  SELF_SRC = sources.niv-util;
  SELF_SRC_OVERRIDE = sourcesWithOverride.niv-util;
  LOCAL_SRC = sourcesWithOverride.localPkg;
}
