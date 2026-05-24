# Create a bucket 
```sh
aws s3 mb s3://bucket-policy-test1231
```
# Create a Policy

```sh
aws s3api put-bucket-policy --bucket bucket-policy-test1231 --policy policy.json
```