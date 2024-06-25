# Backup Script for LAMP Stack on Linux Servers

This repository contains a backup script for creating and managing backups on a Linux server. The script performs the following tasks:

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

sudo apt-get update
sudo apt-get install tar gzip mysql-client sshpass expect
