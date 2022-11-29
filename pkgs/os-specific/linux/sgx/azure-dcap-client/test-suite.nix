{ lib
, sgx-azure-dcap-client
, gtest
, makeWrapper
}:
sgx-azure-dcap-client.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    makeWrapper
    gtest
  ];

  # No need to build the provider lib again
  postPatch = ''
    substituteInPlace ./src/Linux/Makefile.in \
      --replace '$(TEST_SUITE): $(PROVIDER_LIB) $(TEST_SUITE_OBJ)' \
                '$(TEST_SUITE): $(TEST_SUITE_OBJ)'
  '';

  buildFlags = [
    "tests"
  ];

  installPhase = ''
    runHook preInstall

    install -D ./src/Linux/tests "$out/bin/tests"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/tests --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ sgx-azure-dcap-client ]}"
  '';
})
