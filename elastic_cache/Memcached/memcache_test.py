from pymemcache.client.base import Client
import time

HOST = "meme-lab-bcxggb.serverless.use1.cache.amazonaws.com"

# WRITE CLIENT
write_client = Client(
    (HOST, 11211),
    connect_timeout=5,
    timeout=5
)

# READ CLIENT
read_client = Client(
    (HOST, 11212),
    connect_timeout=5,
    timeout=5
)

print("🚀 Writing cache")

start = time.time()

write_client.set(
    "name",
    "Ali Sina",
    expire=60
)

end = time.time()

print(f"✅ Write successful")
print(f"⏱ Write time: {end-start:.6f}")


print("\n🚀 Reading cache")

start = time.time()

value = read_client.get("name")

end = time.time()

print(f"Raw value: {value}")

if value:
    print(f"Decoded value: {value.decode()}")

print(f"⏱ Read time: {end-start:.6f}")