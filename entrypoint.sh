#!/bin/bash
set -e


export RCLONE_CACHE_DIR="/tmp/rclone-cache"
export RESTIC_CACHE_DIR="/home/resticuser/.cache/restic"

mkdir -p /home/resticuser/.config/rclone
mkdir -p $RESTIC_CACHE_DIR


# --- Validazione Variabili ---
: "${RESTIC_REPOSITORY:?Variabile RESTIC_REPOSITORY non impostata}"
: "${RESTIC_PASSWORD:?Variabile RESTIC_PASSWORD non impostata}"
: "${AWS_ACCESS_KEY_ID:?Variabile AWS_ACCESS_KEY_ID non impostata}"
: "${AWS_SECRET_ACCESS_KEY:?Variabile AWS_SECRET_ACCESS_KEY non impostata}"

# Variabili opzionali con default
SOURCE_PATH=${SOURCE_PATH:-"/data"}
RCLONE_REMOTE_NAME="s3-src"

---
### 2. Configurazione Dinamica Rclone ###
# Configuriamo il remote sorgente S3 tramite variabili d'ambiente 
# per evitare di montare un file rclone.conf esterno.

export RCLONE_CONFIG_S3_SRC_TYPE=s3
export RCLONE_CONFIG_S3_SRC_PROVIDER=AWS
export RCLONE_CONFIG_S3_SRC_ACCESS_KEY_ID=$SRC_S3_ACCESS_KEY
export RCLONE_CONFIG_S3_SRC_SECRET_ACCESS_KEY=$SRC_S3_SECRET_ACCESS_KEY
export RCLONE_CONFIG_S3_SRC_REGION=$SRC_S3_REGION
export RCLONE_CONFIG_S3_SRC_ENDPOINT=$SRC_S3_ENDPOINT

---
### 3. Logica di Esecuzione ###

echo "--- [1/3] Init restci repository ---"
restic init || echo "Repository already initialized or connection error."

echo "--- [2/3] Sincronizzazione dati da S3 Sorgente a Locale ---"
# Usiamo rclone per clonare il bucket S3 nella cartella locale prima dello snapshot
rclone sync $RCLONE_REMOTE_NAME:$SRC_S3_BUCKET $SOURCE_PATH --progress

echo "--- [3/3] Creazione Snapshot con Restic ---"
restic backup $SOURCE_PATH --tag automated-backup

# Pulizia vecchi snapshot (Retention policy)
if [ -n "$KEEP_LAST" ]; then
    echo "--- Pulizia vecchi snapshot ---"
    restic forget --keep-last $KEEP_LAST --prune
fi

echo "Operazione completata con successo!"
exec "$@"