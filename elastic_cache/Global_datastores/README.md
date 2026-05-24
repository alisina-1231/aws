
## Amazon ElastiCache Global Datastore is a feature that lets you replicate
## your Redis-compatible cache across multiple AWS regions so you can build 
## low-latency, globally distributed applications.

## It is used with Redis (not Memcached or Valkey in all cases).

# Normally:

# Region A (US) → Redis cache 
# Region B (EU) → separate Redis cache (not connected)

## With Global Datastore:

# Primary Region (write)
  #      ↓ async replication
# Secondary Region (read-only standby or read replica)

# So your data is shared globally across regions.

## Key Idea

# One region is primary (writes allowed)
# Other regions are secondary (read-only replicas)
# Data is replicated automatically

# Why it is used
## 1. Global low latency

# Users read from nearest region cache.

## 2. Fast disaster recovery

# If primary region fails → promote secondary.

## 3. Multi-region apps
```md
Works well for: 
gaming leaderboards
session storage
real-time apps
personalization engines
```