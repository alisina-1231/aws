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

	result, err := client.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
		QueueUrl:            &queueURL,
		MaxNumberOfMessages: 10,
		WaitTimeSeconds:     10,
	})

	if err != nil {
		panic(err)
	}

	if len(result.Messages) == 0 {
		fmt.Println("No messages")
		return
	}

	for _, message := range result.Messages {

		fmt.Println("Received:", *message.Body)

		_, err := client.DeleteMessage(context.TODO(), &sqs.DeleteMessageInput{
			QueueUrl:      &queueURL,
			ReceiptHandle: message.ReceiptHandle,
		})

		if err != nil {
			panic(err)
		}

		fmt.Println("Deleted")
	}
}