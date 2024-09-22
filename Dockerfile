FROM alpine:latest

RUN apk add --no-cache docker-cli bash

COPY restart-qbittorrent.sh /usr/local/bin/restart-qbittorrent.sh

RUN chmod +x /usr/local/bin/restart-qbittorrent.sh

CMD ["/usr/local/bin/restart-qbittorrent.sh"]