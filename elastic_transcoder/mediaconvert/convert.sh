#!/bin/bash
# ============================================
# AWS MediaConvert End-to-End Lab Script
# ============================================

set -e

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

RANDOM_ID=$(date +%s)

INPUT_BUCKET="mediaconvert-input-$RANDOM_ID"
OUTPUT_BUCKET="mediaconvert-output-$RANDOM_ID"

ROLE_NAME="MediaConvertRole-$RANDOM_ID"

VIDEO_FILE=$1

if [ -z "$VIDEO_FILE" ]; then
    echo "Usage: $0 <video-file>"
    exit 1
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "Video file not found!"
    exit 1
fi

echo "============================================"
echo "Creating S3 Buckets"
echo "============================================"

aws s3 mb s3://$INPUT_BUCKET --region $REGION
aws s3 mb s3://$OUTPUT_BUCKET --region $REGION

echo "============================================"
echo "Uploading Video"
echo "============================================"

BASENAME=$(basename $VIDEO_FILE)

aws s3 cp $VIDEO_FILE s3://$INPUT_BUCKET/

echo "============================================"
echo "Creating IAM Trust Policy"
echo "============================================"

cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "mediaconvert.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

echo "============================================"
echo "Creating IAM Role"
echo "============================================"

aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json

echo "============================================"
echo "Attaching S3 Full Access Policy"
echo "============================================"

aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

echo "Waiting for IAM role propagation..."
sleep 15

echo "============================================"
echo "Getting MediaConvert Endpoint"
echo "============================================"

ENDPOINT=$(aws mediaconvert describe-endpoints \
  --region $REGION \
  --query 'Endpoints[0].Url' \
  --output text)

echo "Endpoint:"
echo $ENDPOINT

echo "============================================"
echo "Creating MediaConvert Job JSON"
echo "============================================"

cat > job.json <<EOF
{
  "Role": "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME",
  "Settings": {
    "Inputs": [
      {
        "FileInput": "s3://$INPUT_BUCKET/$BASENAME"
      }
    ],
    "OutputGroups": [
      {
        "Name": "File Group",
        "OutputGroupSettings": {
          "Type": "FILE_GROUP_SETTINGS",
          "FileGroupSettings": {
            "Destination": "s3://$OUTPUT_BUCKET/"
          }
        },
        "Outputs": [
          {
            "NameModifier": "-converted",
            "ContainerSettings": {
              "Container": "MP4"
            },
            "VideoDescription": {
              "CodecSettings": {
                "Codec": "H_264",
                "H264Settings": {
                  "MaxBitrate": 5000000,
                  "RateControlMode": "QVBR"
                }
              }
            },
            "AudioDescriptions": [
              {
                "CodecSettings": {
                  "Codec": "AAC",
                  "AacSettings": {
                    "Bitrate": 96000,
                    "CodingMode": "CODING_MODE_2_0",
                    "SampleRate": 48000
                  }
                }
              }
            ]
          }
        ]
      }
    ]
  }
}
EOF

echo "============================================"
echo "Creating MediaConvert Job"
echo "============================================"

JOB_ID=$(aws mediaconvert create-job \
  --endpoint-url $ENDPOINT \
  --region $REGION \
  --cli-input-json file://job.json \
  --query 'Job.Id' \
  --output text)

echo "Job ID:"
echo $JOB_ID

echo "============================================"
echo "Waiting for Job Completion"
echo "============================================"

while true
do
    STATUS=$(aws mediaconvert get-job \
      --id $JOB_ID \
      --endpoint-url $ENDPOINT \
      --region $REGION \
      --query 'Job.Status' \
      --output text)

    echo "Current Status: $STATUS"

    if [ "$STATUS" == "COMPLETE" ]; then
        echo "MediaConvert Job Completed!"
        break
    fi

    if [ "$STATUS" == "ERROR" ]; then
        echo "MediaConvert Job Failed!"
        exit 1
    fi

    sleep 15
done

echo "============================================"
echo "Listing Output Files"
echo "============================================"

aws s3 ls s3://$OUTPUT_BUCKET/

echo "============================================"
echo "Downloading Converted Video"
echo "============================================"

mkdir -p output

aws s3 cp s3://$OUTPUT_BUCKET/ ./output/ --recursive

echo "============================================"
echo "Lab Complete"
echo "============================================"

echo "Input Bucket:  $INPUT_BUCKET"
echo "Output Bucket: $OUTPUT_BUCKET"
echo "Output Files Downloaded to ./output"

echo ""
echo "============================================"
echo "Cleanup Commands"
echo "============================================"

echo "aws s3 rb s3://$INPUT_BUCKET --force"
echo "aws s3 rb s3://$OUTPUT_BUCKET --force"
echo "aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess"
echo "aws iam delete-role --role-name $ROLE_NAME"