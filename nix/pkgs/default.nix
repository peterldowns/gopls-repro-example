# This file pins a specific version of nixpkgs so we get pinned
# versions of all of our tools.
#
# Most derivations in Nix are structured as functions, and this top
# level one is no different.
#
# `...` is for variadic args.
# `args @` captures all arguments for our nixpkgs function in a set
# named args.
# 
# We're passing these through to the pinned version of nixpkgs.
args @ { ... }:
let
  fetchNixpkgs = spec @ { ... }: fetchTarball {
    url =
      "https://github.com/${spec.owner}/${spec.repo}/archive/${spec.rev}.tar.gz";
    sha256 = spec.sha256;
  };

  unstable = fetchNixpkgs {
    owner = "NixOS";
    repo = "nixpkgs";
    branch = "nixpkgs-unstable";
    rev = "90af9ef6d461d7b69631a1bcf91b45df49ddeb1d"; # 2022-03-18
    sha256 = "sha256:0dlyv43fxvpa6k71dn3s25mnlwnj2bmfyjlgml88xvkx6d02swm0";
  };

  pkgs = import unstable (args);
in
pkgs
