FROM alpine:latest

# Installazione pacchetti e creazione utente
RUN apk add --no-cache rclone restic bash ca-certificates && \
    addgroup -S resticgroup && adduser -S resticuser -G resticgroup

# Creiamo le directory per i dati e i log
RUN mkdir -p /data /tmp/rclone-cache && \
    chown -R resticuser:resticgroup /data /tmp/rclone-cache

# Copia dello script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Passiamo all'utente non privilegiato
USER resticuser
WORKDIR /home/resticuser

ENTRYPOINT ["entrypoint.sh"]