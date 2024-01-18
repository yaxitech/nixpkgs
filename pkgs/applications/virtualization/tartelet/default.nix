{ lib
, stdenvNoCC
, fetchzip
, makeWrapper
, tart
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tartelet";
  version = "0.7.1";

  src = fetchzip {
    url = "https://github.com/shapehq/tartelet/releases/download/${finalAttrs.version}/Tartelet.zip";
    hash = "sha256-l2st6u0yLSBuEyxONGzpoRz4nLz6bLEfNE0lCRV5jH0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # ./Tartelet.app/Contents/MacOS/Tartelet binary is required to be used in order to
    # trick macOS to pick Tartelet.app/Contents/embedded.provision profile for elevated
    # privileges that Tartelet needs
    mkdir -p $out/bin $out/Applications
    cp -r ./. $out/Applications/Tartelet.app/
    makeWrapper $out/Applications/Tartelet.app/Contents/MacOS/Tartelet $out/bin/Tartelet \
      --prefix PATH : ${lib.makeBinPath [ tart ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A macOS app that makes it a breeze to manage multiple GitHub Actions runners in ephemeral virtual machines on a single host machine. ";
    homepage = "https://github.com/shapehq/tartelet";
    license = licenses.mit;
    maintainers = with maintainers; [ veehaitch Trundle ];
    mainProgram = finalAttrs.pname;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})
