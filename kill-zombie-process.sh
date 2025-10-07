#!/bin/bash
echo "Checking for zombie processes..."

# List zombie processes
zombies=$(ps -eo pid,ppid,state,comm | awk '$3=="Z"')

if [ -z "$zombies" ]; then
    echo "No zombie processes found."
else
    echo "Zombie processes found:"
    echo "$zombies"
    
# Extract and kill parent process IDs (PPID)
    echo "$zombies" | awk '{print $2}' | tail -n +2 | while read ppid; do
        echo "Killing parent process ID: $ppid"
        sudo kill -HUP "$ppid"
    done
fi
