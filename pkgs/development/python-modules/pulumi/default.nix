{ lib
, buildPythonPackage
, fetchFromGitHub
, protobuf
, dill
, grpcio
, pulumi
, isPy27
, semver
, pyyaml
, six
}:
let
  # Pulumi uses a pinned version because tests didn't pass with later versions, see
  # https://github.com/pulumi/pulumi/issues/10301
  grpcio-1_47 = grpcio.overrideAttrs (finalAttrs: previousAttrs: rec {
    src = fetchFromGitHub {
      owner = "grpc";
      repo = "grpc";
      rev = "v${version}";
      hash = "sha256-fMYAos0gQelFMPkpR0DdKr4wPX+nhZSSqeaU4URqgto=";
      fetchSubmodules = true;
    };

    version = "1.47.0";
  });
in
buildPythonPackage rec {
  inherit (pulumi) version src;

  pname = "pulumi";

  disabled = isPy27;

  propagatedBuildInputs = [
    semver
    protobuf
    dill
    grpcio-1_47
    pyyaml
    six
  ];

  sourceRoot = "source/sdk/python/lib";

  # we apply the modifications done in the pulumi/sdk/python/Makefile
  # but without the venv code
  postPatch = ''
    cp ../../README.md .
    sed -i "s/\''${VERSION}/${version}/g" setup.py
  '';

  # disabled because tests try to fetch go packages from the net
  doCheck = false;

  pythonImportsCheck = [ "pulumi" ];

  meta = with lib; {
    description = "Modern Infrastructure as Code. Any cloud, any language";
    homepage = "https://github.com/pulumi/pulumi";
    license = licenses.asl20;
    maintainers = with maintainers; [ teto ];
  };
}
