#!/bin/bash
# Set the working directory to the home directory of the current user
cd "$HOME/uptime-kuma" || exit

# SFTP connection details
SFTP_SERVER="ssh.strato.de"
SFTP_USER="ribeiromaier.de"
SFTP_KEY="~/.ssh/id_rsa"
SFTP_DIR="uptimekuma-backup"

# Backup directory
BACKUP_DIR_HOST="data/"

# Timestamp for backup file name
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Generate backup file name
BACKUP_FILE="uptimekuma-dump-$TIMESTAMP.tar.gz"

tar -czvf $BACKUP_FILE $BACKUP_DIR_HOST


# Transfer the backup file to the remote server using SFTP
sftp -o "IdentityFile=$SFTP_KEY" "$SFTP_USER@$SFTP_SERVER" << EOF
put "$BACKUP_FILE" "$SFTP_DIR"
bye
EOF

# Check if the transfer was successful
if [ $? -eq 0 ]; then
    echo "Backup file transferred successfully."
else
    echo "Failed to transfer backup file."
fi