package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/opensearch"
	"github.com/aws/aws-sdk-go-v2/service/opensearch/types"
)

var domainName = "my-test-domain"

func buildAccessPolicy() (string, error) {
	policy := map[string]interface{}{
		"Version": "2012-10-17",
		"Statement": []map[string]interface{}{
			{
				"Effect": "Allow",
				"Principal": map[string]string{
					"AWS": "arn:aws:iam::832014379019:user/admin1",
				},
				"Action":   "es:*",
				"Resource": "arn:aws:es:us-east-1:832014379019:domain/my-test-domain/*",
			},
		},
	}

	b, err := json.Marshal(policy)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func createDomain(client *opensearch.Client) {
	policy, err := buildAccessPolicy()
	if err != nil {
		log.Fatal("policy build error:", err)
	}

	input := &opensearch.CreateDomainInput{
		DomainName:    aws.String(domainName),
		EngineVersion: aws.String("OpenSearch_2.11"),

		ClusterConfig: &types.ClusterConfig{
			InstanceType:           types.OpenSearchPartitionInstanceTypeT3SmallSearch,
			InstanceCount:          aws.Int32(1),
			DedicatedMasterEnabled: aws.Bool(false),
		},

		EBSOptions: &types.EBSOptions{
			EBSEnabled: aws.Bool(true),
			VolumeType: types.VolumeTypeGp2,
			VolumeSize: aws.Int32(10),
		},

		AccessPolicies: aws.String(policy),

		NodeToNodeEncryptionOptions: &types.NodeToNodeEncryptionOptions{
			Enabled: aws.Bool(true),
		},

		EncryptionAtRestOptions: &types.EncryptionAtRestOptions{
			Enabled: aws.Bool(true),
		},
	}

	resp, err := client.CreateDomain(context.TODO(), input)
	if err != nil {
		log.Fatal("CreateDomain error:", err)
	}

	fmt.Println("Domain creation started...")
	fmt.Println(*resp.DomainStatus.DomainName)
}

func updateDomain(client *opensearch.Client) {
	input := &opensearch.UpdateDomainConfigInput{
		DomainName: aws.String(domainName),
		ClusterConfig: &types.ClusterConfig{
			InstanceCount: aws.Int32(1),
		},
	}

	_, err := client.UpdateDomainConfig(context.TODO(), input)
	if err != nil {
		log.Fatal("UpdateDomainConfig error:", err)
	}

	fmt.Println("Domain update requested...")
}

func deleteDomain(client *opensearch.Client) {
	_, err := client.DeleteDomain(context.TODO(), &opensearch.DeleteDomainInput{
		DomainName: aws.String(domainName),
	})
	if err != nil {
		log.Fatal("DeleteDomain error:", err)
	}

	fmt.Println("Domain deletion started...")
}

func waitForDomain(client *opensearch.Client) {
	for {
		resp, err := client.DescribeDomain(context.TODO(), &opensearch.DescribeDomainInput{
			DomainName: aws.String(domainName),
		})
		if err != nil {
			log.Fatal("DescribeDomain error:", err)
		}

		if resp.DomainStatus.Processing == nil || !*resp.DomainStatus.Processing {
			break
		}

		fmt.Println("Waiting for domain to finish processing...")
		time.Sleep(20 * time.Second)
	}

	fmt.Println("Domain is ready.")
}

func confirmAction(message string) bool {
	var input string

	fmt.Printf("%s (yes/no): ", message)
	fmt.Scanln(&input)

	return input == "yes"
}

func main() {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		log.Fatal(err)
	}

	client := opensearch.NewFromConfig(cfg)

	// 1. CREATE
	createDomain(client)
	waitForDomain(client)

	// 2. UPDATE (ask user)
	if confirmAction("Do you want to UPDATE the domain?") {
		updateDomain(client)
		waitForDomain(client)
	} else {
		fmt.Println("Update skipped.")
	}

	// 3. DELETE (ask user)
	if confirmAction("Do you want to DELETE the domain?") {
		deleteDomain(client)
	} else {
		fmt.Println("Delete skipped.")
	}
}