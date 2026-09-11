{ lib, stdenvNoCC, python3 }:
stdenvNoCC.mkDerivation {
  pname = "precision-gpu-indicator";
  version = "0.1.0";
  src = ./.;
  dontBuild = true;
  doCheck = true;
  nativeCheckInputs = [ python3 ];
  checkPhase = ''
    runHook preCheck
    PYTHONDONTWRITEBYTECODE=1 ${python3}/bin/python3 -m unittest discover -s tests -v
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/gnome-shell/extensions/gpu-indicator@alessio.local"
    cp extension/extension.js extension/metadata.json extension/stylesheet.css \
      "$out/share/gnome-shell/extensions/gpu-indicator@alessio.local/"
    cp collector.py "$out/bin/gpu-indicator-collector"
    substituteInPlace "$out/bin/gpu-indicator-collector" \
      --replace-fail '#!/usr/bin/env python3' '#!${python3}/bin/python3'
    chmod +x "$out/bin/gpu-indicator-collector"
    runHook postInstall
  '';
  passthru.extensionUuid = "gpu-indicator@alessio.local";
  meta = {
    description = "GNOME indicator for Intel/NVIDIA power state and readable GPU owners";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
