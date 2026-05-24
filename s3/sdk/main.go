package main

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {

	// Load AWS configuration
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
	)

	if err != nil {
		log.Fatalf("unable to load SDK config: %v", err)
	}

	// Create S3 client
	client := s3.NewFromConfig(cfg)

	// Bucket name must be globally unique
	bucketName := "ali-test-bucket-123456789"

	// Create bucket
	_, err = client.CreateBucket(context.TODO(), &s3.CreateBucketInput{
		Bucket: &bucketName,
	})

	if err != nil {
		log.Fatalf("failed to create bucket: %v", err)
	}

	fmt.Println("Bucket created successfully:", bucketName)
}