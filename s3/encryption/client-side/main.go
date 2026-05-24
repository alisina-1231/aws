package main

import (
	"bytes"
	"context"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {

	ctx := context.Background()

	region := "us-east-1"
	bucket := "client-side-encyrption-1231"
	objectKey := "encrypted-file.dat"

	// Read local file
	plaintext, err := os.ReadFile("file.txt")
	if err != nil {
		log.Fatalf("failed reading file: %v", err)
	}

	// Generate AES-256 key
	key := make([]byte, 32)

	_, err = rand.Read(key)
	if err != nil {
		log.Fatalf("failed generating key: %v", err)
	}

	fmt.Printf("AES Key (SAVE THIS): %x\n", key)

	// Create AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		log.Fatalf("failed creating cipher: %v", err)
	}

	// GCM mode
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		log.Fatalf("failed creating GCM: %v", err)
	}

	// Generate nonce
	nonce := make([]byte, gcm.NonceSize())

	_, err = io.ReadFull(rand.Reader, nonce)
	if err != nil {
		log.Fatalf("failed generating nonce: %v", err)
	}

	// Encrypt file
	ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)

	// Load AWS config
	cfg, err := config.LoadDefaultConfig(
		ctx,
		config.WithRegion(region),
	)
	if err != nil {
		log.Fatalf("unable to load config: %v", err)
	}

	// Create S3 client
	s3Client := s3.NewFromConfig(cfg)

	// Upload encrypted data
	_, err = s3Client.PutObject(
		ctx,
		&s3.PutObjectInput{
			Bucket: &bucket,
			Key:    &objectKey,
			Body:   bytes.NewReader(ciphertext),
		},
	)

	if err != nil {
		log.Fatalf("failed uploading encrypted object: %v", err)
	}

	fmt.Println("Encrypted upload successful")
}