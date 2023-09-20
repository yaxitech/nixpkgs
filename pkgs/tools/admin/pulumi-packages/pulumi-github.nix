{ lib
, mkPulumiPackage
}:
mkPulumiPackage rec {
  owner = "pulumi";
  repo = "pulumi-github";
  version = "5.17.0";
  rev = "v${version}";
  hash = "sha256-GxZ/FAD+S6jPrVNyRRhqEkey1MC2MO7E8dDgVFLzHTk=";
  vendorHash = "sha256-sPmWGmzNWP0/qNhDWZvbeMBUISOLZ3PTLQgZ2UL+8/8=";
  cmdGen = "pulumi-tfgen-github";
  cmdRes = "pulumi-resource-github";
  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/v5/pkg/version.Version=v${version}"
  ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "A Pulumi package to facilitate interacting with GitHub";
    homepage = "https://github.com/pulumi/pulumi-github";
    license = licenses.asl20;
    maintainers = with maintainers; [ veehaitch trundle ];
  };
}
