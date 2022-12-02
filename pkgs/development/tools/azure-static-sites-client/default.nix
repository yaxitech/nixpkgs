{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, curl
, icu70
, libkrb5
, lttng-ust
, openssl_1_1
, zlib
, azure-static-sites-client
  # "latest", "stable" or "backup"
, versionFlavor ? "stable"
}:
let
  icu = icu70;
  versions = lib.importJSON ./versions.json;
  flavor = with lib; head (filter (x: x.version == versionFlavor) versions);
  fetchBinary = runtimeId: fetchurl {
    url = flavor.files.${runtimeId}.url;
    sha256 = flavor.files.${runtimeId}.sha;
  };
  sources = {
    "x86_64-linux" = fetchBinary "linux-x64";
    "x86_64-darwin" = fetchBinary "macOS";
  };
  isOldVersion = lib.versionOlder flavor.buildId "1.0.021611";
in
stdenv.mkDerivation rec {
  name = "${pname}-${versionFlavor}-${version}";
  pname = "StaticSitesClient";
  version = flavor.buildId;

  src = sources.${stdenv.targetPlatform.system};

  nativeBuildInputs = [
    autoPatchelfHook
  ] ++ lib.optionals isOldVersion [
    makeWrapper
  ];

  buildInputs = [
    curl
    icu
    openssl_1_1
    libkrb5
    lttng-ust
    stdenv.cc.cc.lib
    zlib
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install --mode 755 "$src" -D "$out/bin/${pname}"

    declare icu_major_v="${with lib; head (splitVersion (getVersion icu.name))}"
    for icu_lib in 'icui18n' 'icuuc' 'icudata'; do
      patchelf --add-needed "lib''${icu_lib}.so.$icu_major_v" "$out/bin/${pname}"
    done

    patchelf --add-needed 'libgssapi_krb5.so' \
             --add-needed 'liblttng-ust.so'   \
             --add-needed 'libssl.so.1.1'     \
             "$out/bin/${pname}"
  '' + lib.optionalString isOldVersion ''
    # Older versions unpack themselves and require additional wrapping

    autoPatchelf "$out/bin/"

    wrapProgram "$out/bin/${pname}" \
      --set DOTNET_BUNDLE_EXTRACT_BASE_DIR "$out/lib" \
      --prefix LD_LIBRARY_PATH : '${lib.makeLibraryPath [ icu ]}'

    # Call once to extract dependencies
    "$out/bin/${pname}" help

    find "$out/lib" -name 'libcoreclrtraceptprovider.so' -exec \
      patchelf --replace-needed 'liblttng-ust.so.0' 'liblttng-ust.so' {} \;
  '' + ''
    runHook postInstall
  '';

  # Stripping kills the binary
  dontStrip = true;

  # Just make sure the binary executes sucessfully
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/${pname} version

    runHook postInstallCheck
  '';

  # Create tests for all flavors
  passthru.tests = with lib; genAttrs (map (x: x.version) versions) (versionFlavor:
    azure-static-sites-client.override { inherit versionFlavor; }
  );

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Azure static sites client";
    homepage = "https://github.com/Azure/static-web-apps-cli";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ veehaitch ];
    platforms = [ "x86_64-linux" ];
  };
}
