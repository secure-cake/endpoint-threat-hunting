#!/bin/bash

# --- Tunable Parameters ---
SERVERS_FILE="servers.txt"
SSH_USER="security"
SSH_PASSWORD="security"
OUTPUT_DIR="./"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
INPUT_FILE="$OUTPUT_DIR/servers-sockets-$TIMESTAMP.csv"
# --------------------------

mkdir -p "$OUTPUT_DIR"
echo "ComputerName,Hostname,Protocol,LocalAddress,RemoteAddress,State,PID,ProcessName" > "$INPUT_FILE"

while IFS= read -r server; do
    echo "Collecting from $server..."

    hostname=$(sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no \
        $SSH_USER@$server "hostname" 2>/dev/null)
    echo "  Hostname: $hostname"

    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@$server \
        "sudo netstat -tnp 2>/dev/null | grep ESTABLISHED" 2>/dev/null | \
    awk -v host="$server" -v hostname="$hostname" '
        {
            proto=$1; laddr=$4; raddr=$5; state=$6
            split($7, proc, "/")
            pid=proc[1]; pname=proc[2]
            print host "," hostname "," proto "," laddr "," raddr "," state "," pid "," pname
        }
    ' >> "$INPUT_FILE"

    echo "  Done: $(grep -c "^$server" "$INPUT_FILE") sockets collected"

done < "$SERVERS_FILE"

echo "Collection complete: $INPUT_FILE"
