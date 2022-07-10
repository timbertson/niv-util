{ pkgs ? import <nixpkgs> {}, ...}@opts:
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
    cli = pkgs.stdenv.mkDerivation {
      pname = "niv-util";
      version = "dev";
      buildCommand = let
        setupNixContents = rev: "";
      in
      ''
        mkdir -p $out/bin
        cat << "EOF" > $out/bin/niv-util
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
            echo "import (builtins.fetchurl \"https://raw.githubusercontent.com/timbertson/niv-util/$rev/default.nix\")" > "$dest"
            echo "Wrote $dest"
          ;;

          *)
            echo 'ERROR: unknown command. Try `init`'
          ;;
        esac
        EOF

        chmod +x $out/bin/niv-util'';
    };
  };
in
result
