{ lib
, buildGoModule
, pulumi
, python3
}:
buildGoModule rec {
  inherit (pulumi) version src sdkVendorHash;

  pname = "pulumi-language-python";

  sourceRoot = "${src.name}/sdk/python/cmd/pulumi-language-python";

  vendorHash = "sha256-HlcSkFoLPcHRyp0yH+ojGnL/gubfGyCP1iCK6sOootQ=";

  postPatch = ''
    substituteInPlace main_test.go \
      --replace "TestDeterminePulumiPackages" \
                "SkipTestDeterminePulumiPackages"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/pulumi/pulumi/sdk/v3/go/common/version.Version=${version}"
  ];

  postInstall = ''
    cp ../pulumi-language-python-exec    $out/bin
    cp ../../dist/pulumi-resource-pulumi-python $out/bin
    cp ../../dist/pulumi-analyzer-policy-python $out/bin
  '';

  nativeCheckInputs = [
    python3
  ];
}
