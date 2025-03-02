#!/bin/bash

# Define the input/output directory
INPUT_OUTPUT_DIR="/mnt/data/ytdl-sub"

# Infinite loop to check for new .info.json files
while true; do
    echo "Checking for new .info.json files at $(date)"

    # Find all .info.json files and process them with ytdl-nfo
    find "$INPUT_OUTPUT_DIR" -name "*.info.json" -type f | while read -r json_file; do
        # Check if the corresponding .nfo file already exists
        nfo_file="${json_file%.info.json}.nfo"
        if [[ ! -f "$nfo_file" ]]; then
            echo "Processing $json_file..."
            ytdl-nfo "$json_file"
        else
            echo "Skipping $json_file (NFO file already exists)."
        fi
    done

    echo "Finished processing at $(date)"

    # Wait for 3 minutes before checking again
    sleep 180
done
