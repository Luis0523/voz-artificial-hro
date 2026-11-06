#!/usr/bin/env bash
# Carga en el servidor la imagen exportada con save-image.sh.
# Uso: ./load-image.sh kokoro-tts-cpu-image.tar
set -euo pipefail
cd "$(dirname "$0")"

if [ $# -lt 1 ]; then
  echo "Uso: $0 <archivo.tar>" >&2
  exit 1
fi

docker load -i "$1"
echo "Imagen cargada. Ahora: docker compose up -d"
echo "Si el compose no encuentra el digest, ejecuta:"
echo "  KOKORO_IMAGE=kokoro-tts:local docker compose up -d"
