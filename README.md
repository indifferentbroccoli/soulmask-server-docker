# Soulmask Server Docker

![marketing_assets_banner](https://github.com/user-attachments/assets/b8b4ae5c-06bb-46a7-8d94-903a04595036)
[![GitHub License](https://img.shields.io/github/license/indifferentbroccoli/soulmask-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/soulmask-server-docker/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/indifferentbroccoli/soulmask-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/soulmask-server-docker/releases)
[![GitHub Repo stars](https://img.shields.io/github/stars/indifferentbroccoli/soulmask-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/soulmask-server-docker)
[![Discord](https://img.shields.io/discord/798321161082896395?style=for-the-badge&label=Discord&labelColor=5865F2&color=6aa84f)](https://discord.gg/indifferentbroccoli)
[![Docker Pulls](https://img.shields.io/docker/pulls/indifferentbroccoli/soulmask-server-docker?style=for-the-badge&color=6aa84f)](https://hub.docker.com/r/indifferentbroccoli/soulmask-server-docker)

Game server hosting

Fast RAM, high-speed internet

Eat lag for breakfast

[Try our Soulmask server hosting free for 2 days!](https://indifferentbroccoli.com/soulmask-server-hosting)

## Soulmask Server Docker

Docker image for running a [Soulmask](https://store.steampowered.com/app/2646460/Soulmask/) dedicated server.

Supports Soulmask **1.0** including the **Shifting Sands** DLC.

---

## Quick Start

1. Copy `.env.example` to `.env` and edit your settings:
   ```bash
   cp .env.example .env
   ```

2. Start the server:
   ```bash
   docker compose up -d
   ```

The server files are downloaded automatically on first start and updated on every restart (unless `UPDATE_ON_START=false`).

---

## Ports

| Port  | Protocol | Description                     |
|-------|----------|---------------------------------|
| 8777  | UDP      | Game port                       |
| 27015 | UDP      | Steam query port                |
| 18888 | TCP      | Telnet port                     |

---

## Environment Variables

| Variable          | Default                    | Description                                                                                   |
|-------------------|----------------------------|-----------------------------------------------------------------------------------------------|
| `PUID`            | 1000                       | **Required.** User ID to run as                                                               |
| `PGID`            | 1000                       | **Required.** Group ID to run as                                                              |
| `SERVER_NAME`     | `Soulmask Dedicated Server`| The server name shown in the in-game server browser                                           |
| `SERVER_PASSWORD` | *(empty)*                  | Server join password. Leave empty for a public server                                         |
| `ADMIN_PASSWORD`  | *(empty)*                  | Admin (GM) password. Use `gm key <password>` in the in-game console to elevate privileges     |
| `GAME_MODE`       | `pve`                      | `pve` or `pvp`                                                                                |
| `GAME_WORLD`      | `Level01_Main`             | Map to load. See [Map Selection](#map-selection) below                                        |
| `MAX_PLAYERS`     | `20`                       | Maximum concurrent players (game cap: 70)                                                     |
| `GAME_PORT`       | `8777`                     | UDP port for client connections                                                               |
| `QUERY_PORT`      | `27015`                    | UDP port for Steam server browser queries                                                     |
| `ECHO_PORT`       | `18888`                    | TCP port for Telnet maintenance (`telnet <host> 18888`)                                       |
| `LISTEN_ADDRESS`  | `0.0.0.0`                  | Network interface the server listens on                                                       |
| `SAVING_INTERVAL` | `600`                      | Seconds between writing game objects to the database                                          |
| `BACKUP_INTERVAL` | `900`                      | Seconds between flushing the database to disk                                                 |
| `UPDATE_ON_START` | `true`                     | Set to `false` to skip the Steam update check on container start                              |

---

## Map Selection

Use the `GAME_WORLD` variable to choose the map:

| Value           | Map                                     |
|-----------------|-----------------------------------------|
| `Level01_Main`  | Cloud Mist Forest (base game, default)  |
| `Level01_Main`  | Shifting Sands (DLC, April 10 2026)     |

### Shifting Sands DLC (v1.0)

For **cross-map play** on private servers, run two separate container instances — one for
each map — using different port mappings. Both must share the same server password.

---

## Game Maintenance (Echo Port)

Connect via Telnet for live server administration:

```bash
telnet <server-ip> 18888
```

Useful commands:
- `help` — list available commands
- `saveworld 1` — force save the world
- `quit 30` — graceful shutdown after 30 seconds

---