package main

import (
	"context"
	"crypto/aes"
	"crypto/cipher"
	"encoding/hex"
	"fmt"
	"io"
	"log"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func main() {

	ctx := context.Background()

	region := "us-east-1"
	bucket := "client-side-encyrption-1231"
	objectKey := "encrypted-file.dat"

	// SAME AES key used during encryption
	keyHex := "a9c80e86e85b4d7a0e92a93138f5bc059529d32bcd422c566f4fb142e681a284"

	key, err := hex.DecodeString(keyHex)
	if err != nil {
		log.Fatalf("invalid key: %v", err)
	}

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

	// Download encrypted object
	result, err := s3Client.GetObject(
		ctx,
		&s3.GetObjectInput{
			Bucket: &bucket,
			Key:    &objectKey,
		},
	)

	if err != nil {
		log.Fatalf("failed downloading object: %v", err)
	}

	ciphertext, err := io.ReadAll(result.Body)
	if err != nil {
		log.Fatalf("failed reading object: %v", err)
	}

	// Create AES cipher
	block, err := aes.NewCipher(key)
	if err != nil {
		log.Fatalf("failed creating cipher: %v", err)
	}

	// Create GCM
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		log.Fatalf("failed creating GCM: %v", err)
	}

	nonceSize := gcm.NonceSize()

	// Extract nonce
	nonce := ciphertext[:nonceSize]

	// Extract encrypted data
	encryptedData := ciphertext[nonceSize:]

	// Decrypt
	plaintext, err := gcm.Open(nil, nonce, encryptedData, nil)
	if err != nil {
		log.Fatalf("failed decrypting: %v", err)
	}

	fmt.Println("Decrypted text:")
	fmt.Println(string(plaintext))
}