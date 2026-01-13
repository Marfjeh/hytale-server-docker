# Hytale Server Docker

A simple Docker container for running a Hytale dedicated server. This automatically downloads and updates the server files, so you can get started in just a few minutes.

## Quick Start with Docker

Run your server with:

```bash
docker run -d \
  --name hytale \
  -p 5520:5520/udp \
  -v ./data:/hytale-server \
  ghcr.io/vngdv/hytale-server-docker:latest
```

Your server will be running on port 5520. All server data is stored in the `./data` folder.

**Note:** On first run, follow the browser authentication prompt that appears in the container logs.

## Using Docker Compose

Create a `compose.yaml` file:

```yaml
services:
  hytale:
    image: ghcr.io/vngdv/hytale-server-docker:latest
    container_name: hytale
    ports:
      - "5520:5520/udp"
    volumes:
      - ./data:/hytale-server
    environment:
      AUTO_UPDATE: true
      SERVER_NAME: My Hytale Server
      MAX_PLAYERS: 10
    restart: unless-stopped
```

Start it with:

```bash
docker compose up -d
```

**Note:** On first run, check the logs with `docker compose logs -f` and follow the browser authentication prompt.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BIND_ADDRESS` | The IP and port the server listens on | `0.0.0.0:5520` |
| `AUTO_UPDATE` | Automatically check for updates on startup | `false` |
| `SERVER_NAME` | Name of your server | _(none)_ |
| `MOTD` | Message of the day shown to players | _(none)_ |
| `PASSWORD` | Server password (leave empty for no password) | _(none)_ |
| `MAX_PLAYERS` | Maximum number of players allowed | _(none)_ |
| `MAX_VIEW_RADIUS` | Maximum view distance for players | _(none)_ |
| `DEFAULT_WORLD` | Default world to load | _(none)_ |
| `DEFAULT_GAMEMODE` | Default game mode for new players | _(none)_ |
| `ENABLE_BACKUPS` | Enable automatic backups | `false` |
| `BACKUP_DIR` | Directory to store backups | `/hytale-server/backups` |
| `BACKUP_FREQUENCY` | Backup interval in minutes | `30` |
| `DISABLE_SENTRY` | Disable Sentry error reporting | `false` |
