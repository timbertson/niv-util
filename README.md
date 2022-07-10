# niv-util

This is a small wrapper expression for [niv](https://github.com/nmattia/niv).

The idea is that it replaces `sources.nix` to simply delegate to the online version, rather than repeating the lengthy contents of `sources.nix`. This keeps your repository a little cleaner.

It also makes updates straightforward - you update by changing the git sha, rather than niv trying to guess when it's out of date by checking the file's checksum.

# Features

 - traces the import of each source, along with its type. This can help track down when a source is coming from a surprising location (due to env vars) or when the same source is coming from two different locations in a transitive build.
 - the returned objects are the `.outPath` from niv - i.e. the actual paths / derivations. Use `sources` if you need to access other attributes.

# Additional attributes in the returned object:

### `local`:

Takes the same arguments as `builtins.fechGit`, but returns the bare `url` if it happens to be a store path. This means you can use `{ url = ../.; }` for a working path from a development repo (via git) and also from within a fetched tarball.

### `sources`:

The plain sources returned by niv directly

### `cli`:

A simple derivation providing `niv-util` script. `niv-util init` will (over)write `nix/sources.nix` with a trivial wrapper that imports the latest commit from this repository.
