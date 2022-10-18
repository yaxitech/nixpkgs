{ callPackage }:
let
  mkPackage = callPackage ./base.nix { };
in
{
  pulumi-resource-azure-native = callPackage ./pulumi-resource-azure-native.nix { inherit mkPackage; };
}
