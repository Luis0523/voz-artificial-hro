# Kokoro-FastAPI — despliegue en servidor

Carpeta autocontenida para levantar el servicio en un servidor. **No se levanta nada
automáticamente**; solo quedan los archivos listos.

```
deploy/
├── docker-compose.yml   # servicio + límites de CPU/RAM (editar ahí)
├── .env.example         # copiar a .env y ajustar valores
├── save-image.sh        # exportar imagen para servidor sin internet
└── load-image.sh        # cargar la imagen en el servidor
```

## 1. Configurar

```bash
cd deploy
cp .env.example .env
# edita .env -> KOKORO_CPUS, KOKORO_MEM_LIMIT, KOKORO_PORT...
```

Los límites también se pueden tocar directamente en `docker-compose.yml`, en la
sección marcada con:

```
# >>>  LÍMITES DE CPU Y RAM: EDITA ESTA SECCIÓN  <<<
```

Valores de referencia para Kokoro-82M en CPU:

| CPU | RAM | Uso |
|-----|-----|-----|
| 2   | 2 GB | mínimo, anuncios cortos |
| 4   | 4 GB | recomendado con concurrencia |
| 8   | 8 GB | holgado |

## 2a. Servidor CON internet

```bash
docker compose pull       # descarga la imagen fijada por digest
docker compose up -d
```

## 2b. Servidor SIN internet

En esta máquina (donde ya está la imagen):

```bash
./save-image.sh           # genera kokoro-tts-cpu-image.tar (~3.3 GB)
```

Copiar el `.tar` al servidor, junto con esta carpeta, y allí:

```bash
./load-image.sh kokoro-tts-cpu-image.tar
docker compose up -d
# Si no encuentra el digest:
# KOKORO_IMAGE=kokoro-tts:local docker compose up -d
```

## 3. Verificar

```bash
curl http://127.0.0.1:8880/health
curl http://127.0.0.1:8880/v1/audio/voices
curl -X POST http://127.0.0.1:8880/v1/audio/speech \
  -H 'Content-Type: application/json' \
  -d '{"model":"kokoro","input":"Hola","voice":"ef_dora","response_format":"wav"}' \
  -o prueba.wav
```

- API: `http://IP_DEL_SERVIDOR:8880/v1`
- Docs: `http://IP_DEL_SERVIDOR:8880/docs`
- Sin API key.

## Notas

- Los pesos y las voces van **dentro de la imagen**: no se descarga nada al arrancar.
- La imagen está fijada por digest para que un `pull` futuro no cambie la versión.
- `restart: unless-stopped` + healthcheck ya configurados.
- Si el puerto 8880 ya está ocupado (por la demo actual), cámbialo en `.env`
  (`KOKORO_PORT`) o para el contenedor de la demo antes de desplegar.
- La interfaz `web-demo/` no forma parte de este despliegue; es solo para pruebas.
- Para GPU NVIDIA haría falta otra imagen (`kokoro-fastapi-gpu`) y
  `nvidia-container-toolkit`; este compose es CPU.
