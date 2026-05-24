package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

func main() {

	queueURL := "https://sqs.us-east-1.amazonaws.com/832014379019/MyFifoQueue.fifo"

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		panic(err)
	}

	client := sqs.NewFromConfig(cfg)

	messageBody := "Hello FIFO Queue"

	messageGroupID := "group-1"

	result, err := client.SendMessage(context.TODO(), &sqs.SendMessageInput{
		QueueUrl:      &queueURL,
		MessageBody:   &messageBody,
		MessageGroupId: &messageGroupID,
	})

	if err != nil {
		panic(err)
	}

	fmt.Println("FIFO Message Sent")
	fmt.Println("Message ID:", *result.MessageId)
}