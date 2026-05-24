#!/bin/bash

Bucket_NAME=$1

# Check if bucket name was provided
if [ -z "$Bucket_NAME" ]; then
    echo "Usage: ./createbucket.sh <bucket-name>"
    exit 1
fi

echo "Creating new bucket..."

# Check if bucket exists
if aws s3api head-bucket --bucket "$Bucket_NAME" 2>/dev/null; then
    echo "Bucket already exists"
else
    echo "Bucket does not exist. Creating..."
    aws s3api create-bucket --bucket "$Bucket_NAME"
fi

# Create multiple test files
for i in {1..5}
do
    filename="file$i.txt"

    echo "Hello Master this is file $i for S3 upload." > "test/$filename"

    echo "$filename created"
done

# Upload one specific file using put-object
aws s3api put-object \
    --bucket "$Bucket_NAME" \
    --key "file1.txt" \
    --body "test/file1.txt"

echo "Single file uploaded successfully"

# Sync all files in test directory
aws s3 sync test/ "s3://$Bucket_NAME"

echo "Directory synced successfully"
# List bucket objects
aws s3api list-objects \
    --bucket "$Bucket_NAME" \
    --output yaml

# Ask before deleting objects
read -p "Do you want to delete all objects in the bucket? (yes/no): " DELETE_OBJECTS

if [ "$DELETE_OBJECTS" = "yes" ]; then
    echo "Deleting all objects..."

    aws s3 rm "s3://$Bucket_NAME" --recursive

    echo "All objects deleted"
else
    echo "Skipping object deletion"
fi

# Ask before deleting bucket
read -p "Do you want to delete the bucket itself? (yes/no): " DELETE_BUCKET

if [ "$DELETE_BUCKET" = "yes" ]; then
    echo "Deleting bucket..."

    aws s3api delete-bucket \
        --bucket "$Bucket_NAME"

    echo "Bucket deleted"
else
    echo "Skipping bucket deletion"
fi
