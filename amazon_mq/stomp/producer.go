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

	err = stompConn.Send(
		"/queue/test",
		"text/plain",
		[]byte("hello stomp"),
	)

	if err != nil {
		log.Fatal(err)
	}

	log.Println("message sent")

	stompConn.Disconnect()
}