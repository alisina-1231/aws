```sh
#create s3 bucket
aws s3 mb s3://new-test-bucket-1231

```

```sh
#create file and upload to s3
echo "hello world!" > new.txt
md5sum new.txt
#c897d1410af8f2c74fba11b1db511e9e  new.txt
aws s3 cp new.txt s3://new-test-bucket-1231
aws s3api get-object --bucket new-test-bucket-1231 --key new.txt
```
```sh
#calculate the checksum
openssl dgst -sha1 -binary new.txt | base64
# upload to aws
aws s3api put-object \
--bucket new-test-bucket-1231 \
--key newsh1.txt \
--body new.txt \
--checksum-algorithm SHA1 \
--checksum-sha1 +VGxAZibLDt0cXELTnj8Tb36DKY=
```