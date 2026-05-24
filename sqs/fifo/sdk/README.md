for i in {1..5}; do   aws sqs send-message     --queue-url https://sqs.us-east-1.amazonaws.com/account_id/MyFifoQueue.fifo     --message-body "Message-$i"     --message-group-id group1; done
{
    "MD5OfMessageBody": "ff36a2793ec3f06a9535996d5030c592",
    "MessageId": "28b7a123-3bec-4dc2-a07c-d6856a5f03f6",
    "SequenceNumber": "18902246118240239872"
}
{
    "MD5OfMessageBody": "d0df09018a4dc02ff7d49611a0d37c09",
    "MessageId": "3e122172-c9ee-49f9-becb-720490928be1",
    "SequenceNumber": "18902246119530735616"
}
{
    "MD5OfMessageBody": "a50c8bf3e94c2823886b1007d38c05f2",
    "MessageId": "b6859311-d59a-475b-bbb8-add71259aab3",
    "SequenceNumber": "18902246120241903872"
}
{
    "MD5OfMessageBody": "d694fc4edd0fa2b005e0b7045cadc29a",
    "MessageId": "d554af1a-d38c-45b4-a1dd-4b8bf5a480f1",
    "SequenceNumber": "18902246121037039616"
}
{
    "MD5OfMessageBody": "9225106de1d6ab324dd61a82e9f0cd55",
    "MessageId": "055ccb30-f2d8-4a52-8a28-4fe7582636d1",
    "SequenceNumber": "18902246121835759616"
}
ali@ali:~/aws/sqs/fifo/sdk$ go run consumer.go 
Received: Message-1
Deleted
Received: Message-2
Deleted
Received: Message-3
Deleted
Received: Message-4
Deleted
Received: Message-5
Deleted