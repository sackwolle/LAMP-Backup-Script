# Backup Script for Ubuntu Server

This repository contains a backup script designed to create and manage backups on an Ubuntu server. The script performs the following tasks:

- Creates a compressed backup of website files
- Creates a compressed backup of a MySQL database
- Transfers the backups to a remote server via SFTP
- Maintains only the three most recent backups locally and remotely

## Prerequisites

Before using the script, ensure that the following software is installed on your server:

- `tar`
- `gzip`
- `mysqldump`
- `sshpass`
- `expect`

You can install these packages using the following command:

```bash
sudo apt-get update
sudo apt-get install tar gzip mysql-client sshpass expect
```

## Usage

1. **Clone the Repository**

   ```bash
   git clone https://github.com/sackwolle/LAMP-Backup-Script.git
   cd LAMP-Backup-Script
   ```

2. **Configure the Script**

   Edit the script to match your server configuration and backup preferences:

   ```bash
   nano backup_script.sh
   ```

   Update the following variables:
   - `LOCAL_BACKUP_DIR`: Directory where local backups will be stored
   - `WEB_DIR`: Directory of the website files to back up
   - `DB_USER`: MySQL database username
   - `DB_PASS`: MySQL database password
   - `DB_NAME`: MySQL database name
   - `SFTP_USER`: Username for the remote server
   - `SFTP_HOST`: IP address or hostname of the remote server
   - `SFTP_PORT`: SSH port of the remote server
   - `REMOTE_BACKUP_DIR`: Directory on the remote server where backups will be stored

3. **Make the Script Executable**

   ```bash
   chmod +x backup_script.sh
   ```

4. **Run the Script Manually**

   You can test the script by running it manually:

   ```bash
   ./backup_script.sh
   ```

5. **Automate the Script Using Cron**

   To automate the backup process, add a cron job:

   ```bash
   crontab -e
   ```

   Add the following line to schedule the script to run daily at 1 AM:

   ```bash
   0 1 * * * /path/to/backup_script.sh > /dev/null 2>&1
   ```

## Contributing

Feel free to submit pull requests or open issues to improve this script.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```
