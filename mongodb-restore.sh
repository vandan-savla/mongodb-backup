#!/bin/bash

set -e

# ===== CONFIGURATION =====
DATABASE="mydb"
RESTORE_DIR="mongo_restore"
S3_BUCKET_NAME="s3://mydb-mongo-backups"

# ===== FIND LATEST BACKUP FILE IN S3 =====
echo "Fetching latest backup from S3..."
LATEST_BACKUP=$(aws s3 ls $S3_BUCKET_NAME/ | sort | tail -n 1 | awk '{print $4}')
echo "Latest Backup - $LATEST_BACKUP"

if [ -z "$LATEST_BACKUP" ]; then
    echo " No backups found in S3 bucket: $S3_BUCKET_NAME"
    exit 1
fi

echo "Latest backup file: $LATEST_BACKUP"

# ===== DOWNLOAD BACKUP =====
mkdir -p "$RESTORE_DIR/restore"

aws s3 cp "$S3_BUCKET_NAME/$LATEST_BACKUP" "$RESTORE_DIR/restore/"

# ===== EXTRACT TARBALL =====
echo "Extracting backup..."
tar -xzf "$RESTORE_DIR/restore/$LATEST_BACKUP" -C "$RESTORE_DIR/restore/"

# ===== RESTORE TO MONGODB =====
echo "Restoring MongoDB database: $DATABASE"
mongorestore --db "$DATABASE" --drop "$RESTORE_DIR/restore/$DATABASE"

if [ $? -eq 0 ]; then
    echo " Restore completed successfully!"
else
    echo " Restore failed!"
    exit 1
fi

