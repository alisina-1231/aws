package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {

	queueURL := "https://sqs.us-east-1.amazonaws.com/832014379019/my-go-queue"

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		panic(err)
	}

	client := sqs.NewFromConfig(cfg)

	result, err := client.SendMessage(context.TODO(), &sqs.SendMessageInput{
		QueueUrl:    &queueURL,
		MessageBody: awsString("Hello from Golang SQS Producer"),
	})

	if err != nil {
		panic(err)
	}

	fmt.Println("Message Sent!")
	fmt.Println("Message ID:", *result.MessageId)
}

func awsString(s string) *string {
	return &s
}