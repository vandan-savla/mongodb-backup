#!/bin/bash

set -e

DATABASE="mydb"
COLLECTION="users"
BACKUP_DIR="mongo_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
S3_BUCKET_NAME="s3://mydb-mongo-backups"


# Create Backup Directory

mkdir -p "$BACKUP_DIR/dump-$TIMESTAMP"

echo "Dumping MongoDB database: $DATABASE"

mongodump --db="$DATABASE"  --out "$BACKUP_DIR/dump-$TIMESTAMP"

#Compressing to Tarball
echo "Compressing to TarBall"

tar -czf "$BACKUP_DIR/$DATABASE-backup-$TIMESTAMP.tar.gz" -C "$BACKUP_DIR/dump-$TIMESTAMP" .


#Upload to S3
echo "Uploading to S3"

aws s3 cp "$BACKUP_DIR/$DATABASE-backup-$TIMESTAMP.tar.gz" "$S3_BUCKET_NAME/"

if [ $? -eq 0 ]; then
        echo "Success Backup uploaded to  S3- s3://$BACKUP_DIR/$DATABASE-backup-$TIMESTAMP.tar.gz"
else
        echo "Error Occured"
fi
