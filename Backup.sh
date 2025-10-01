#!/bin/bash

# Configuration
SOURCE_DIR="/path/to/source/directory"  # Directory to back up
REMOTE_SERVER="user@remote_server.com"  # Remote server address
REMOTE_DIR="/path/to/remote/backup/directory"  # Remote backup destination
SSH_KEY="/path/to/ssh/key"  # Path to SSH private key
BACKUP_LOG="backup_log.txt"  # Log file for backup reports
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$BACKUP_LOG"
}

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create backup archive
log_message "Starting backup process"
if tar -czf "$ARCHIVE_NAME" -C "$SOURCE_DIR" . 2>> "$BACKUP_LOG"; then
    log_message "Backup archive created: $ARCHIVE_NAME"
else
    log_message "ERROR: Failed to create backup archive"
    exit 1
fi

# Transfer backup to remote server
if scp -i "$SSH_KEY" "$ARCHIVE_NAME" "${REMOTE_SERVER}:${REMOTE_DIR}/" 2>> "$BACKUP_LOG"; then
    log_message "Successfully transferred $ARCHIVE_NAME to $REMOTE_SERVER:$REMOTE_DIR"
else
    log_message "ERROR: Failed to transfer backup"
    rm -f "$ARCHIVE_NAME"
    exit 1
fi

# Clean up local archive
if rm -f "$ARCHIVE_NAME"; then
    log_message "Cleaned up local archive: $ARCHIVE_NAME"
else
    log_message "ERROR: Failed to clean up local archive"
    exit 1
fi

log_message "Backup process completed successfully"
