{ lib
, mkPulumiPackage
}:
mkPulumiPackage rec {
  owner = "pulumi";
  repo = "pulumi-aws-native";
  version = "0.40.2";
  rev = "v${version}";
  hash = "sha256-TTHY2xIkyT5SWHCs6NmTOV7DtUwzPMexxKyXozX6M/0=";
  vendorHash = "sha256-BM02e946ZTISwtd0Q01wJjxjAJkcQMBVHQuIURfEPZc=";
  cmdGen = "pulumi-gen-aws-native";
  cmdRes = "pulumi-resource-aws-native";
  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/pkg/version.Version=v${version}"
  ];

  fetchSubmodules = true;
  postConfigure = ''
    pushd ..

    ${cmdGen} schema aws-cloudformation-schema ${version}

    popd
  '';

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Native AWS Pulumi Provider";
    homepage = "https://github.com/pulumi/pulumi-aws-native";
    license = licenses.asl20;
    maintainers = with maintainers; [ veehaitch trundle ];
  };
}
