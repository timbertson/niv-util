# niv-util

This is a small wrapper utility for [niv][].

The idea is that it replaces `sources.nix` to simply delegate to the online version, rather than repeating the lengthy contents of

This also makes it easy to upate - alter the git sha, rather than niv trying to guess when it's out of date by checking the file's checksum.


# Additions:

### `local`:

Takes the same arguments as `builtins.fechGit`, but returns the bare `url` if it happens to be a store path. This means you can use `{ url = ../.; }` for a working path from a development repo (via git) and also from within a fetched tarball.

### `cli`:

Builds a simple derivation providing `niv-util` script. This writes out a trivial wrapper to `nix/sources.nix`.
