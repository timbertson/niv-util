{ pkgs ? import <nixpkgs> {}, ... }@opts:
with builtins;
let
  lib = pkgs.lib;
  nivCommit = "82e5cd1ad3c387863f0545d7591512e76ab0fc41";
  url = "https://raw.githubusercontent.com/nmattia/niv/${nivCommit}/nix/sources.nix";
  upstream = import (fetchurl url) opts;
  loggedSources = lib.mapAttrs (n: v: lib.trace "[niv]: providing ${n} from ${v.type}" v.outPath) upstream;

  local = args: if lib.isStorePath args.url then args.url else builtins.fetchGit args;

  result = loggedSources // {
    inherit local;
    sources = loggedSources;
    mergeOptionals = paths:
      lib.foldl (acc: p: acc // pkgs.callPackage p {}) result (lib.filter builtins.pathExists paths);

    cli = pkgs.stdenv.mkDerivation {
      pname = "niv-util";
      version = "dev";
      NIX_SOURCES_TEMPLATE = ''
        { pkgs ? import <nixpkgs> {}, ... }@opts:
        let
          defaults = { sourcesFile = ./sources.json; };
          url = builtins.fetchurl "https://raw.githubusercontent.com/timbertson/niv-util/__REVISION__/default.nix";
        in
        import url (defaults // opts)
      '';

      SCRIPT = ''
        #!/usr/bin/env bash
        set -eu
        case "''${1:-}" in
          init)
            rev="$(git ls-remote https://github.com/timbertson/niv-util.git HEAD | cut -f 1)"
            if [ -z "$rev" ]; then
              echo "Error: can't find HEAD revision"
              exit 1
            fi
            mkdir -p nix
            dest="nix/sources.nix"
            sed -e "s/__REVISION__/$rev/g" "__SOURCES_FILE__" > "$dest"
            echo "Wrote $dest"
          ;;

          *)
            echo 'ERROR: unknown command. Try `init`'
          ;;
        esac
      '';

      buildCommand = ''
        mkdir -p $out/bin
        mkdir -p $out/share
        SOURCES_FILE="$out/share/sources.nix"
        echo "$NIX_SOURCES_TEMPLATE" > "$SOURCES_FILE"
        echo "$SCRIPT" | sed -e "s|__SOURCES_FILE__|$SOURCES_FILE|g" > $out/bin/niv-util
        chmod +x $out/bin/niv-util
      '';
    };
  };
in
result
