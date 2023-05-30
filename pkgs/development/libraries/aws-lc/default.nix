{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, perl
, prefix ? ""
}:
stdenv.mkDerivation rec {
  pname = "aws-lc";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-lc";
    rev    = "v${version}";
    sha256 = "sha256-3v7Nq6IIN1vezRnryd7ekeFvqbDpZakSDwa6hznoa58=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
  ];

  cmakeFlags = [
    "-GNinja"
    "-DBORINGSSL_PREFIX=${prefix}"
    # Use pre-generated files
    "-DDISABLE_GO=ON"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=stringop-overflow"
  ];

  doCheck = true;
  checkTarget = "run_minimal_tests";

  meta = with lib; {
    description = "AWS-LC is a general-purpose cryptographic library maintained by the AWS Cryptography team for AWS and their customers";
    homepage    = "https://github.com/aws/aws-lc";
    maintainers = [ maintainers.veehaitch ];
    license = with licenses; [ openssl isc mit bsd3 ];
  };
}
