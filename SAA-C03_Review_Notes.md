
# AWS Solutions Architect Associate (SAA-C03)
## Comprehensive Review Notes — Weak Areas Focus

---

## 1. VPC ENDPOINTS: Gateway vs. Interface

### Gateway VPC Endpoints (FREE)
| Aspect | Details |
|--------|---------|
| **Services** | Amazon S3, DynamoDB ONLY |
| **Type** | Gateway (target in route table) |
| **Cost** | **FREE** — no hourly charges |
| **Availability** | Highly available by design (AWS-managed) |
| **Use Case** | Private subnet → S3/DynamoDB without NAT/IGW |
| **Route Table** | Must add route: `vpce-xxx` → S3/DynamoDB prefix list |

```
Private Subnet → Route Table → Gateway VPC Endpoint → S3/DynamoDB
                              (no NAT, no internet)
```

### Interface VPC Endpoints (AWS PrivateLink) — PAID
| Aspect | Details |
|--------|---------|
| **Services** | 100+ services (EC2, SNS, SQS, Lambda, etc.) |
| **Type** | ENI in your subnet (private IP) |
| **Cost** | **~$0.01/hour per AZ** + data processing |
| **Availability** | Create in multiple AZs for HA |
| **Use Case** | Private access to most AWS services |
| **DNS** | Overrides public DNS to resolve to private IP |

```
Private Subnet → ENI (Interface Endpoint) → AWS Service via PrivateLink
```

### Quick Decision Tree
```
Need to access S3 or DynamoDB from private subnet?
    → YES → Use Gateway VPC Endpoint (FREE)

Need to access any other AWS service from private subnet?
    → YES → Use Interface VPC Endpoint (PrivateLink)

Need to access third-party SaaS from VPC?
    → YES → Use Interface VPC Endpoint (PrivateLink)
```

### Exam Traps
- ❌ "Use Interface endpoints for S3" → Gateway is FREE and purpose-built
- ❌ "NAT Gateway for S3 access" → Overkill and expensive; use Gateway endpoint
- ✅ "Private subnet needs S3 + DynamoDB" → Gateway endpoints

---

## 2. SECURITY SERVICES: WAF vs. Shield vs. GuardDuty vs. Macie vs. Config

### AWS WAF (Web Application Firewall)
| Aspect | Details |
|--------|---------|
| **Layer** | Layer 7 (Application) |
| **Protects Against** | SQL injection, XSS, bad bots, geo-blocking, rate limiting |
| **Deployment** | CloudFront, ALB, API Gateway, AppSync |
| **Rules** | Managed rule groups + custom rules |
| **Cost** | Per web ACL + rule + requests inspected |

**Use WAF when:** Web app needs protection from common web exploits

### AWS Shield
| Aspect | Shield Standard | Shield Advanced |
|--------|-----------------|-----------------|
| **Cost** | FREE | $3,000/month |
| **Protection** | DDoS (L3/L4) automatic | DDoS + L7 + cost protection |
| **WAF Integration** | No | Yes (WAF included) |
| **DRT Access** | No | Yes (DDoS Response Team) |
| **Cost Protection** | No | Yes (credits for scaling costs) |

**Use Shield when:** DDoS protection needed. Standard is automatic; Advanced for critical apps.

### Amazon GuardDuty
| Aspect | Details |
|--------|---------|
| **Type** | Threat detection (ML-based) |
| **Monitors** | CloudTrail, VPC Flow Logs, DNS logs |
| **Detects** | Compromised instances, reconnaissance, crypto mining, IAM anomalies |
| **Response** | Findings → EventBridge → Lambda/SNS/Security Hub |

**Use GuardDuty when:** Need intelligent threat detection across account

### AWS Macie
| Aspect | Details |
|--------|---------|
| **Type** | Data security + privacy (ML-based) |
| **Focus** | S3 buckets — PII, PHI, sensitive data discovery |
| **Detects** | Unencrypted buckets, publicly accessible buckets, sensitive data |

**Use Macie when:** Need to discover and protect sensitive data in S3

### AWS Config
| Aspect | Details |
|--------|---------|
| **Type** | Configuration compliance + audit |
| **Monitors** | Resource configuration changes over time |
| **Rules** | Managed rules (200+) + custom rules |
| **Remediation** | Auto-remediation via SSM Automation |
| **Use Cases** | Compliance, change tracking, drift detection |

**Use Config when:** Need to ensure resources stay compliant (e.g., all S3 buckets encrypted)

### IAM Access Analyzer
| Aspect | Details |
|--------|---------|
| **Type** | External access analysis |
| **Finds** | Resources shared with external accounts/public |
| **Scope** | Single account or Organizations-wide |

**Use Access Analyzer when:** Need to identify unintended external access

### Quick Comparison Table
| Service | What It Does | Layer | Key Use Case |
|---------|-------------|-------|--------------|
| **WAF** | Block web attacks | L7 | SQL injection, XSS |
| **Shield** | DDoS protection | L3/L4/L7 | DDoS mitigation |
| **GuardDuty** | Threat detection | All | Compromised resources, anomalies |
| **Macie** | Sensitive data discovery | Data | Find PII/PHI in S3 |
| **Config** | Compliance monitoring | Config | Ensure encryption, tagging |
| **Access Analyzer** | External access review | IAM | Find public/external sharing |

### Exam Traps
- ❌ "Use Shield for SQL injection" → WAF handles application-layer attacks
- ❌ "Use GuardDuty for PII discovery" → Macie discovers sensitive data
- ❌ "Use Config for threat detection" → GuardDuty does threat detection
- ✅ "Block SQL injection on ALB" → AWS WAF
- ✅ "Detect crypto mining on EC2" → GuardDuty
- ✅ "Find unencrypted S3 buckets" → AWS Config + Macie

---

## 3. ACM CERTIFICATES: REGIONAL NATURE

### Critical Rule
> **ACM certificates are REGIONAL. They do NOT replicate across regions automatically.**

### Valid Approaches
| Scenario | Solution |
|----------|----------|
| Same cert in multiple regions | **Request/import a separate certificate in EACH region** |
| Global certificate (CloudFront) | ACM in **us-east-1** ONLY (CloudFront requirement) |
| ALB in eu-west-1 | Request/import cert in ACM eu-west-1 |
| ALB in ap-southeast-1 | Request/import cert in ACM ap-southeast-1 |

### CloudFront Special Case
```
CloudFront (global) → ACM certificate MUST be in us-east-1
```

### Exam Traps
- ❌ "Export ACM cert and import to other regions" → ACM certs cannot be exported (private key not accessible)
- ❌ "ACM certs replicate automatically" → They are regional
- ❌ "Use KMS to replicate certs" → KMS doesn't replicate certificates
- ✅ "Use same cert in multiple regions" → Request new cert in each region's ACM
- ✅ "CloudFront needs cert" → Must be in us-east-1 ACM

---

## 4. KMS KEY POLICIES: Customer-Managed vs. AWS-Managed

### KMS Key Types
| Type | Control | Rotation | Audit | Use Case |
|------|---------|----------|-------|----------|
| **AWS-managed** | AWS controls key policy | Automatic (every ~3 years) | Limited | Default encryption, simple use |
| **Customer-managed** | Full key policy control | Automatic (annual) or manual | Full CloudTrail | Compliance, fine-grained access |
| **AWS-owned** | AWS fully manages | Yes | No | Used by AWS services internally |
| **External (CloudHSM)** | On-premises HSM | Manual | Yes | FIPS 140-2 Level 3, full isolation |
| **Custom Key Store (CloudHSM)** | Customer-managed in CloudHSM | Manual | Yes | Same as external but integrated |

### For Full Control + Audit + Rotation
```
Requirements: Full control + Audit all usage + Annual rotation
Answer: SSE-KMS with CUSTOMER-MANAGED keys + automatic rotation + CloudTrail
```

### Key Policy Elements
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789:root"},
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow specific role to decrypt",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789:role/AppRole"},
      "Action": ["kms:Decrypt", "kms:DescribeKey"],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "s3.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```

### CloudTrail Integration
- Every KMS API call is logged in CloudTrail
- `Decrypt`, `GenerateDataKey`, `Encrypt` all logged
- Use for: compliance auditing, anomaly detection, key usage analysis

### Exam Traps
- ❌ "SSE-C for audit and rotation" → SSE-C has no CloudTrail audit, manual rotation only
- ❌ "AWS-managed keys for full control" → AWS controls the policy
- ❌ "SSE-S3 for key rotation control" → SSE-S3 keys are opaque to customer
- ✅ "Full control + audit + rotation" → Customer-managed KMS + CloudTrail
- ✅ "Track every decryption" → Customer-managed KMS key + CloudTrail

---

## 5. DYNAMODB HIGH AVAILABILITY

### Built-In HA (No Configuration Needed)
| Feature | Details |
|---------|---------|
| **Replication** | Automatic across **3 AZs** in a region |
| **Durability** | 99.999999999% (11 9's) |
| **Failover** | Automatic, transparent to application |
| **Consistency** | Eventual consistency by default; Strongly consistent reads optional |

```
DynamoDB Table (Region)
    ├── AZ-1 (Primary copy + replicas)
    ├── AZ-2 (Replica)
    └── AZ-3 (Replica)
```

### When to Use Global Tables
| Scenario | Solution |
|----------|----------|
| Single region, need HA | **Standard DynamoDB** (already 3-AZ) |
| Multi-region, need HA + low latency reads | **DynamoDB Global Tables** |
| Multi-region, need disaster recovery | **Global Tables** (active-active) |

### Global Tables Features
- Active-active replication across regions
- Sub-second replication latency
- Conflict resolution (last writer wins)
- Must be on-demand or provisioned with auto-scaling

### Exam Traps
- ❌ "Enable Multi-AZ on DynamoDB" → DynamoDB is ALREADY multi-AZ by default
- ❌ "Use Global Tables for single-region HA" → Overkill; standard DynamoDB is sufficient
- ❌ "DynamoDB is single-AZ" → FALSE; it's 3-AZ by design
- ✅ "DynamoDB automatically replicates across AZs" → TRUE, built-in
- ✅ "Multi-region HA for DynamoDB" → Global Tables

---

## 6. ALB FEATURES: Cross-Zone Load Balancing

### Cross-Zone Load Balancing
| Aspect | Details |
|--------|---------|
| **Default** | ON for ALB (cannot disable) |
| **Behavior** | Distributes traffic evenly across ALL registered targets in ALL AZs |
| **Without it** | Each ALB node distributes only to targets in its own AZ |
| **Use Case** | Ensure even distribution when target counts differ across AZs |

```
Without Cross-Zone:
  AZ-1 (2 targets) → ALB Node 1 → 50% traffic to each
  AZ-2 (4 targets) → ALB Node 2 → 50% traffic to each (but only 2 targets!)

With Cross-Zone (ALB default):
  All 6 targets receive equal traffic regardless of AZ
```

### Health Checks vs. Cross-Zone
| Feature | What It Does |
|---------|-------------|
| **Health Checks** | Marks unhealthy targets as "unhealthy" (stops sending traffic) |
| **Cross-Zone** | Routes traffic across AZ boundaries to ALL healthy targets |
| **Both Together** | Traffic goes to ALL healthy targets in ALL AZs |

### Exam Traps
- ❌ "Health checks alone route across AZs" → Health checks only mark targets; cross-zone routes traffic
- ❌ "Disable cross-zone on ALB" → ALB has cross-zone always ON
- ✅ "Even distribution across AZs with different target counts" → Cross-zone load balancing
- ✅ "ALB automatically routes to healthy targets in other AZs" → Cross-zone + health checks

---

## 7. EC2 PLACEMENT GROUPS

### Types
| Type | Use Case | Characteristics |
|------|----------|-----------------|
| **Cluster** | HPC, low-latency networking | Same AZ, same rack, 10 Gbps throughput, lowest latency |
| **Spread** | Critical instances, fault isolation | Different racks (7 per AZ), max 7 instances per AZ per group |
| **Partition** | Large distributed workloads | Multiple partitions (racks), isolated fault domains, 100s of instances |

### Cluster Placement Group (HPC)
```
Cluster PG (Single AZ)
├── Rack 1: Instance A, Instance B, Instance C (10 Gbps mesh)
├── Same rack = same network spine = lowest latency
└── Best for: HPC, ML training, real-time financial modeling
```

### Spread Placement Group (Isolation)
```
Spread PG (Single AZ)
├── Rack 1: Instance A (isolated)
├── Rack 2: Instance B (isolated)
├── Rack 3: Instance C (isolated)
└── Best for: Small critical sets, max 7 per AZ
```

### Partition Placement Group (Large Scale)
```
Partition PG
├── Partition 1 (Rack 1-3): Instances 1-50
├── Partition 2 (Rack 4-6): Instances 51-100
├── Partition 3 (Rack 7-9): Instances 101-150
└── Best for: Kafka, Cassandra, HDFS (isolate node failures)
```

### Exam Traps
- ❌ "Enhanced networking for HPC cluster" → Enhanced networking is single-instance; Cluster PG is for inter-instance
- ❌ "Spread PG for HPC" → Spread isolates instances; Cluster groups them for low latency
- ❌ "Partition PG for lowest latency" → Partition is for fault isolation at scale, not latency
- ✅ "HPC needs lowest inter-instance latency" → Cluster placement group
- ✅ "Isolate critical instances from each other" → Spread placement group
- ✅ "Large distributed database with isolated failure domains" → Partition placement group

---

## 8. S3 STORAGE CLASSES: Precise Retrieval SLAs

### Storage Class Comparison
| Class | Min Storage | Retrieval | Use Case | Cost |
|-------|-------------|-----------|----------|------|
| **S3 Standard** | None | Immediate | Frequently accessed | Highest |
| **S3 Intelligent-Tiering** | None | Immediate | Unknown/variable access | Low (auto-optimizes) |
| **S3 Standard-IA** | 30 days | Immediate | Infrequent access, quick retrieval | Lower |
| **S3 One Zone-IA** | 30 days | Immediate | Infrequent, reproducible data | Lowest (single AZ) |
| **S3 Glacier Instant Retrieval** | 90 days | Milliseconds | Archive, rare but urgent access | Very low |
| **S3 Glacier Flexible Retrieval** | 90 days | 1-12 hours | Archive, bulk retrieval acceptable | Lower |
| **S3 Glacier Deep Archive** | 180 days | 12-48 hours | Long-term compliance, rarely accessed | Lowest |

### Retrieval SLA Decision Tree
```
Need data within milliseconds?
    → YES → Glacier Instant Retrieval (if 90+ days old)
    → NO → Continue...

Need data within 12 hours?
    → YES → Glacier Flexible Retrieval (1-12 hours)
    → NO → Continue...

Need data within 48 hours?
    → YES → Glacier Deep Archive (12-48 hours)
    → NO → Not suitable for Glacier
```

### Lifecycle Policy Example
```
Day 0-30: S3 Standard (frequent access)
Day 30-90: S3 Standard-IA (infrequent access, immediate retrieval)
Day 90+: S3 Glacier Deep Archive (compliance, 12-48 hr retrieval OK)
```

### Exam Traps
- ❌ "Deep Archive for 12-hour retrieval" → Deep Archive is 12-48 hours; Flexible Retrieval is 1-12 hours
- ❌ "One Zone-IA for critical data" → Single AZ = data loss risk if AZ fails
- ❌ "Standard-IA for 7-year retention only" → Can stay in Standard-IA indefinitely; just minimum 30 days
- ✅ "12-hour retrieval, 5-year retention" → Glacier Flexible Retrieval
- ✅ "7-year compliance, 48-hour retrieval OK" → Glacier Deep Archive
- ✅ "Unknown access patterns" → S3 Intelligent-Tiering

---

## 9. HPC COMPUTE: Spot Instances + Checkpointing

### Why Spot for HPC?
| Aspect | Details |
|--------|---------|
| **Cost** | Up to 90% savings vs. On-Demand |
| **Interruption** | AWS can reclaim with 2-minute warning |
| **HPC Fit** | Batch jobs, fault-tolerant, can resume |
| **Checkpointing** | Save progress periodically to S3/EFS |

### Checkpointing Pattern
```
HPC Job on Spot Instance
├── Start from checkpoint (if exists)
├── Process chunk of work
├── Save checkpoint to S3/EFS every N minutes
├── If interrupted → Spot instance reclaimed
└── New Spot instance → Resume from last checkpoint
```

### Why NOT Lambda for HPC?
| Limitation | Impact |
|------------|--------|
| 15-minute timeout | HPC jobs often run hours/days |
| 10 GB memory max | Genomics, ML need 100s of GB |
| No GPU support | Many HPC workloads need GPU |
| Cold starts | Unacceptable for sustained HPC |

### Why NOT Fargate for HPC?
| Limitation | Impact |
|------------|--------|
| No Spot pricing (Fargate on-demand) | More expensive than EC2 Spot |
| Limited instance types | No specialized HPC instances |
| 120-second timeout (Fargate Spot) | Too short for most HPC |

### Exam Traps
- ❌ "Lambda for genomics processing" → 15-min timeout, memory limits
- ❌ "Fargate for cost-sensitive HPC" → No Spot savings, limited types
- ❌ "On-Demand for interruptible batch" → 90% more expensive than Spot
- ✅ "Interruptible HPC, minimize cost" → Spot Instances + checkpointing
- ✅ "Fault-tolerant batch with flexible completion" → AWS Batch + Spot + checkpointing

---

## 10. COST OPTIMIZATION PATTERNS

### Reserved vs. On-Demand vs. Spot vs. Savings Plans
| Workload Pattern | Best Pricing Model |
|-----------------|-------------------|
| Steady-state 24/7 (3 years) | Reserved Instances (3-year, all upfront) or Savings Plans |
| Steady-state 24/7 (1 year) | Reserved Instances (1-year) or Savings Plans |
| Predictable daily/weekly patterns | Scheduled Reserved Instances |
| Variable but within known range | Compute Savings Plans |
| Spiky, unpredictable | On-Demand + Auto Scaling |
| Fault-tolerant, interruptible | Spot Instances |
| Dev/test, business hours only | Scheduled start/stop or Spot |

### Scheduled Start/Stop vs. Manual
| Approach | Cost Savings | Reliability | Best For |
|----------|-----------|-------------|----------|
| **Scheduled (Lambda + EventBridge)** | High (automated) | High | Dev/test, predictable hours |
| **Manual start/stop** | Medium (human error) | Low | Ad-hoc, unpredictable |
| **Auto Scaling scheduled actions** | High | High | Production with time patterns |

### Fargate Spot for Containers
| Aspect | Details |
|--------|---------|
| **Discount** | Up to 70% vs. Fargate on-demand |
| **Interruption** | 2-minute warning, task evicted |
| **Use Case** | Fault-tolerant container workloads |
| **Not For** | Long-running, stateful, interrupt-sensitive tasks |

### Aurora Serverless vs. Reserved
| Scenario | Choice |
|----------|--------|
| Variable, unpredictable traffic | Aurora Serverless v2 |
| Steady, predictable traffic | Reserved RDS/Aurora (3-year) |
| Need both? | Reserved for baseline + Serverless for spikes |

### Exam Traps
- ❌ "Aurora Serverless for steady 24/7 workload" → Reserved is cheaper
- ❌ "Manual stop for dev/test" → Scheduled automation is reliable
- ❌ "Fargate on-demand for variable containers" → Fargate Spot saves more
- ❌ "One Zone-IA for critical compliance data" → Standard-IA is safer (multi-AZ)
- ✅ "3-year steady workload, minimize cost" → Reserved (3-year, all upfront)
- ✅ "Dev/test 9-5 weekdays" → Scheduled instance start/stop
- ✅ "Variable containers, cost-sensitive" → Fargate Spot

---

## QUICK REFERENCE: DECISION TREES

### Encryption Decision Tree
```
Need encryption at rest?
    ├── Who manages keys?
    │   ├── AWS → SSE-S3 or SSE-KMS (AWS-managed)
    │   ├── Customer (full control, audit, rotation) → SSE-KMS (customer-managed)
    │   └── Customer (on-prem HSM) → SSE-KMS (CloudHSM custom key store)
    └── Need client-side encryption?
        └── Yes → Client-side encryption before upload
```

### DR Strategy Decision Tree
```
RTO/RPO requirements?
    ├── RTO < 1 hour, RPO < 1 minute → Multi-Site Active/Active
    ├── RTO < 4 hours, RPO < 1 hour → Warm Standby
    ├── RTO < 12 hours, RPO < 4 hours → Pilot Light
    └── RTO > 24 hours, RPO > 24 hours → Backup and Restore
```

### Database Decision Tree
```
Relational data + complex joins + ACID?
    ├── Yes → RDS/Aurora
    │   ├── MySQL/PostgreSQL → RDS or Aurora
    │   ├── Need auto-scaling reads → Aurora with Auto Scaling replicas
    │   └── Need global tables → Aurora Global Database
    └── No → Continue...

Key-value, schema-less, massive scale?
    ├── Yes → DynamoDB
    └── No → Continue...

Analytics, OLAP, complex aggregations?
    ├── Yes → Redshift
    └── No → Continue...

Document, wide-column, graph, in-memory?
    ├── Yes → DocumentDB, Keyspaces, Neptune, ElastiCache
```

---

## KEY FORMULAS & NUMBERS TO MEMORIZE

| Item | Value |
|------|-------|
| S3 durability | 99.999999999% (11 9's) |
| S3 availability (Standard) | 99.99% |
| EBS io2 durability | 99.999% (5 9's) |
| DynamoDB durability | 99.999999999% (11 9's) |
| DynamoDB AZ replication | 3 AZs (automatic) |
| RDS Multi-AZ failover | Typically < 60 seconds |
| CloudFront edge locations | 450+ globally |
| Lambda timeout max | 15 minutes (900 seconds) |
| Lambda memory max | 10,240 MB (10 GB) |
| Lambda payload max | 6 MB (sync), 256 KB (async) |
| SQS message max size | 256 KB (standard), 256 KB (FIFO) |
| SQS visibility timeout max | 12 hours |
| SQS retention max | 14 days |
| Kinesis Data Streams retention | 365 days (max) |
| EBS snapshot storage | S3 (automatic, incremental) |
| Spot interruption warning | 2 minutes |
| Direct Connect port speeds | 1 Gbps, 10 Gbps, 100 Gbps |
| VPC max CIDR size | /16 (65,536 IPs) |
| VPC min CIDR size | /28 (16 IPs) |
| Security group rules | Inbound + Outbound, stateful |
| NACL rules | Stateless, ordered evaluation |
| IAM role max session duration | 12 hours (default 1 hour) |
| IAM policy max size | 6,144 characters (inline), 5,120 (managed) |
| CloudTrail log retention | 90 days (CloudWatch), indefinite (S3) |
| AWS Config config history | 7 years |

---

## EXAM STRATEGY TIPS

1. **Read the question twice** — identify the KEY constraint (cost, security, performance, HA)
2. **Eliminate wrong answers first** — look for services that don't fit the scenario
3. **Watch for "MOST" and "BEST"** — these require comparing valid options
4. **Know the well-architected pillars** — each question maps to one or more pillars
5. **Serverless first** — if serverless works, it's usually the right answer
6. **Managed > Self-managed** — prefer AWS managed services over DIY
7. **Multi-AZ != Multi-Region** — know which the question asks for
8. **Cost optimization** — Reserved/Savings Plans for steady, Spot for interruptible, On-Demand for variable

---

*Generated for SAA-C03 exam preparation. Focus on these 10 weak areas and review the decision trees before the exam.*
