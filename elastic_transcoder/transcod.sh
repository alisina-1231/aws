#!/bin/bash
# Create an S3 bucket and upload the input video file
```sh
aws s3 mb s3://elastic-transcoder-lab-input-bucket-123456789012
aws s3 cp input.mp4 s3://elastic-transcoder-lab-input-bucket-123456789012/video.mp4
```
# Create an Elastic Transcoder pipeline
```sh
aws elastictranscoder create-pipeline \
    --name convert-video-lab \
    --input-bucket elastic-transcoder-lab-input-bucket-123456789012 \
    --role arn:aws:iam::832014379019:role/Elastic_Transcoder_Default_Role \
    --content-config file://content.json \
    --thumbnail-config file://thumbnail.json \
    --region us-east-1
```
# Create a transcoding job
```sh
aws elastictranscoder create-job \
    --pipeline-id 1111111111111-abcde1 \
    --inputs file://inputs.json \
    --outputs file://outputs.json \
    --output-key-prefix "recipes/" \
    --user-metadata file://user-metadata.json \
    --region us-east-1
```

# Descibe Job Details
```sh
aws elastictranscoder read-job --id 1111111111111-abcde2 --region us-east-1