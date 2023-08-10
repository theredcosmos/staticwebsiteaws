#!/bin/bash

# Check if AWS CLI is installed and accessible
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install and configure it."
    exit 1
fi

# Check for correct number of command-line arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <s3_bucket>"
    exit 1
fi

source_dir="$1"
s3_bucket="$2"
log_file="$(dirname "$0")/backup.log"

# Check if source directory exists and is accessible
if [ ! -d "$source_dir" ]; then
    echo "Source directory '$source_dir' does not exist or is not accessible."
    exit 1
fi

# Check if S3 bucket exists and is accessible
if ! aws s3 ls "s3://$s3_bucket" &> /dev/null; then
    echo "S3 bucket '$s3_bucket' does not exist or is not accessible."
    exit 1
fi

# Create timestamp for logging
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

# Create compressed tarball of source directory
tarball_name="backup_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czf "$tarball_name" -C "$source_dir" .

# Upload tarball to S3 bucket
aws s3 cp "$tarball_name" "s3://$s3_bucket/"

# Check if upload was successful
if [ $? -eq 0 ]; then
    echo "[$timestamp] Backup of '$source_dir' uploaded to S3 bucket '$s3_bucket'" >> "$log_file"
    rm "$tarball_name" # Remove local tarball
else
    echo "[$timestamp] Error: Backup upload to S3 bucket '$s3_bucket' failed" >> "$log_file"
fi

# Display final status message
echo "Backup process completed. Log details are available in '$log_file'."
