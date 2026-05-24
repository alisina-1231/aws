# 1. Create IAM Policy for S3 Access (attach to Role)

# This policy allows access only to one bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME"
    },
    {
      "Sid": "ObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```

---

# 2.  Create Trust Policy for STS Assume Role

# This allows the IAM user to assume the role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:user/limited-user"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

# 3. 🧱 Create IAM Role (S3AccessRole)

### CLI example:

```bash
aws iam create-role \
--role-name S3AccessRole \
--assume-role-policy-document file://trust-policy.json
```

---

# 4. Attach S3 Policy to Role

```bash
aws iam put-role-policy \
--role-name S3AccessRole \
--policy-name S3AccessPolicy \
--policy-document file://s3-policy.json
```

---

# 5. 👤 Create IAM User (NO permissions)

```bash
aws iam create-user --user-name limited-user
```

No S3 policies attached ❌

---

# 6. 🔐 Allow User to Assume Role (IMPORTANT)

Attach this policy to the user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::832014379019:role/S3AccessRole"
    }
  ]
}
```

```bash
aws iam put-user-policy \
--user-name machine-user \
--policy-name AssumeS3Role \
--policy-document file://assume-role-policy.json
```

---

# 7. 🔁 Use STS to Get Temporary Credentials

From CLI:

```bash
aws sts assume-role \
--role-arn arn:aws:iam::832014379019:role/S3AccessRole \
--role-session-name s3session
```

You will get:

```json
{
  "Credentials": {
    "AccessKeyId": "...",
    "SecretAccessKey": "...",
    "SessionToken": "..."
  }
}
```

---

# 8. 📦 Use S3 with Temporary Credentials

Export them:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

Now test:

```bash
aws s3 ls s3://YOUR_BUCKET_NAME
```

---


