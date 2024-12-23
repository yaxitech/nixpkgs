{
  buildGoModule,
  fetchFromGitHub,
  hurl,
  killall,
  lib,
  openssh,
}:
buildGoModule rec {
  pname = "litetlog";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "litetlog";
    rev = "v${version}";
    hash = "sha256-PCaXtaFwR5Q4aUvfXDnU1kI7EP9KtbBb/8co+XQ9GQU=";
  };
  vendorHash = "sha256-6B7ULx7wsyU6K5oaB/WsmlEFTonfD0ybYHbqpV9IPSQ=";

  subPackages = [
    "cmd/litebastion"
    "cmd/litewitness"
    "cmd/spicy"
    "cmd/tlogclient-warmup"
    "cmd/witnessctl"
  ];

  nativeCheckInputs = [
    hurl
    killall
    openssh
  ];

  meta = {
    description = "A collection of liteweight transparency logging tools, compatible with the Sigsum and Omniwitness ecosystems";
    homepage = "https://github.com/FiloSottile/litetlog";
    changelog = "https://github.com/FiloSottile/litetlog/blob/v${version}/NEWS.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ veehaitch ];
  };
}
