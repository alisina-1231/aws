package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Generic JSON input structure
type RequestBody map[string]interface{}

func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// Print full event to CloudWatch Logs
	eventJSON, _ := json.MarshalIndent(event, "", "  ")
	fmt.Println("Received Event:")
	fmt.Println(string(eventJSON))

	// Parse JSON body
	var body RequestBody

	if event.Body != "" {
		err := json.Unmarshal([]byte(event.Body), &body)
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 400,
				Body:       `{"error":"Invalid JSON input"}`,
			}, nil
		}
	}

	// Print parsed body to CloudWatch
	bodyJSON, _ := json.MarshalIndent(body, "", "  ")
	fmt.Println("Parsed JSON Body:")
	fmt.Println(string(bodyJSON))

	// Response
	responseBody, _ := json.Marshal(map[string]interface{}{
		"message": "Lambda executed successfully",
		"input":   body,
	})

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handler)
}