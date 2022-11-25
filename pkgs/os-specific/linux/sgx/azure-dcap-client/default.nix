{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, curl
, nlohmann_json
, openssl
, pkg-config
}:

let
  # Although those headers are also included in the source of `sgx-psw`, the `azure-dcap-client` build needs specific versions
  headers = {
    "sgx_ql_lib_common.h" = fetchurl {
      url = "https://raw.githubusercontent.com/intel/SGXDataCenterAttestationPrimitives/0436284f12f1bd5da7e7a06f6274d36b4c8d39f9/QuoteGeneration/quote_wrapper/common/inc/sgx_ql_lib_common.h";
      hash = "sha256-36oxPBt0SmmRqjwtXgP87wOY2tOlbxQEhMZZgjoh4xI=";
    };
    "sgx_attributes.h" = fetchurl {
      url = "https://raw.githubusercontent.com/intel/linux-sgx/1ccf25b64abd1c2eff05ead9d14b410b3c9ae7be/common/inc/sgx_attributes.h";
      hash = "sha256-fPuwchUP9L1Zi3BoFfhmRPe7CgjHlafNrKeZDOF2l1k=";
    };
    "sgx_key.h" = fetchurl {
      url = "https://raw.githubusercontent.com/intel/linux-sgx/1ccf25b64abd1c2eff05ead9d14b410b3c9ae7be/common/inc/sgx_key.h";
      hash = "sha256-3ApIE2QevE8MeU0y5UGvwaKD9OOJ3H9c5ibxsBSr49g=";
    };
  };
in
stdenv.mkDerivation rec {
  pname = "azure-dcap-client";
  version = "1.11.2";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = pname;
    rev = version;
    hash = "sha256-EYj3jnzTyJRl6N7avNf9VrB8r9U6zIE6wBNeVsMtWCA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl.dev
    nlohmann_json
    openssl
  ];

  patchPhase = ''
    runHook prePatch

    pushd src/Linux
    rm configure
    mkdir -p ext/intel
    ${lib.strings.concatStringsSep "\n" (lib.attrsets.mapAttrsToList (name: value: "ln -s ${value} ext/intel/${name}") headers)}
    popd

    runHook postPatch
  '';

  configurePhase = ''
    runHook preConfigure

    substitute src/Linux/Makefile{.in,} \
      --replace '##CURLINC##' '${curl.dev}/include/curl/' \
      --replace '-Wall' '-Wall -Wno-deprecated-declarations' \
      --replace 'prefix = /usr/local' 'prefix ='

    runHook postConfigure
  '';

  makeFlags = [
    "-C src/Linux"
  ];

  installFlags = [
    "DESTDIR=$(out)"
  ];
}
