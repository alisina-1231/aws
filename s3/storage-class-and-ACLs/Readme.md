# Create a New Bucket and set Storage class
```sh
aws s3 mb s3://storage-class-acl-test-bucket
echo "hello" > new.txt
aws s3api put-object \
--bucket storage-class-acl-test-bucket \
--key new.txt \
--body new.txt \
--storage-class STANDARD_IA
```
# Create ACLs
```sh
aws s3api put-public-access-block \
--bucket storage-class-acl-test-bucket \
--public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```
```sh
aws s3api get-public-access-block \
--bucket storage-class-acl-test-bucket
```
# Chnage ownership to enable ACLs
```sh
aws s3api put-bucket-ownership-controls \
--bucket storage-class-acl-test-bucket \
--ownership-controls="Rules=[{ObjectOwnership=BucketOwnerPreferred}]"

```

# Change ACLs to allow access from ther account
```sh
aws s3api put-bucket-acl \
--bucket storage-class-acl-test-bucket \
--access-control-policy file://test.json
```
# Access from other account

```sh
echo "hello" > file.txt
aws s3 cp file.txt s3://storage-class-acl-test-bucket
aws s3 ls s3://storage-class-acl-test-bucket
```
# Cleanup 
```sh
aws s3 rb s3://storage-class-acl-test-bucket --force
```