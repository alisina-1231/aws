from flask import Flask, jsonify
import redis
import time

app = Flask(__name__)

# Connect to Valkey (ElastiCache)
cache = redis.Redis(
    host="YOUR_ELASTICACHE_ENDPOINT",
    port=6379,
    ssl=True,
    decode_responses=True
)

# Simulated slow database
def get_from_db(user_id):
    time.sleep(3)  # simulate slow query
    return {"user_id": user_id, "name": "Ali Sina", "source": "database"}

@app.route("/user/<user_id>")
def get_user(user_id):
    cache_key = f"user:{user_id}"

    # 1. Check cache first
    cached = cache.get(cache_key)
    if cached:
        return jsonify({
            "source": "cache",
            "data": cached,
            "speed": "FAST ⚡"
        })

    # 2. If not in cache → DB
    data = get_from_db(user_id)

    # 3. Store in cache
    cache.setex(cache_key, 60, str(data))  # TTL = 60 sec

    return jsonify({
        "source": "database",
        "data": data,
        "speed": "SLOW 🐢"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)