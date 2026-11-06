#!/usr/bin/env bash
# Exporta la imagen de Kokoro a un .tar para llevarla a un servidor SIN internet.
# Uso:   ./save-image.sh [archivo.tar]
# Luego: copia el .tar al servidor y ejecuta allí ./load-image.sh archivo.tar
set -euo pipefail
cd "$(dirname "$0")"

DIGEST="ghcr.io/remsky/kokoro-fastapi-cpu@sha256:cbcc28802fb5d1eaaba8b91e38b0e872a669e85831c513cf6a29c709cbe25405"
LOCAL_TAG="kokoro-tts:local"
OUT="${1:-kokoro-tts-cpu-image.tar}"

if ! docker image inspect "$DIGEST" >/dev/null 2>&1; then
  echo "La imagen no está local. Descargándola desde GHCR..."
  docker pull "$DIGEST"
fi

docker tag "$DIGEST" "$LOCAL_TAG"

echo "Exportando imagen a $OUT (puede tardar varios minutos, ~3.3 GB)..."
docker save -o "$OUT" "$DIGEST" "$LOCAL_TAG"
echo "Listo: $(du -h "$OUT" | cut -f1) -> $OUT"
