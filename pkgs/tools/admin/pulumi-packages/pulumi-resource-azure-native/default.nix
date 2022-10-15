{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  pulumiAzureNativeDrv = { pname, ... }@args: buildGoModule (rec {
    inherit pname;
    version = "1.81.0";

    src = fetchFromGitHub {
      owner = "pulumi";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-xiifVjvtt4bKi0fBYLU/Gfkx2tziLIq2vddRNWwuyz0=";
    };
    vendorSha256 = "sha256-VSwT5I5casJiBpXAcV9vLEWU9XWuDTktmfGqE6H/HX4=";

    doCheck = false;

    # Bundle release metadata
    ldflags = [
      "-s"
      "-w"
      "-X github.com/pulumi/pulumi-azure-native/provider/pkg/version.Version=v${version}"
    ];
  } // args);

  pulumi-gen-azure-native = pulumiAzureNativeDrv rec {
    pname = "pulumi-gen-azure-native";

    sourceRoot = "source/provider";

    subPackages = [
      "cmd/${pname}"
    ];
  };
in

pulumiAzureNativeDrv {
  pname = "pulumi-resource-azure-native";

  nativeBuildInputs = [
    pulumi-gen-azure-native
  ];

  sourceRoot = "source/provider";

  postConfigure = ''
    pushd $TMPDIR/source

    pulumi-gen-azure-native schema

    popd
  '';

  subPackages = [
    "cmd/pulumi-resource-azure-native"
  ];

  meta = with lib; {
    homepage = "https://github.com/pulumi/pulumi-azure-native";
    description = "Native Azure Pulumi Provider";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ trundle veehaitch ];
  };
}
