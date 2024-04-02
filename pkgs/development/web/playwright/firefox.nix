{ stdenv
, fetchzip
, firefox-bin
, suffix
, revision
}:
let
  suffix' = if suffix == "linux"
            then "ubuntu-22.04"
            else suffix;
in
stdenv.mkDerivation {
  name = "firefox";
  src = fetchzip {
    url = "https://playwright.azureedge.net/builds/firefox/${revision}/firefox-${suffix'}.zip";
    hash = "sha256-Wka1qwkrX5GDlekm7NfSEepI8zDippZlfI2tkGyWcFs=";
    stripRoot = false;
  };

  inherit (firefox-bin.unwrapped)
    nativeBuildInputs
    buildInputs
    runtimeDependencies
    appendRunpaths
    patchelfFlags
  ;

  buildPhase = ''
    cp -R . $out
  '';
}
