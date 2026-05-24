## AWS Auto Scaling Group (ASG) Practice Guide

An Amazon Web Services Auto Scaling Group (ASG) automatically launches or terminates EC2 instances based on demand.

Main goals:

* High availability
* Automatic scaling
* Cost optimization
* Fault tolerance

---

# 1. Auto Scaling Group Architecture

Typical architecture:

```text
Users
   |
Application Load Balancer
   |
Auto Scaling Group
   |
EC2 Instances
```

---

# 2. Capacity Settings

Capacity settings define how many EC2 instances ASG maintains.

| Setting          | Meaning                                   |
| ---------------- | ----------------------------------------- |
| Desired Capacity | Number of instances ASG tries to maintain |
| Minimum Capacity | Lowest number of instances                |
| Maximum Capacity | Highest number of instances               |

Example:

```text
Min = 2
Desired = 3
Max = 6
```

Behavior:

* ASG keeps 3 running instances
* Never goes below 2
* Never exceeds 6

---

## CLI Example

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version=1 \
  --min-size 2 \
  --max-size 6 \
  --desired-capacity 3 \
  --vpc-zone-identifier "subnet-111,subnet-222"
```

---

# 3. Health Check Replacement

ASG continuously checks instance health.

If an instance becomes unhealthy:

1. ASG terminates it
2. Launches a new instance automatically

Health check types:

| Type | Description                      |
| ---- | -------------------------------- |
| EC2  | Checks EC2 instance status       |
| ELB  | Uses Load Balancer health checks |

---

## Example

Suppose:

```text
Desired Capacity = 3
```

One instance crashes.

ASG action:

```text
Unhealthy instance terminated
New instance launched automatically
```

Desired capacity remains:

```text
3
```

---

## Enable ELB Health Checks

```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --health-check-type ELB \
  --health-check-grace-period 300
```

---

# 4. Scaling Policies

Scaling policies define WHEN and HOW ASG scales.

---

# A. Simple Scaling Policy

Basic scaling rule.

Example:

```text
If CPU > 70%
Add 1 instance
```

OR

```text
If CPU < 30%
Remove 1 instance
```

---

## Flow

```text
CloudWatch Alarm
      |
Trigger Scaling Policy
      |
ASG Adds/Removes Instances
```

---

## CLI Example

Create scale-out policy:

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name scale-out-policy \
  --adjustment-type ChangeInCapacity \
  --scaling-adjustment 1
```

---

# B. Step Scaling Policy

More advanced than Simple Scaling.

Different scaling actions for different metric ranges.

Example:

| CPU Usage | Action          |
| --------- | --------------- |
| 60–70%    | Add 1 instance  |
| 70–85%    | Add 2 instances |
| >85%      | Add 3 instances |

---

## Why Use Step Scaling?

* Faster reaction to heavy traffic
* Better control
* Avoids slow scaling

---

## Example Scenario

```text
Current instances = 2
CPU = 88%
```

Action:

```text
ASG adds 3 instances
Total = 5
```

---

# C. Target Tracking Scaling Policy

Most commonly used policy.

You define a target metric.

ASG automatically maintains it.

Example:

```text
Keep average CPU at 50%
```

ASG automatically:

* Adds instances when CPU rises
* Removes instances when CPU drops

---

## Advantages

* Easy setup
* Fully automatic
* Similar to thermostat behavior

---

## CLI Example

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name cpu-target-tracking \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
      "PredefinedMetricSpecification": {
          "PredefinedMetricType": "ASGAverageCPUUtilization"
      },
      "TargetValue": 50.0
  }'
```

---

# D. Predictive Scaling

Uses machine learning to predict future traffic.

ASG launches instances BEFORE traffic increases.

Useful for:

* Daily traffic patterns
* Business hours
* Known peak times

---

## Example

Traffic usually increases at:

```text
8:00 AM every day
```

Predictive scaling:

```text
Launches instances before 8:00 AM
```

---

## Benefits

* Better performance
* Reduced latency
* Prevents scaling delays

---

# Comparison Table

| Policy          | Complexity | Best Use                |
| --------------- | ---------- | ----------------------- |
| Simple          | Easy       | Basic environments      |
| Step            | Medium     | Variable workloads      |
| Target Tracking | Easy       | Most production systems |
| Predictive      | Advanced   | Predictable traffic     |

---

# Recommended Learning Order

1. Capacity Settings
2. Health Checks
3. Simple Scaling
4. Step Scaling
5. Target Tracking
6. Predictive Scaling

---

# Best Practice for Real Production

Most companies use:

```text
ALB + ASG + Target Tracking
```

Example:

```text
Target CPU = 50%
Min = 2
Max = 10
```

This provides:

* High availability
* Automatic scaling
* Cost optimization



## Official AWS Documentation

* [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html?utm_source=chatgpt.com)
* [AWS Auto Scaling Policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html?utm_source=chatgpt.com)
* [AWS Predictive Scaling](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html?utm_source=chatgpt.com)
