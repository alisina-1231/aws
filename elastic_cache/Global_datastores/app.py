import redis
import time

PRIMARY = "primary-endpoint.cache.amazonaws.com"
SECONDARY = "secondary-endpoint.cache.amazonaws.com"

primary = redis.Redis(host=PRIMARY, port=6379, decode_responses=True)
secondary = redis.Redis(host=SECONDARY, port=6379, decode_responses=True)

def test_global_datastore():

    print("🚀 Writing to PRIMARY region")

    primary.set("user:1", "Ali Sina - Global User")

    print("⏳ Waiting for replication...")
    time.sleep(2)

    print("\n🌎 Reading from SECONDARY region")

    value = secondary.get("user:1")

    print("Value from secondary:", value)

    if value:
        print("✅ Replication SUCCESS")
    else:
        print("❌ Replication FAILED")

if __name__ == "__main__":
    test_global_datastore()