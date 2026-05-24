package main

import (
	"context"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

func main() {

	conn, err := amqp.Dial("amqps://admin:Testing123%21%40%23@b-af4542af-146a-4c6d-a332-faab48164e3a.mq.us-east-1.on.aws:5671")
	if err != nil {
		log.Fatal("Connection failed:", err)
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		log.Fatal(err)
	}
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"test-queue",
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatal(err)
	}

	body := "Hello from Go to Amazon MQ RabbitMQ"

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = ch.PublishWithContext(
		ctx,
		"",
		q.Name,
		false,
		false,
		amqp.Publishing{
			ContentType: "text/plain",
			Body:        []byte(body),
		},
	)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Message sent:", body)
}