# MongoDB Backup & Restore with AWS S3

This project provides simple shell scripts to **backup** a MongoDB database and upload it to **AWS S3**, and to **restore** the database from the latest backup.

---

## 📂 Files

* `mongodb-backup.sh` → Dumps MongoDB database, compresses it, and uploads to S3
* `mongodb-restore.sh` → Downloads the latest backup from S3 and restores into MongoDB

---

## ⚙️ Prerequisites

1. **MongoDB tools** installed (`mongodump`, `mongorestore`)

   ```bash
   sudo apt update && sudo apt install -y mongodb-clients
   ```

2. **AWS CLI v2** installed & configured

   ```bash
   aws configure
   ```

   Provide:

   * AWS Access Key ID
   * AWS Secret Access Key
   * Default region name (e.g., `us-east-1`)
   * Output format (json/text/table)

3. An **S3 bucket** created (e.g., `mydb-mongo-backups`).
   Make sure your IAM user has permission to `s3:PutObject`, `s3:GetObject`, `s3:ListBucket`.

---

## 🚀 Backup

Run:

```bash
./mongodb-backup.sh
```

This will:

* Dump the MongoDB database
* Compress it into a `.tar.gz` file
* Upload it to the configured S3 bucket

Backups are timestamped like:

```
mydb-backup-2025-09-14_15-41-19.tar.gz
```

---

## 🔄 Restore

Run:

```bash
./mongodb-restore.sh
```

This will:

* Fetch the **latest backup** from S3
* Extract it
* Restore the collections into MongoDB (dropping existing data first)

---

## ⏰ Cron Job (Weekly Backups)

To run automatic backups every **Sunday at 5 PM**, add this to crontab:

```bash
crontab -e
```

Add the line:

```bash
0 17 * * 0 /path/to/mongodb-backup.sh >> /var/log/mongodb-backup.log 2>&1
```

* `0 17 * * 0` = Run at 17:00 (5 PM) every Sunday
* Logs will be written to `/var/log/mongodb-backup.log`

---

## 📝 Notes

* `--drop` is used in restore to overwrite collections. Remove it if you want to keep existing data.
* Always verify restore on a test database before applying to production.

### Problem Statement from : https://roadmap.sh/projects/automated-backups

### PS: Didnt used Cloudfare since it was asking for credit card, instead used S3 which does the work!
