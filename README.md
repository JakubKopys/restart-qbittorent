# Restart qBitTorrent
qbittorrent docker container looses connection after gluetun's "self-healing" reconnects.
This script solves this problem, by restarting the qbittorent container when that happens

This script waits for "gluetun" docker container, and if it's up, it watches its logs. 
When Gluetun reconnects, it restarts the qBittorrent container.

Context:
- https://github.com/qdm12/gluetun/issues/504#issuecomment-893632195
- https://www.reddit.com/r/qBittorrent/comments/115ef17/seeding_and_downloading_stopped_working_when/

None of the solutions worked well for me. 
Health-based restarts on qbitorrent don't work - qbittorrent regains the internet connectivity, but seeding and downloading still doesn't work.
Instead of relying on the health check, this script listens to Gluetun's Logs, and restarts qbittorrent container after Gluetun successfuly restarts itself.

## How to use it

### Docker

The easiest way to use this script is to use the [docker-compose.yml](https://github.com/JakubKopys/restart-qbittorent/blob/main/docker-compose.yml)

### Run on Host - Systemd
On Linux, you can register it as a systemd service:

1. Save the `restart-qbittorrent.sh` file on your disk, and make it exectuable:
    `chmod +x restart-qbittorent.sh`
2. Add the systemd service file:

    `sudoedit /etc/systemd/system/restart-qbittorrent.service`

    And use those contents:
    ```
    [Unit]
    Description=Restarts qBittorent Container when Gluetun conainer disconnects and reconnents
    After=docker.service
    BindsTo=docker.service
    ReloadPropagatedFrom=docker.service

    [Service]
    Type=simple
    ExecStart=/path/to/restart-qbittorrent.sh
    KillMode=process
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    ```
    Remember to replace `/path/to/restart-qbittorrent.sh` with your path.
3. Reload systemd and start the service
    ```
    sudo systemctl daemon-reload
    sudo systemctl start restart-qbittorrent.service
    sudo systemctl status restart-qbittorrent.service
    ```