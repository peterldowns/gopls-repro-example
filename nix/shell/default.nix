{ }:
let
  # Import our pinned & customized version of Nixpkgs.
  pkgs = import ../pkgs { };

  # packages to install on darwin (macOS) machines
  darwinPaths = with pkgs; [
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Security
  ];
  # packages to install on non-darwin (linux) machines
  nonDarwinPaths = with pkgs; [
    # not yet used
  ];

  # Build a core environment with all of the core tools/toolchains.
  # This is everything needed to build and test the monorepo.
  coreToolchain = pkgs.buildEnv {
    name = "core-toolchains";

    paths = with pkgs;
      # We bring all pkgs into scope to make this a bit easier to read
      [
        go_1_18
        gopls
        gopkgs
        go-outline
        delve
        gotools
      ] ++ (if pkgs.stdenv.isDarwin then darwinPaths else nonDarwinPaths);
  };
in
# The shell environment output.
pkgs.mkShell {
  # Need to disable fortify hardening because GCC is not built with -oO,
  # which means that if CGO_ENABLED=1 (which it is by default) then the golang
  # debugger fails.
  # see https://github.com/NixOS/nixpkgs/pull/12895/files
  hardeningDisable = [ "fortify" ];

  buildInputs = [ coreToolchain ];

  shellHook = ''
    # Figure out the workspace root, which is:
    # - pwd when this hook fires under direct nix-shell invocations
    # - dirname of the IN_LORRI_SHELL file when fired by lorri invocations
    shell_nix="''${IN_LORRI_SHELL:-$(pwd)/shell.nix}"
    workspace_root=$(dirname "$shell_nix")
    export WORKSPACE_ROOT="$workspace_root"

    # Use a GOPATH local to this workspace so we get a portable
    # go environment that won't ever conflict with other repos or
    # other coding happening elsewhere.
    #
    # We also ensure the GOPATH's bin dir is on our PATH so tools
    # installed with `go install` work.
    #
    # Long term, tools installed with `go install` can also be
    # included directly as a nix package. Presently we're not
    # sure which way is best-- perhaps both ways are fine :).
    # 
    # Any tools installed explicitly with `go install` will take precedence
    # over versions installed by Nix due to the ordering here. VSCode is
    # configured to act this way already, explicitly, but this makes it so that
    # the shell/environment in general has the same behavior. The downside to
    # this is that if a user `go install`s a tool that we later update with
    # nix, they will remain using the version that they `go install`ed. 
    export GOPATH="$workspace_root"/.go
    export GOROOT=
    export PATH=$(go env GOPATH)/bin:$PATH
  '';
}
