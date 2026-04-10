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

### Single-map server

1. Copy `.env.example` to `.env` and edit your settings:
   ```bash
   cp .env.example .env
   ```

2. Remove the `soulmask-map2` service from `docker-compose.yml`.

3. Start the server:
   ```bash
   docker compose up -d
   ```

### Cross-map server (Cloud Mist Forest + Shifting Sands)

See [Cross-Map Setup](#cross-map-setup) below.

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
| `UPDATE_ON_START`         | `true`                     | Set to `false` to skip the Steam update check on container start                                                  |
| `SERVER_ID`               | *(unset)*                  | Unique integer ID for this server instance. Required for cross-map; each server must have a different value       |
| `CROSS_SERVER_MAIN_PORT`  | *(unset)*                  | **Main server only.** Broadcast port child servers connect to (e.g. `20000`)                                      |
| `CROSS_SERVER_CONNECT`    | *(unset)*                  | **Child server only.** `host:port` of the main server's broadcast port (e.g. `soulmask-map1:20000`)               |

---

## Map Selection

Use the `GAME_WORLD` variable to choose the map:

| Value               | Map                                    |
|---------------------|----------------------------------------|
| `Level01_Main`      | Cloud Mist Forest (base game, default) |
| `DLC_Level01_Main`  | Shifting Sands (DLC, April 10 2026)    |

---

## Cross-Map Setup

Cross-map lets players travel between Cloud Mist Forest and Shifting Sands on the same private server cluster. It requires two container instances: a **main server** (hosts the shared character database) and a **child server** (connects back to the main).

### How it works

- The main server stores character data in `Saved\Accounts\account.db` (separate from world data).
- The child server registers itself with the main via a broadcast port (`-clientserverconnect`).
- Both servers must use the **same `SERVER_PASSWORD`** — mismatched passwords will reject cross-server logins.
- Each server must have a **unique `SERVER_ID`**.

### Setup steps

1. Copy the example env files:
   ```bash
   cp .env.map1.example .env.map1
   cp .env.map2.example .env.map2
   ```

2. Edit both files and set a strong, matching `SERVER_PASSWORD` on each.

3. Start both servers:
   ```bash
   docker compose up -d
   ```

4. Both servers appear in the Steam server browser as separate entries. Players connect to whichever map they want to play; their character transfers automatically when they use the in-game cross-server travel menu.

### Port reference

| Server | Game port | Query port | Echo port |
|--------|-----------|------------|-----------|
| Map 1 (Cloud Mist Forest) | 8777/udp | 27015/udp | 18888/tcp |
| Map 2 (Shifting Sands)    | 8778/udp | 27016/udp | 18889/tcp |

The cross-server broadcast port (`20000`) is only used for inter-container communication and does not need to be forwarded in your firewall/router unless the two servers run on **different physical hosts**.

### Multi-host deployment

If map1 and map2 run on separate machines:

1. Expose port `20000` on the main server host (firewall + router).
2. In `.env.map2`, set `CROSS_SERVER_CONNECT` to the main server's public IP:
   ```
   CROSS_SERVER_CONNECT=<main-server-public-ip>:20000
   ```
3. In `docker-compose.yml` on the main server host, publish the broadcast port:
   ```yaml
   ports:
     - 20000:20000/udp
   ```

### Copying character data manually

The game ships a CLI tool for copying character records between databases:

```
WS\Plugins\DBAgent\ThirdParty\Binaries\CopyRoles.exe
```

Usage is documented in `Readme.txt` in the same directory. This is useful for migrating characters from a standalone server into a cross-map cluster.

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