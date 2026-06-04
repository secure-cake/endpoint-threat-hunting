#!/bin/bash

# --- Tunable Parameters ---
SERVERS_FILE="servers.txt"
SSH_USER="security"
SSH_PASSWORD="security"
OUTPUT_DIR="./"
TIMESTAMP=$(date +"%Y%m%d_%H%M")
INPUT_FILE="$OUTPUT_DIR/servers-processes-$TIMESTAMP.csv"
# --------------------------

mkdir -p "$OUTPUT_DIR"
echo "Hostname,ProcessUser,PID,CPU,MEM,TTY,State,Started,Command" > "$INPUT_FILE"

while IFS= read -r server; do
    echo "Collecting from $server..."
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no $SSH_USER@$server \
        'echo $(hostname); ps aux --no-headers' 2>/dev/null | \
    awk -v host="$server" '
        NR==1 { hostname=$0; next }
        {
            user=$1; pid=$2; cpu=$3; mem=$4
            tty=$7; state=$8; started=$9
            cmd=""
            for(i=11;i<=NF;i++) cmd=cmd $i " "
            gsub(/,/,";",cmd)
            print hostname "," user "," pid "," cpu "," mem "," tty "," state "," started "," cmd
        }
    ' >> "$INPUT_FILE"

    echo "  Done: $(grep -c "^$server" "$INPUT_FILE") processes collected"

done < "$SERVERS_FILE"

echo "Collection complete: $INPUT_FILE"

