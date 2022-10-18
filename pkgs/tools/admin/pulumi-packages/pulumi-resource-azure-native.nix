{ mkPackage }:
mkPackage rec {
  owner = "pulumi";
  repo = "pulumi-azure-native";
  version = "1.81.0";
  rev = "v${version}";
  hash = "sha256-BIzZveyhdxXBMqt168J2iLx1Kka3VcpJWFpbdGPf+aY=";
  vendorHash = "sha256-VSwT5I5casJiBpXAcV9vLEWU9XWuDTktmfGqE6H/HX4=";
  cmdGen = "pulumi-gen-azure-native";
  cmdRes = "pulumi-resource-azure-native";
  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/pkg/version.Version=v${version}"
  ];
}
