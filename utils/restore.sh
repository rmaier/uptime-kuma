#!/bin/bash
# Set the working directory to the home directory of the current user
cd "$HOME/uptime-kuma" || exit

# SFTP connection details
SFTP_SERVER="ssh.strato.de"
SFTP_USER="ribeiromaier.de"
SFTP_KEY="~/.ssh/id_rsa"
SFTP_DIR="uptimekuma-backup"

# Directory where backups will be restored
RESTORE_DIR="./"

# Temporary download directory
TMP_DIR="/tmp/backup_restore/"
mkdir -p "$TMP_DIR"

# SSH to the SFTP server and list backup files, sort them, and pick the newest
NEWEST_BACKUP_FILE=$(ssh -i "$SFTP_KEY" "$SFTP_USER@$SFTP_SERVER" "ls -t $SFTP_DIR/uptimekuma-dump-*.tar.gz | head -n1")

# Check if a newest file was found
if [ -z "$NEWEST_BACKUP_FILE" ]; then
    echo "No backup files found."
    exit 1
fi

REMOTE_BACKUP_FILE=$(basename "$NEWEST_BACKUP_FILE")
LOCAL_BACKUP_FILE="$TMP_DIR$REMOTE_BACKUP_FILE"

# Download the backup file from the remote server using SCP
scp -i "$SFTP_KEY" "$SFTP_USER@$SFTP_SERVER:$SFTP_DIR/$REMOTE_BACKUP_FILE" "$LOCAL_BACKUP_FILE"

# Check if the download was successful
if [ ! -f "$LOCAL_BACKUP_FILE" ]; then
    echo "Failed to download backup file."
    exit 1
fi

echo "Backup file ('$REMOTE_BACKUP_FILE') downloaded successfully."

# Restore the backup
tar -xzvf "$LOCAL_BACKUP_FILE" -C "$RESTORE_DIR"

# Check if the tar command was successful
if [ $? -eq 0 ]; then
    echo "Backup restored successfully."
else
    echo "Failed to restore backup."
fi

# Cleanup
rm -rf "$TMP_DIR"