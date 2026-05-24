# Create S3 Bucket
```sh
aws s3 mb s3://encryption-test-bucket-1231
```
# Create a file 
```sh
echo "hello world!" > file.txt
# Find ssekms key
aws kms list-keys
```
# Put the object with encryption of KMS
```sh
aws s3api put-object \
--bucket encryption-test-bucket-1231 \
--key file.txt \
--body file.txt \
--server-side-encryption aws:kms \
--ssekms-key-id b5c3a34d-27ed-4084-94cd-0076960de8b6
# download and check the file
aws s3 cp s3://encryption-test-bucket-1231 file.txt 
```
