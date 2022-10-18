{ lib, mkPackage }:
mkPackage rec {
  owner = "pulumi";
  repo = "pulumi-random";
  version = "4.8.2";
  rev = "v${version}";
  hash = "sha256-tFEtBgNpl8090RuVMEkyGmdfpZK8wvOD4iog1JRq+GY=";
  vendorHash = "sha256-H3mpKxb1lt+du3KterYPV6WWs1D0XXlmemMyMiZBnqs=";
  cmdGen = "pulumi-tfgen-random";
  cmdRes = "pulumi-resource-random";
  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/v4/pkg/version.Version=v${version}"
  ];
}
