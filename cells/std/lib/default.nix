{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs;
in {
  inherit (inputs.devshell.legacyPackages) mkShell;

  fromMakesWith = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "makes" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'makes' must be defined in the flake. See inputs above.
      ''
    );
    assert nixpkgs.lib.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'nixpkgs' must be defined in the flake. See inputs above.
      ''
    ); inputs';
    makes = nixpkgs.lib.fix (
      nixpkgs.lib.extends (
        _: _: {
          inherit (inputsChecked.nixpkgs) system;
          inputs = inputsChecked;
          __nixpkgs__ = nixpkgs;
          __nixpkgsSrc__ = nixpkgs.path;
        }
      )
      (
        import (inputsChecked.makes + /src/args/agnostic.nix) {inherit (inputsChecked.nixpkgs) system;}
      )
      .__unfix__
    );
  in
    nixpkgs.lib.customisation.callPackageWith makes;

  writeShellEntrypoint = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "n2c" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.writeShellEntrypoint', an input
        named 'n2c' (representing 'nlewo/nix2container') must be defined in the flake.
        See inputs above.
      ''
    ); inputs';
  in
    import ./writeShellEntrypoint.nix { inputs = inputsChecked; inherit cell;};
}
