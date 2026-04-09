#!/bin/bash

#================
# Log Definitions
#================
export LINE='\n'                        # Line Break
export RESET='\033[0m'                  # Text Reset
export WhiteText='\033[0;37m'           # White

# Bold
export RedBoldText='\033[1;31m'         # Red
export GreenBoldText='\033[1;32m'       # Green
export YellowBoldText='\033[1;33m'      # Yellow
export CyanBoldText='\033[1;36m'        # Cyan
#================
# End Log Definitions
#================

LogInfo() {
  Log "$1" "$WhiteText"
}
LogWarn() {
  Log "$1" "$YellowBoldText"
}
LogError() {
  Log "$1" "$RedBoldText"
}
LogSuccess() {
  Log "$1" "$GreenBoldText"
}
LogAction() {
  Log "$1" "$CyanBoldText" "====" "===="
}
Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET$LINE" "$prefix$message$suffix"
}

install() {
  LogAction "Starting server install"
  LogInfo "Installing Soulmask Dedicated Server (App ID: 3017300)"

  /depotdownloader/DepotDownloader \
    -app 3017300 \
    -dir /home/steam/server-files \
    -validate

  LogSuccess "Server install complete"
}

# Attempt to shutdown the server gracefully via SIGTERM.
# Returns 0 if the process exited within 60 seconds.
# Returns 1 if the process did not exit (caller should force-kill).
shutdown_server() {
  local return_val=0
  LogAction "Attempting graceful server shutdown"

  local pid
  pid=$(pgrep -f "WSServer-Linux-Shipping")

  if [ -n "$pid" ]; then
    kill -SIGTERM "$pid"

    local count=0
    while [ $count -lt 60 ] && kill -0 "$pid" 2>/dev/null; do
      sleep 1
      count=$((count + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
      LogWarn "Server did not shutdown gracefully within 60 seconds, forcing shutdown"
      return_val=1
    else
      LogSuccess "Server shutdown gracefully"
    fi
  else
    LogWarn "Server process not found"
    return_val=1
  fi

  return "$return_val"
}
