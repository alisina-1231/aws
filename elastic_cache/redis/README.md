# Since Valkey is Redis-compatible, we can use the Python Redis client directly.


# Required Security Group Rule
# Your Redis SG must allow EC2 access:
```sh
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 6379 \
  --source-group sg-ec2-instance
```