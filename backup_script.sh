#!/bin/bash

# Verzeichnis für lokale Backups
LOCAL_BACKUP_DIR="/root"
# Verzeichnis der Website
WEB_DIR="/var/www/html"
# MySQL Datenbankinformationen
DB_USER="DB_USER_HERE"
DB_PASS="DB_PASS_HERE"
DB_NAME="DB_NAME_HERE"

# SFTP-Serverinformationen
SFTP_USER="root"
SFTP_HOST="SFTP_HOST_HERE"
SFTP_PORT="22"
REMOTE_BACKUP_DIR="/root"
REMOTE_PASS="REMOTE_PASS_HERE"

# Zeitstempel für Dateinamen
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Backup-Dateinamen
LOCAL_WEB_BACKUP_FILE="$LOCAL_BACKUP_DIR/ftp_$TIMESTAMP.tar.gz"
LOCAL_DB_BACKUP_FILE="$LOCAL_BACKUP_DIR/backup_$TIMESTAMP.sql.gz"
REMOTE_WEB_BACKUP_FILE="$REMOTE_BACKUP_DIR/ftp_$TIMESTAMP.tar.gz"
REMOTE_DB_BACKUP_FILE="$REMOTE_BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

# Sicherung der Website (einschließlich versteckter Dateien)
tar -cpzf "$LOCAL_WEB_BACKUP_FILE" -C "$WEB_DIR" .

# Sicherung der MySQL-Datenbank
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$LOCAL_DB_BACKUP_FILE"

# Funktion zum Löschen alter Backups, nur die neuesten 3 behalten
cleanup_old_backups() {
    local BACKUP_DIR=$1
    local BACKUP_TYPE=$2
    local BACKUP_FILES=($(ls -1tr "$BACKUP_DIR"/*"$BACKUP_TYPE"*))
    local NUM_FILES=${#BACKUP_FILES[@]}
    if (( NUM_FILES > 3 )); then
        local NUM_FILES_TO_DELETE=$(( NUM_FILES - 3 ))
        for (( i=0; i<NUM_FILES_TO_DELETE; i++ )); do
            rm -f "${BACKUP_FILES[$i]}"
        done
    fi
}

# Alte lokale Backups löschen
cleanup_old_backups "$LOCAL_BACKUP_DIR" ".tar.gz"
cleanup_old_backups "$LOCAL_BACKUP_DIR" ".sql.gz"

# Funktion zum Überprüfen der SSH-Verbindung
check_ssh_connection() {
    sshpass -p "$REMOTE_PASS" ssh -o BatchMode=yes -o ConnectTimeout=5 -p "$SFTP_PORT" "$SFTP_USER@$SFTP_HOST" 'exit 0'
    return $?
}

# Übertragen der Backups auf den Remote-Server per SFTP und alte Backups löschen
sftp_upload() {
    local FILE=$1
    local REMOTE_FILE=$2
    expect <<EOF
spawn sftp -oPort=$SFTP_PORT $SFTP_USER@$SFTP_HOST
expect "password:"
send "$REMOTE_PASS\r"
expect "sftp>"
send "put $FILE $REMOTE_FILE\r"
expect "sftp>"
send "bye\r"
expect eof
EOF
}

# Überprüfen der SSH-Verbindung
if check_ssh_connection; then
    echo "SSH-Verbindung erfolgreich. Übertrage Backups..."
    
    # Remote-Backups hochladen
    sftp_upload "$LOCAL_WEB_BACKUP_FILE" "$REMOTE_WEB_BACKUP_FILE"
    sftp_upload "$LOCAL_DB_BACKUP_FILE" "$REMOTE_DB_BACKUP_FILE"
    
    # Remote alte Backups löschen
    sshpass -p "$REMOTE_PASS" ssh -p $SFTP_PORT "$SFTP_USER@$SFTP_HOST" "$(typeset -f); cleanup_old_backups '$REMOTE_BACKUP_DIR' '.tar.gz'"
    sshpass -p "$REMOTE_PASS" ssh -p $SFTP_PORT "$SFTP_USER@$SFTP_HOST" "$(typeset -f); cleanup_old_backups '$REMOTE_BACKUP_DIR' '.sql.gz'"
    
    echo "Backup abgeschlossen: $LOCAL_WEB_BACKUP_FILE und $LOCAL_DB_BACKUP_FILE. Remote-Backup erfolgreich."
else
    echo "SSH-Verbindung fehlgeschlagen. Überprüfen Sie die Servereinstellungen und versuchen Sie es erneut."
fi
