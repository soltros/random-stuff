#!/bin/bash

# Define the playlist URL and output directory
PLAYLIST_URL="https://www.youtube.com/playlist?list=PLSrj4gA59MSAX411oW_sI6Sh0DmPyg2mw"
OUTPUT_DIR="/mnt/data/ytdl-sub"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Infinite loop to check the playlist every 3 minutes
while true; do
    echo "Starting download at $(date)"

    # Use yt-dlp to download new videos from the playlist
    yt-dlp \
        --download-archive "$OUTPUT_DIR/downloaded.txt" \
        --no-overwrites \
        --write-info-json \
        --write-thumbnail \
        --convert-thumbnails jpg \
        --format "bestvideo+bestaudio/best" \
        --merge-output-format "mp4" \
        --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
        --restrict-filenames \
        --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
        --sleep-interval 5 \
        "$PLAYLIST_URL"

    echo "Download completed at $(date)"

    # Wait for 3 minutes before checking the playlist again
    sleep 180
done
