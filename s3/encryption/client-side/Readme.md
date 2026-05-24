# Create a Bucket

```sh
aws s3 mb s3://client-side-encyrption-1231
```
# Encyrpt the file and upload it to s3 using ruby

```sh
go mod init client-side
go mod tidy
go run main.go

# download the file and check the content
aws s3 cp s3://client-side-encyrption-1231/encrypted-file.dat downloaded.dat
cat downloaded.dat

# Decrypt the content save the key during the upload and use it for decryption
go run decrypt.go
```

