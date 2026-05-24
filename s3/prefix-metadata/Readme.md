# Create a New Bucket
```sh
aws s3 mb s3://prefix-meta-test-bucket
echo "hello" > new.txt
```
# Upload the file to aws
```sh
aws s3 cp new.txt s3://prefix-meta-test-bucket
```
# Add prefix to object in s3 bucket
```sh
aws s3api put-object --bucket prefix-meta-test-bucket --key pre-test/new.txt --body new.txt 
```
# Add metadata to object in s3
```sh
aws s3api put-object --bucket prefix-meta-test-bucket --key pre-test/new.txt --body new.txt --metadata source=ali
```
# Get Prefix and Metadata
```sh
aws s3api head-object --bucket prefix-meta-test-bucket --key pre-test/new.txt  
```