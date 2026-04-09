#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/steam/server/functions.sh"

SERVER_FILES="/home/steam/server-files"

cd "$SERVER_FILES" || exit

LogAction "Starting Soulmask Dedicated Server"

GAME_PORT="${GAME_PORT:-8777}"
QUERY_PORT="${QUERY_PORT:-27015}"
ECHO_PORT="${ECHO_PORT:-18888}"
GAME_WORLD="${GAME_WORLD:-Level01_Main}"
GAME_MODE="${GAME_MODE:-pve}"
if [ "$GAME_MODE" != "pve" ] && [ "$GAME_MODE" != "pvp" ]; then
    LogError "GAME_MODE must be 'pve' or 'pvp'. Got: '${GAME_MODE}'"
    exit 1
fi

MAX_PLAYERS="${MAX_PLAYERS:-20}"
SERVER_NAME="${SERVER_NAME:-Soulmask Dedicated Server}"
LISTEN_ADDRESS="${LISTEN_ADDRESS:-0.0.0.0}"
BACKUP_INTERVAL="${BACKUP_INTERVAL:-900}"
SAVING_INTERVAL="${SAVING_INTERVAL:-600}"

# Locate the server launch script
EXEC="$SERVER_FILES/WSServer.sh"

if [ ! -f "$EXEC" ]; then
    LogError "Could not find server executable at: $EXEC"
    exit 1
fi

chmod +x "$EXEC"

LAUNCH_ARGS="${GAME_WORLD} \
-server \
-SILENT \
-SteamServerName=\"${SERVER_NAME}\" \
-${GAME_MODE} \
-MaxPlayers=${MAX_PLAYERS} \
-backup=${BACKUP_INTERVAL} \
-saving=${SAVING_INTERVAL} \
-log \
-UTF8Output \
-MULTIHOME=${LISTEN_ADDRESS} \
-Port=${GAME_PORT} \
-QueryPort=${QUERY_PORT} \
-EchoPort=${ECHO_PORT} \
-online=Steam \
-forcepassthrough"

if [ -n "${SERVER_PASSWORD}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -PSW=\"${SERVER_PASSWORD}\""
    LogInfo "Server password:  [set]"
else
    LogWarn "SERVER_PASSWORD is not set — server is open to the public"
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -adminpsw=\"${ADMIN_PASSWORD}\""
    LogInfo "Admin password:   [set]"
else
    LogWarn "ADMIN_PASSWORD is not set"
fi

if [ -n "${SERVER_ID}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -serverid=${SERVER_ID}"
    LogInfo "Server ID:        ${SERVER_ID}"
fi

if [ -n "${CROSS_SERVER_MAIN_PORT}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -mainserverport=${CROSS_SERVER_MAIN_PORT}"
    LogInfo "Cross-server:     main server on port ${CROSS_SERVER_MAIN_PORT}"
fi

if [ -n "${CROSS_SERVER_CONNECT}" ]; then
    LAUNCH_ARGS="${LAUNCH_ARGS} -clientserverconnect=${CROSS_SERVER_CONNECT}"
    LogInfo "Cross-server:     connecting to main at ${CROSS_SERVER_CONNECT}"
fi

eval exec "$EXEC" "$LAUNCH_ARGS"
