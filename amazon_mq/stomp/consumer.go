package main

import (
	"crypto/tls"
	"log"

	"github.com/go-stomp/stomp/v3"
)

func main() {

	conn, err := tls.Dial(
		"tcp",
		"b-13196c03-0f69-4231-ab02-807b4cd1f54d-1.mq.us-east-1.amazonaws.com:61614",
		&tls.Config{
			InsecureSkipVerify: true,
		},
	)

	if err != nil {
		log.Fatal(err)
	}

	stompConn, err := stomp.Connect(
		conn,
		stomp.ConnOpt.Login("admin", "Testing123!#"),
	)

	if err != nil {
		log.Fatal(err)
	}

	sub, err := stompConn.Subscribe(
		"/queue/test",
		stomp.AckAuto,
	)

	if err != nil {
		log.Fatal(err)
	}

	log.Println("waiting for messages")

	for msg := range sub.C {

		if msg.Err != nil {
			log.Println("error:", msg.Err)
			continue
		}

		log.Println("received:", string(msg.Body))
	}
}