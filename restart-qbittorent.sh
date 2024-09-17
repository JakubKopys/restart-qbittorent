#!/bin/bash

# Script that restarts qbittorent docker container, when gluetun disconnects and reconnects
# otherwise, qbitorrent looses connection

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

is_gluetun_running() {
  docker ps --filter "name=gluetun" --filter "status=running" --format '{{.Names}}' | grep -w "gluetun" > /dev/null 2>&1
}

wait_for_gluetun() {
  log_message "Waiting for the 'gluetun' container to start..."
  until is_gluetun_running; do
    sleep 10
  done
  log_message "'gluetun' container is running."
}

while true; do
  wait_for_gluetun

  log_message "Listening to 'gluetun' logs..."
  docker logs -f -n 0 gluetun | while read line; do
      # Check if the line contains "ip getter"
      if [[ "$line" == *"ip getter"* ]]; then
          log_message "Detected 'ip getter' event. Restarting qbittorrent container..."

          # Restart the qbittorrent container
          if docker restart qbittorrent; then
              log_message "qbittorrent container restarted successfully."
          else
              log_message "Failed to restart qbittorrent container."
          fi
      fi
  done
  if [ $? -ne 0 ]; then
    log_message "'gluetun' container has stopped or an error occurred."
  fi

  log_message "Restarting log monitoring..."
  sleep 2
done