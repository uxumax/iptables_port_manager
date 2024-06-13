#!/bin/bash

# Define files path
PORTS_FILE="/tmp/ports_to_open.list"
LOG_FILE="/var/log/port_manager.log"
OPEN_PORT_DELAY=1  # Check $PORTS_FILE every 1 second
CLOSE_PORT_DELAY=10  # Close port after opening after 10 seconds

# Ensure the script is run with sudo or root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo"
  exit
fi

log() {
  message=$1
  echo "[$(date)] $message" >> $LOG_FILE
}

# Function to open a port using iptables
open_port() {
  local port=$1
  iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
  log "Opened port $port"
}

# Function to remove a iptables rule with openned port
close_port_with_delay() {
  local port=$1
  sleep $CLOSE_PORT_DELAY
  iptables -D INPUT -p tcp --dport "$port" -j ACCEPT
  log "Closed port $port"
}

# Function to get first line of file and preserve file ownership bcs it run via root
pop_first_line_of_file() {
    local file="$1"

    first_line=$(head -n 1 "$file")
    
    # Get the current ownership of the file
    local current_user
    local current_group
    current_user=$(stat -c "%U" "$file")
    current_group=$(stat -c "%G" "$file")

    # Remove the first line from the file using a temporary file
    tail -n +2 "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    # Restore the original ownership
    chown "$current_user:$current_group" "$file"
    
    # Return-like first_line
    echo $first_line
}

# Function for the first loop
main_loop() {
    while true; do
        # Check if the file exists and is not empty
        if [ -s "$PORTS_FILE" ]; then
          port=$(pop_first_line_of_file "$PORTS_FILE") 
          log "Have port to open $port"
          open_port $port
          close_port_with_delay $port &
        # else
        #   log "No ports to open"
        fi
        sleep $OPEN_PORT_DELAY
    done
}

main_loop
