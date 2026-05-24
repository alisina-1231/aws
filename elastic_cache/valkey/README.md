# Install Python dependencies on EC2
```sh
sudo dnf install python3 -y
pip3 install flask valkey
pip3 install flask redis
```
# Replace endpoint
host="YOUR_ELASTICACHE_ENDPOINT"

# Run Flask app
```sh
python3 app.py
```
# Test API

http://<EC2-IP>:5000/user/1
# First request:
# Takes ~3 seconds
```sh
Response:

{
  "source": "database",
  "speed": "SLOW 🐢"
}
```
# Second request:
```sh
Instant

{
  "source": "cache",
  "speed": "FAST ⚡"
}
```