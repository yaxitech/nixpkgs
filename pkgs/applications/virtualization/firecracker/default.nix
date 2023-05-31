{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
, clang
, openssl
, linuxHeaders
}:
rustPlatform.buildRustPackage rec {
  pname = "firecracker";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-h9BBfErt7s3IJ9myhyHc5is1962Icb/KutJc/lTvZrI=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "kvm-bindings-0.6.0" = "sha256-w+u8FJ31N8C2MHZdOvFyVn59R/Cu3z5JOXxGvWYYeRM";
      "micro_http-0.1.0" = "sha256-Mz/KoxUqaqB9BHru1I9pg0IYe4gwm6c6/tcMOC5aYyE=";
    };
  };

  # userfaultfd-sys asserts `include/uapi` which does not exist in `linuxHeaders`
  # but is also not required
  postPatch = ''
    substituteInPlace $TMPDIR/cargo-vendor-dir/userfaultfd-sys-0.4.2/build.rs \
      --replace 'incl_dir.push("uapi");' ""
  '';

  preConfigure = ''
    export LINUX_HEADERS=${linuxHeaders}
    export LIBCLANG_PATH="${clang.cc.lib}/lib"
    export OPENSSL_INCLUDE_DIR="${openssl.dev}/include"
    export OPENSSL_LIB_DIR="${lib.getLib openssl}/lib"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    find build/cargo_target/ -executable -type f -name firecracker -exec cp {} $out/bin \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Secure, fast, minimal micro-container virtualization";
    homepage = "http://firecracker-microvm.io";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ thoughtpolice endocrimes ];
  };
}
