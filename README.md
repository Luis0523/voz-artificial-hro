# Kokoro-82M (Kokoro-FastAPI) — entorno aislado

Prueba del TTS Kokoro-82M en el equipo real (CPU), separada del resto del proyecto `modelo-voz`.

- Repo clonado en `repo/` (https://github.com/remsky/Kokoro-FastAPI)
- Muestras generadas en `samples/`
- No modifica nada fuera de esta carpeta

## Estado

Servicio levantado en Docker (imagen oficial CPU), puerto **8880**:

- API OpenAI-compatible: `http://localhost:8880/v1`
- Web Player: `http://localhost:8880/web/`
- Modelo: `kokoro_v1` en CPU, 72 voicepacks
- Warmup del modelo: **2989 ms**

## Arrancar / parar

```bash
cd repo/docker/cpu
docker compose up -d --no-build   # arrancar
docker compose logs -f            # ver logs
docker compose down               # parar
```

## Voces en español

| Voz      | Descripción |
|----------|-------------|
| `ef_dora`  | femenina |
| `em_alex`  | masculina |
| `em_santa` | masculina |

## Latencia medida en este equipo (CPU)

Frase de prueba (~5 s de audio), petición HTTP completa:

| Voz      | Tiempo |
|----------|--------|
| `ef_dora`  | 2.29 s |
| `em_alex`  | 2.60 s |
| `em_santa` | 1.82 s |

Nota: son mediciones puntuales, no benchmarks. En un i7 antiguo el proyecto reporta ~3.5 s al primer chunk y <1 s en M3 Pro.

## Uso

```bash
curl -X POST http://localhost:8880/v1/audio/speech \
  -H 'Content-Type: application/json' \
  -d '{"model":"kokoro","input":"Hola mundo","voice":"ef_dora","response_format":"wav"}' \
  -o salida.wav
```

Python (cliente OpenAI):

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8880/v1", api_key="not-needed")
with client.audio.speech.with_streaming_response.create(
    model="kokoro", voice="ef_dora", input="Hola mundo"
) as response:
    response.stream_to_file("salida.mp3")
```

## GPU (pendiente / opcional)

Hay una GTX 1650 Ti (4 GB) pero **no está instalado `nvidia-container-toolkit`**, así que Docker no puede usar la GPU todavía. La imagen GPU sería `ghcr.io/remsky/kokoro-fastapi-gpu:latest` (`docker/gpu` + `--gpus all`). 4 GB de VRAM deberían bastar para Kokoro-82M, pero hay que instalar el toolkit (requiere sudo) y validar.

## Interfaz de prueba (web-demo)

UI mínima para probar el anuncio con nombre + clínica y medir tiempos.

```bash
cd web-demo
./start.sh            # http://127.0.0.1:8091/
PORT=8090 ./start.sh  # si el 8090 está libre
```

> `8090` está ocupado por `hro-keycloak` en este equipo, por eso la interfaz usa `8091`.

Mide: tiempo del servidor, tiempo total, inicio de reproducción y tamaño del audio. Voces: `ef_dora`, `em_alex`, `em_santa`.
