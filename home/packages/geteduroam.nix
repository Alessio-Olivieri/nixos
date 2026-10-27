{ geteduroam, fetchurl }:

# Work around the login-page logo crash until upstream PR #105 is released.
# https://github.com/geteduroam/linux-app/pull/105
geteduroam.overrideAttrs (old: {
  # The GUI still crashes entering credentials (upstream issue #98).
  # Include the upstream CLI as a fallback: run geteduroam-cli in a terminal.
  subPackages = (old.subPackages or []) ++ [ "cmd/geteduroam-cli" ];
  patches = (old.patches or []) ++ [
    (fetchurl {
      url = "https://github.com/geteduroam/linux-app/commit/bf77e54a049c8ecad27203ecc47c1e0692f3178f.patch";
      hash = "sha256-pJm3WHNZ8WUJoZW5JQgOaFXcz8rG8cofoD4bTbvq3ps=";
    })
  ];
})
