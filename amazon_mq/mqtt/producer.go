package main

import (
	"log"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func main() {

	opts := mqtt.NewClientOptions()
	opts.AddBroker("mqtt+ssl://b-13196c03-0f69-4231-ab02-807b4cd1f54d-1.mq.us-east-1.amazonaws.com:8883")

	opts.SetUsername("admin")
	opts.SetPassword("Testing123!#")

	client := mqtt.NewClient(opts)

	token := client.Connect()
	token.Wait()

	if token.Error() != nil {
		log.Fatal(token.Error())
	}

	token = client.Publish(
		"test/topic",
		0,
		false,
		"hello mqtt",
	)

	token.Wait()

	log.Println("message sent")

	client.Disconnect(250)
}