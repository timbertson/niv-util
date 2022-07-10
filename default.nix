{ pkgs ? import <nipkgs> {}, ...}@opts:
with builtins;
let
  lib = pkgs.lib;
  nivCommit = "82e5cd1ad3c387863f0545d7591512e76ab0fc41";
  url = "https://raw.githubusercontent.com/nmattia/niv/${nivCommit}/nix/sources.nix";
  upstream = import (fetchurl url) opts;
  loggedSources = lib.mapAttrs (n: v: lib.trace "[niv]: providing ${n} from ${v.type}" v.outPath);

  local = args: if builtins.isStorePath arg.url then arg.url else builtins.fetchGit args;

  decorated = loggedSources // {
    inherit local;
    sources = loggedSources;
    cli = pkgs.stdenv.mkDerivation {
      buildPhase = let
        setupNixContents = rev: ''
          import "https://raw.githubusercontent.com/timbertson/niv-util/${rev}/default.nix"
        '';
      in
      ''
        mkdir -p $out/bin
        cat << EOF > $out/bin/niv-util
        #!/usr/bin/env bash
        set -eu
        case "''${1}:-" in
          init)
          ;;

          *)
          ;;
        EOF

        chmod +x $out/bin/niv-util'';
    };
  };
in

