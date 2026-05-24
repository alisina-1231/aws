package main

import (
	"fmt"
	"log"

	amqp "github.com/rabbitmq/amqp091-go"
)

func main() {


	conn, err := amqp.Dial("amqps://admin:Testing123%21%40%23@b-af4542af-146a-4c6d-a332-faab48164e3a.mq.us-east-1.on.aws:5671")
	if err != nil {
		log.Fatal(err)
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

	msgs, err := ch.Consume(
		q.Name,
		"",
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Waiting for messages...")

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			fmt.Println("Received:", string(d.Body))
		}
	}()

	<-forever
}