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
buildPythonPackage rec {
  inherit (pulumi) version src;

  pname = "pulumi";

  disabled = isPy27;

  propagatedBuildInputs = [
    semver
    protobuf
    dill
    grpcio
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
