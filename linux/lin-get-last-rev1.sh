#!/bin/bash

# --- Tunable Parameters ---
SERVERS_FILE="servers.txt"
SSH_USER="security"
SSH_PASSWORD="security"
OUTPUT_DIR="./"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
INPUT_FILE="$OUTPUT_DIR/servers-last-$TIMESTAMP.csv"
# --------------------------

mkdir -p "$OUTPUT_DIR"
echo "ComputerName,Hostname,User,TTY,RemoteHost,LoginTime,LogoutTime,Duration" > "$INPUT_FILE"

while IFS= read -r server; do
    echo "Collecting from $server..."

    hostname=$(sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no \
        $SSH_USER@$server "hostname" 2>/dev/null)
    echo "  Hostname: $hostname"

    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@$server \
        'last -F 2>/dev/null | grep -v "^$" | grep -v "wtmp begins"' 2>/dev/null | \
	awk -v host="$server" -v hostname="$hostname" '
            {
            	user=$1; tty=$2; rhost=$3
	        logintime=$4" "$5" "$6" "$7" "$8
         	logouttime=$10" "$11" "$12" "$13" "$14
            	duration=$15
            	print host "," hostname "," user "," tty "," rhost "," logintime "," logouttime "," duration
        }

    ' >> "$INPUT_FILE"

    echo "  Done: $(grep -c "^$server" "$INPUT_FILE") entries collected"

done < "$SERVERS_FILE"

echo "Collection complete: $INPUT_FILE"
