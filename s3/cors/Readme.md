
## <------------------------>
# CORS in Amazon S3 controls whether a website or app from one origin is allowed
# to access files in your S3 bucket through the browser.
## <------------------------>

## Create a Bucket 

```sh
aws s3 mb s3://bucket-cors-test-1231
```
## Change block public Access
```sh
aws s3api put-public-access-block \
--bucket bucket-cors-test-1231 \
--public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

## Create a Bucket Policy
```sh
aws s3api put-bucket-policy --bucket bucket-cors-test-1231 --policy file://policy.json

```
## Trun on Static Website hosting
```sh
aws s3api put-bucket-website --bucket bucket-cors-test-1231 --website-configuration file://website.json

```

## Upload index.html and include a resource that would be cross-region
```sh
aws s3 cp index.html s3://bucket-cors-test-1231
```
## View the website 
```sh
aws s3api get-bucket-website \
--bucket bucket-cors-test-1231
```
#    http://bucket-cors-test-1231.s3-website.us-east-1.amazonaws.com

## Apply a Cors policy
```sh
aws s3api put-bucket-cors \
--bucket bucket-cors-test-1231 \
--cors-configuration file://cors.json
```

## Access via cross region
```sh
curl -H "Origin: https://example.com" \
-I http://bucket-cors-test-1231.s3-website-us-east-1.amazonaws.com
```
# Output
```sh 
    HTTP/1.1 200 OK
    x-amz-id-2: HKP2JrwYmXHv4ccNeFghcuKCOO6s++yBs9NUNXvCe+QwRK6aNyDEDpZUiFJWyTA9dxBc1p0ZTuhYzlh6Nuq9tFLaOcfkCnc4
    x-amz-request-id: 9FDZ030YCS6BA964
    Date: Sun, 10 May 2026 10:07:43 GMT
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Methods: GET, HEAD, POST, PUT
    Access-Control-Expose-Headers: ETag
    Access-Control-Max-Age: 3000
    Vary: Origin, Access-Control-Request-Headers, Access-Control-Request-Method
    Last-Modified: Sun, 10 May 2026 10:01:25 GMT
    ETag: "33c3c72bf1bb128b68e8f2a92f2ccfa6"
    Content-Type: text/html
    Content-Length: 791
    Server: AmazonS3
    ```