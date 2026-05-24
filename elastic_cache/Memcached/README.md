## Create the cache using create.sh 
```sh
./create.sh
```

# Security Group Rule Memcached uses port: 11211
```sh
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 11211 \
  --source-group sg-ec2-instance
```

# Install Memcached Client on EC2
```sh
sudo dnf install memcached telnet -y
pip3 install pymemcache
```
# Run the function to test
```sh
python3 memcache_test.py &
```






