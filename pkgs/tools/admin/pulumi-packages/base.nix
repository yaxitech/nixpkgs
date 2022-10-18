{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  mkBasePackage =
    { owner
    , repo
    , rev
    , version
    , hash
    , vendorHash
    , cmd
    , extraLdflags
    , ...
    }@args: buildGoModule (rec {
      pname = cmd;

      inherit vendorHash version;

      src = fetchFromGitHub {
        name = "source-${repo}-${rev}";
        inherit owner repo rev hash;
      };

      sourceRoot = "source-${repo}-${rev}/provider";

      subPackages = [ "cmd/${cmd}" ];

      doCheck = false;

      # Bundle release metadata
      ldflags = [
        "-s"
        "-w"
      ] ++ extraLdflags;
    } // args);
in
{ owner
, repo
, rev
, version
, hash
, vendorHash
, cmdGen
, cmdRes
, extraLdflags
, ...
}@args:
let
  pulumi-gen = mkBasePackage rec {
    inherit owner repo rev version hash vendorHash extraLdflags;

    cmd = cmdGen;
  };
in
mkBasePackage {
  inherit owner repo version rev hash vendorHash extraLdflags;

  nativeBuildInputs = [
    pulumi-gen
  ];

  cmd = cmdRes;

  postConfigure = ''
    set -x

    pushd ..

    chmod +w sdk/
    ${cmdGen} schema

    popd

    VERSION=v${version} go generate cmd/${cmdRes}/main.go

    set +x
  '';
}
