# Comprehensive Deployment Guide

This guide details the complete, enterprise-grade process for provisioning S3 versioning, architecting lifecycle policies, and enabling Cross-Region Replication (CRR). We will walk through the conceptual "why" alongside the technical "how".

## 🚀 PRE-FLIGHT CHECKS

Before deploying cloud infrastructure, always validate your terminal session identity and regional configuration. Attempting to deploy replication policies with the wrong IAM permissions or in the wrong region will result in cascading failures.

Run these commands in PowerShell to confirm your environment is ready:
```powershell
# Confirm you are authenticated as an Administrator or Power User
aws sts get-caller-identity

# Confirm your default region is set correctly (e.g., us-east-1)
aws configure get region

# Baseline Check: View existing buckets to ensure CLI connectivity
aws s3 ls
```

---

## 🏗️ PART 1 — PROVISION THE SOURCE BUCKET

The Source Bucket acts as the primary data lake or application storage layer. By enabling Versioning at creation, we ensure that from day 1, no data can be accidentally permanently overwritten.

### 🖥️ Method 1: AWS Management Console
1. Navigate to **S3** → **Create bucket**.
2. **Bucket name**: `s3-versioning-lab-yourname` (Bucket names must be globally unique across all AWS customers).
3. **Region**: `US East (N. Virginia) us-east-1`
4. **Object Ownership**: ACLs disabled (default). This is an AWS best practice ensuring the bucket owner retains full control of all objects regardless of who uploads them.
5. **Block Public Access**: Leave ALL blocks ON. This prevents any accidental data leaks to the internet.
6. **Bucket Versioning**: **Enable**. This is the critical setting for this lab.
7. **Encryption**: SSE-S3 (default). AWS automatically manages the encryption keys.
8. Click **Create bucket**.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash

# Set variables
SOURCE_BUCKET="s3-versioning-lab-yourname"
SOURCE_REGION="us-east-1"

# Create source bucket
aws s3api create-bucket \
  --bucket $SOURCE_BUCKET \
  --region $SOURCE_REGION

# Enable versioning on source bucket
aws s3api put-bucket-versioning \
  --bucket $SOURCE_BUCKET \
  --versioning-configuration Status=Enabled

# Verify versioning is enabled
aws s3api get-bucket-versioning --bucket $SOURCE_BUCKET
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
# Set variables
$SOURCE_BUCKET = "s3-versioning-lab-yourname"
$SOURCE_REGION = "us-east-1"

# Create source bucket
aws s3api create-bucket `
  --bucket $SOURCE_BUCKET `
  --region $SOURCE_REGION

# Enable versioning on source bucket
aws s3api put-bucket-versioning `
  --bucket $SOURCE_BUCKET `
  --versioning-configuration Status=Enabled

# Verify versioning is enabled
aws s3api get-bucket-versioning --bucket $SOURCE_BUCKET
```
---

## 🧪 PART 2 — THE VERSIONING WORKFLOW 

This phase demonstrates how Versioning protects you from catastrophic data loss.

### 🖥️ Method 1: AWS Management Console
1. Upload `document.txt` to the bucket.
2. Modify `document.txt` locally and upload it again.
3. In the bucket UI, toggle **Show versions** to see both versions.
4. Delete the current version.
5. In the versions list, select the **Delete marker** and delete it to restore the file.

### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
SOURCE_BUCKET="s3-versioning-lab-yourname"

# Create a working directory
mkdir -p ~/s3-versioning-lab
cd ~/s3-versioning-lab

# Create version 1 of a test file
cat << EOF > document.txt
This is version 1 of my important document.
Created: $(date)
Author: YourName
EOF

# Upload version 1
aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Overwrite with version 2
cat << EOF > document.txt
This is version 2 - UPDATED content.
Updated: $(date)
Important changes made here.
EOF

aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Upload version 3
cat << EOF > document.txt
This is version 3 - FINAL content.
Finalized: $(date)
This is the current production version.
EOF

aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Save all version IDs for later use
VERSIONS=$(aws s3api list-object-versions --bucket $SOURCE_BUCKET --prefix document.txt)

V1_ID=$(echo "$VERSIONS" | jq -r '.Versions[-1].VersionId')  # oldest = version 1
V2_ID=$(echo "$VERSIONS" | jq -r '.Versions[-2].VersionId')  # middle = version 2
V3_ID=$(echo "$VERSIONS" | jq -r '.Versions[0].VersionId')   # newest = version 3

echo "Version 1 ID: $V1_ID"
echo "Version 2 ID: $V2_ID"
echo "Version 3 ID: $V3_ID"

# Download version 1 specifically
aws s3api get-object \
  --bucket $SOURCE_BUCKET \
  --key document.txt \
  --version-id $V1_ID \
  recovered-v1.txt

echo "Recovered version 1 content:"
cat recovered-v1.txt

# Delete the object
aws s3 rm s3://$SOURCE_BUCKET/document.txt

# Get the delete marker version ID
DELETE_MARKER_ID=$(aws s3api list-object-versions \
  --bucket $SOURCE_BUCKET \
  --prefix document.txt | jq -r '.DeleteMarkers[0].VersionId')

echo "Delete marker ID: $DELETE_MARKER_ID"

# RECOVER — remove the delete marker to restore the file
aws s3api delete-object \
  --bucket $SOURCE_BUCKET \
  --key document.txt \
  --version-id $DELETE_MARKER_ID

# Now download it again — file is back
aws s3 cp s3://$SOURCE_BUCKET/document.txt recovered-from-delete.txt
echo "Recovered after delete content:"
cat recovered-from-delete.txt
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$SOURCE_BUCKET = "s3-versioning-lab-yourname"

# Create a working directory
mkdir C:\Users\$env:USERNAME\s3-versioning-lab -ErrorAction SilentlyContinue
cd C:\Users\$env:USERNAME\s3-versioning-lab

# Create version 1 of a test file
"This is version 1 of my important document.
Created: $(Get-Date)
Author: YourName" | Out-File -FilePath "document.txt" -Encoding utf8

# Upload version 1
aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Overwrite with version 2
"This is version 2 - UPDATED content.
Updated: $(Get-Date)
Important changes made here." | Out-File -FilePath "document.txt" -Encoding utf8

aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Upload version 3
"This is version 3 - FINAL content.
Finalized: $(Get-Date)
This is the current production version." | Out-File -FilePath "document.txt" -Encoding utf8

aws s3 cp document.txt s3://$SOURCE_BUCKET/document.txt

# Save all version IDs for later use
$VERSIONS = aws s3api list-object-versions `
  --bucket $SOURCE_BUCKET `
  --prefix document.txt | ConvertFrom-Json

$V1_ID = $VERSIONS.Versions[-1].VersionId  # oldest = version 1
$V2_ID = $VERSIONS.Versions[-2].VersionId  # middle = version 2
$V3_ID = $VERSIONS.Versions[0].VersionId   # newest = version 3

Write-Host "Version 1 ID: $V1_ID"
Write-Host "Version 2 ID: $V2_ID"
Write-Host "Version 3 ID: $V3_ID"

# Download version 1 specifically
aws s3api get-object `
  --bucket $SOURCE_BUCKET `
  --key document.txt `
  --version-id $V1_ID `
  recovered-v1.txt

Write-Host "Recovered version 1 content:"
cat recovered-v1.txt

# Delete the object
aws s3 rm s3://$SOURCE_BUCKET/document.txt

# Get the delete marker version ID
$DELETE_MARKER_ID = (aws s3api list-object-versions `
  --bucket $SOURCE_BUCKET `
  --prefix document.txt | ConvertFrom-Json).DeleteMarkers[0].VersionId

Write-Host "Delete marker ID: $DELETE_MARKER_ID"

# RECOVER — remove the delete marker to restore the file
aws s3api delete-object `
  --bucket $SOURCE_BUCKET `
  --key document.txt `
  --version-id $DELETE_MARKER_ID

# Now download it again — file is back
aws s3 cp s3://$SOURCE_BUCKET/document.txt recovered-from-delete.txt
Write-Host "Recovered after delete content:"
cat recovered-from-delete.txt
```
---

## 📉 PART 3 — ARCHITECTING LIFECYCLE POLICIES

To prevent versioning from doubling or tripling your storage costs over time, we deploy an automated Lifecycle Policy. This policy dictates data tiering rules.

### 🖥️ Method 1: AWS Management Console
1. Click your source bucket → **Management** tab → **Create lifecycle rule**.
2. **Lifecycle rule name**: `cost-optimization-policy`
3. **Rule scope**: Apply to all objects in the bucket.
4. **Lifecycle rule actions** (check ALL): 
   - Transition current versions...
   - Transition noncurrent versions...
   - Expire current versions...
   - Permanently delete noncurrent versions...
   - Delete expired object delete markers or incomplete multipart uploads
5. **Configure Tiering Logistics**:
   - **Current Versions:** Move to `Standard-IA` (30 days) → Move to `Glacier Flexible Retrieval` (90 days).
   - **Noncurrent Versions:** Move to `Standard-IA` (30 days) → Move to `Glacier Flexible Retrieval` (90 days).
   - **Expiration/Deletion:** Expire current versions at 365 days. Permanently delete noncurrent versions at 90 days.
   - **Hygiene:** Delete incomplete multipart uploads after 7 days (prevents paying for broken, half-uploaded large files).
6. Click **Create rule**.


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
SOURCE_BUCKET="s3-versioning-lab-yourname"

# Create the lifecycle policy JSON
cat << 'EOF' > lifecycle-policy.json
{
  "Rules": [
    {
      "ID": "cost-optimization-policy",
      "Status": "Enabled",
      "Filter": {"Prefix": ""},
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "NoncurrentDays": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 90
      },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 7
      }
    }
  ]
}
EOF

# Apply the lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket $SOURCE_BUCKET \
  --lifecycle-configuration file://lifecycle-policy.json

# Verify the policy was applied
aws s3api get-bucket-lifecycle-configuration --bucket $SOURCE_BUCKET
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$SOURCE_BUCKET = "s3-versioning-lab-yourname"

# Create the lifecycle policy JSON
$LIFECYCLE_POLICY = '{
  "Rules": [
    {
      "ID": "cost-optimization-policy",
      "Status": "Enabled",
      "Filter": {"Prefix": ""},
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "NoncurrentVersionTransitions": [
        {
          "NoncurrentDays": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "NoncurrentDays": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 90
      },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 7
      }
    }
  ]
}'

# Save to file
$LIFECYCLE_POLICY | Out-File -FilePath "lifecycle-policy.json" -Encoding utf8

# Apply the lifecycle policy
aws s3api put-bucket-lifecycle-configuration `
  --bucket $SOURCE_BUCKET `
  --lifecycle-configuration file://lifecycle-policy.json

# Verify the policy was applied
aws s3api get-bucket-lifecycle-configuration --bucket $SOURCE_BUCKET
```
---

## 🌍 PART 4 — CONFIGURING CROSS-REGION REPLICATION (CRR)

For Disaster Recovery (DR), we want every object in `us-east-1` to automatically replicate to a datacenter hundreds of miles away in `us-west-2`.

### 🖥️ Method 1: AWS Management Console
1. **Provision the Destination (DR) Bucket**:
   - Create `s3-versioning-lab-yourname-replica` in `US West (Oregon) us-west-2`.
   - **CRITICAL:** You *must* enable Bucket Versioning on the destination bucket, or replication will fail.
2. **Provision the IAM Service Role**:
   - Create an IAM role (e.g., `s3-replication-role`) that allows S3 to assume it.
   - Attach a policy granting `s3:ReplicateObject` on the destination, and `s3:GetObjectVersionForReplication` on the source.
3. **Deploy the Replication Rule**:
   - On the source bucket → **Management** tab → **Replication rules** → **Create replication rule**.
   - **Destination**: Choose the replica bucket in us-west-2.
   - **IAM role**: Select the replication role you just built.
   - **Delete marker replication**: Enable (ensures that if you soft-delete a file in Prod, it is soft-deleted in DR).
   - Click **Save**. *Choose NOT to replicate existing objects to save time and bandwidth.*


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
SOURCE_BUCKET="s3-versioning-lab-yourname"
DEST_BUCKET="s3-versioning-lab-yourname-replica"
DEST_REGION="us-west-2"

# Create destination bucket in us-west-2
aws s3api create-bucket \
  --bucket $DEST_BUCKET \
  --region $DEST_REGION \
  --create-bucket-configuration LocationConstraint=$DEST_REGION

# Enable versioning on destination (required for CRR)
aws s3api put-bucket-versioning \
  --bucket $DEST_BUCKET \
  --versioning-configuration Status=Enabled

# Verify
aws s3api get-bucket-versioning --bucket $DEST_BUCKET

# Get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity \
  --query "Account" --output text)

echo "Account ID: $ACCOUNT_ID"

# Create the replication IAM role
aws iam create-role \
  --role-name s3-replication-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }'

# Create replication permissions policy
cat << EOF > replication-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::$SOURCE_BUCKET"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Resource": "arn:aws:s3:::$SOURCE_BUCKET/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Resource": "arn:aws:s3:::$DEST_BUCKET/*"
    }
  ]
}
EOF

# Create and attach the policy to the role
aws iam put-role-policy \
  --role-name s3-replication-role \
  --policy-name s3-replication-permissions \
  --policy-document file://replication-policy.json

echo "Replication IAM role created and policy attached"

# Get the role ARN
ROLE_ARN=$(aws iam get-role \
  --role-name s3-replication-role \
  --query "Role.Arn" --output text)

echo "Role ARN: $ROLE_ARN"

# Enable replication on source bucket
aws s3api put-bucket-replication \
  --bucket $SOURCE_BUCKET \
  --replication-configuration "{
    \"Role\": \"$ROLE_ARN\",
    \"Rules\": [{
      \"ID\": \"replicate-to-us-west-2\",
      \"Status\": \"Enabled\",
      \"Filter\": {\"Prefix\":\"\"},
      \"Destination\": {
        \"Bucket\": \"arn:aws:s3:::$DEST_BUCKET\",
        \"StorageClass\": \"STANDARD\"
      },
      \"DeleteMarkerReplication\": {
        \"Status\": \"Enabled\"
      }
    }]
  }"

# Verify replication configuration
aws s3api get-bucket-replication --bucket $SOURCE_BUCKET
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$SOURCE_BUCKET = "s3-versioning-lab-yourname"
$DEST_BUCKET   = "s3-versioning-lab-yourname-replica"
$DEST_REGION   = "us-west-2"

# Create destination bucket in us-west-2
aws s3api create-bucket `
  --bucket $DEST_BUCKET `
  --region $DEST_REGION `
  --create-bucket-configuration LocationConstraint=$DEST_REGION

# Enable versioning on destination (required for CRR)
aws s3api put-bucket-versioning `
  --bucket $DEST_BUCKET `
  --versioning-configuration Status=Enabled

# Verify
aws s3api get-bucket-versioning --bucket $DEST_BUCKET

# Get your account ID
$ACCOUNT_ID = aws sts get-caller-identity `
  --query "Account" --output text

Write-Host "Account ID: $ACCOUNT_ID"

# Create the replication IAM role
aws iam create-role `
  --role-name s3-replication-role `
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  }'

# Create replication permissions policy
$REPLICATION_POLICY = "{
  `"Version`": `"2012-10-17`",
  `"Statement`": [
    {
      `"Effect`": `"Allow`",
      `"Action`": [
        `"s3:GetReplicationConfiguration`",
        `"s3:ListBucket`"
      ],
      `"Resource`": `"arn:aws:s3:::$SOURCE_BUCKET`"
    },
    {
      `"Effect`": `"Allow`",
      `"Action`": [
        `"s3:GetObjectVersionForReplication`",
        `"s3:GetObjectVersionAcl`",
        `"s3:GetObjectVersionTagging`"
      ],
      `"Resource`": `"arn:aws:s3:::$SOURCE_BUCKET/*`"
    },
    {
      `"Effect`": `"Allow`",
      `"Action`": [
        `"s3:ReplicateObject`",
        `"s3:ReplicateDelete`",
        `"s3:ReplicateTags`"
      ],
      `"Resource`": `"arn:aws:s3:::$DEST_BUCKET/*`"
    }
  ]
}"

# Save policy to file
$REPLICATION_POLICY | Out-File -FilePath "replication-policy.json" -Encoding utf8

# Create and attach the policy to the role
aws iam put-role-policy `
  --role-name s3-replication-role `
  --policy-name s3-replication-permissions `
  --policy-document file://replication-policy.json

Write-Host "Replication IAM role created and policy attached"

# Get the role ARN
$ROLE_ARN = aws iam get-role `
  --role-name s3-replication-role `
  --query "Role.Arn" --output text

Write-Host "Role ARN: $ROLE_ARN"

# Enable replication on source bucket
aws s3api put-bucket-replication `
  --bucket $SOURCE_BUCKET `
  --replication-configuration "{
    `"Role`": `"$ROLE_ARN`",
    `"Rules`": [{
      `"ID`": `"replicate-to-us-west-2`",
      `"Status`": `"Enabled`",
      `"Filter`": {`"Prefix`":`"`"},
      `"Destination`": {
        `"Bucket`": `"arn:aws:s3:::$DEST_BUCKET`",
        `"StorageClass`": `"STANDARD`"
      },
      `"DeleteMarkerReplication`": {
        `"Status`": `"Enabled`"
      }
    }]
  }"

# Verify replication configuration
aws s3api get-bucket-replication --bucket $SOURCE_BUCKET
```
---

## 🔍 PART 5 — VALIDATE REPLICATION SLA

### 🖥️ Method 1: Interactive/Manual validation
1. Upload a new test file (`crr-test.txt`) to the SOURCE bucket.
2. S3 Replication is asynchronous. Wait roughly 15-30 seconds.
3. Query the destination bucket in `us-west-2` to prove the AWS backbone successfully transferred the data.
   ```powershell
   aws s3api head-object --bucket $DEST_BUCKET --key crr-test.txt --region us-west-2
   ```
   *Look for `ReplicationStatus: REPLICA` in the metadata response. This proves the architecture is working perfectly.*


### 🐧 Method 2: AWS CLI (Bash)
```bash
#!/bin/bash
SOURCE_BUCKET="s3-versioning-lab-yourname"
DEST_BUCKET="s3-versioning-lab-yourname-replica"
DEST_REGION="us-west-2"

# Upload a new test file to SOURCE bucket
cat << EOF > crr-test.txt
CRR Test file - uploaded $(date)
This object should automatically replicate to us-west-2
EOF

aws s3 cp crr-test.txt s3://$SOURCE_BUCKET/crr-test.txt
echo "Uploaded to source bucket. Waiting 30 seconds for replication..."

# Wait for replication (usually 15-30 seconds for small objects)
sleep 30

# Check if the object exists in the DESTINATION bucket (us-west-2)
aws s3api head-object \
  --bucket $DEST_BUCKET \
  --key crr-test.txt \
  --region $DEST_REGION

# List objects in destination to confirm
aws s3 ls s3://$DEST_BUCKET --region $DEST_REGION

# Check replication status on source object
aws s3api head-object \
  --bucket $SOURCE_BUCKET \
  --key crr-test.txt

# Upload a second file and verify it also replicates
cat << EOF > crr-test-2.txt
Second CRR test - $(date)
EOF

aws s3 cp crr-test-2.txt s3://$SOURCE_BUCKET/crr-test-2.txt
sleep 30

aws s3 ls s3://$DEST_BUCKET --region $DEST_REGION
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$SOURCE_BUCKET = "s3-versioning-lab-yourname"
$DEST_BUCKET   = "s3-versioning-lab-yourname-replica"
$DEST_REGION   = "us-west-2"

# Upload a new test file to SOURCE bucket
"CRR Test file - uploaded $(Get-Date)
This object should automatically replicate to us-west-2" `
  | Out-File -FilePath "crr-test.txt" -Encoding utf8

aws s3 cp crr-test.txt s3://$SOURCE_BUCKET/crr-test.txt
Write-Host "Uploaded to source bucket. Waiting 30 seconds for replication..."

# Wait for replication (usually 15-30 seconds for small objects)
Start-Sleep -Seconds 30

# Check if the object exists in the DESTINATION bucket (us-west-2)
aws s3api head-object `
  --bucket $DEST_BUCKET `
  --key crr-test.txt `
  --region $DEST_REGION

# List objects in destination to confirm
aws s3 ls s3://$DEST_BUCKET --region $DEST_REGION

# Check replication status on source object
aws s3api head-object `
  --bucket $SOURCE_BUCKET `
  --key crr-test.txt

# Upload a second file and verify it also replicates
"Second CRR test - $(Get-Date)" `
  | Out-File -FilePath "crr-test-2.txt" -Encoding utf8

aws s3 cp crr-test-2.txt s3://$SOURCE_BUCKET/crr-test-2.txt
Start-Sleep -Seconds 30

aws s3 ls s3://$DEST_BUCKET --region $DEST_REGION
```
---

## 🧹 PART 6 — PROPER INFRASTRUCTURE TEARDOWN

To prevent recurring AWS charges, proceed to the `docs/cleanup-guide.md` to run the tear-down scripts. Versioned buckets require a specialized deletion loop to destroy underlying versions before the bucket can be removed.

### 🐧 Method 1: AWS CLI (Bash)
```bash
#!/bin/bash
SOURCE_BUCKET="s3-versioning-lab-yourname"
DEST_BUCKET="s3-versioning-lab-yourname-replica"
SOURCE_REGION="us-east-1"
DEST_REGION="us-west-2"

# Step 1 — Delete all versions from source bucket
echo "Deleting all versions from source bucket..."

ALL_VERSIONS=$(aws s3api list-object-versions --bucket $SOURCE_BUCKET)

if [ -n "$ALL_VERSIONS" ] && [ "$ALL_VERSIONS" != "null" ]; then
  # Delete all versions
  VERSIONS=$(echo "$ALL_VERSIONS" | jq -c '.Versions[]? | {Key: .Key, VersionId: .VersionId}')
  for v in $VERSIONS; do
    KEY=$(echo $v | jq -r .Key)
    VID=$(echo $v | jq -r .VersionId)
    aws s3api delete-object --bucket $SOURCE_BUCKET --key "$KEY" --version-id "$VID" >/dev/null
  done

  # Delete all delete markers
  MARKERS=$(echo "$ALL_VERSIONS" | jq -c '.DeleteMarkers[]? | {Key: .Key, VersionId: .VersionId}')
  for m in $MARKERS; do
    KEY=$(echo $m | jq -r .Key)
    VID=$(echo $m | jq -r .VersionId)
    aws s3api delete-object --bucket $SOURCE_BUCKET --key "$KEY" --version-id "$VID" >/dev/null
  done
fi

echo "All versions deleted from source bucket"

# Step 2 — Delete source bucket
aws s3api delete-bucket --bucket $SOURCE_BUCKET --region $SOURCE_REGION
echo "Source bucket deleted"

# Step 3 — Empty and delete destination bucket
echo "Deleting destination bucket..."
aws s3 rm s3://$DEST_BUCKET --recursive --region $DEST_REGION

DEST_VERSIONS=$(aws s3api list-object-versions --bucket $DEST_BUCKET --region $DEST_REGION)

if [ -n "$DEST_VERSIONS" ] && [ "$DEST_VERSIONS" != "null" ]; then
  VERSIONS=$(echo "$DEST_VERSIONS" | jq -c '.Versions[]? | {Key: .Key, VersionId: .VersionId}')
  for v in $VERSIONS; do
    KEY=$(echo $v | jq -r .Key)
    VID=$(echo $v | jq -r .VersionId)
    aws s3api delete-object --bucket $DEST_BUCKET --key "$KEY" --version-id "$VID" --region $DEST_REGION >/dev/null
  done

  MARKERS=$(echo "$DEST_VERSIONS" | jq -c '.DeleteMarkers[]? | {Key: .Key, VersionId: .VersionId}')
  for m in $MARKERS; do
    KEY=$(echo $m | jq -r .Key)
    VID=$(echo $m | jq -r .VersionId)
    aws s3api delete-object --bucket $DEST_BUCKET --key "$KEY" --version-id "$VID" --region $DEST_REGION >/dev/null
  done
fi

aws s3api delete-bucket --bucket $DEST_BUCKET --region $DEST_REGION
echo "Destination bucket deleted"

# Step 4 — Delete IAM replication role
aws iam delete-role-policy \
  --role-name s3-replication-role \
  --policy-name s3-replication-permissions 2>/dev/null || true

aws iam delete-role --role-name s3-replication-role 2>/dev/null || true
echo "IAM replication role deleted"

# Step 5 — Verify everything is gone
aws s3 ls | grep "versioning-lab"
```

### 🪟 Method 3: AWS CLI (PowerShell)
```powershell
$SOURCE_BUCKET = "s3-versioning-lab-yourname"
$DEST_BUCKET   = "s3-versioning-lab-yourname-replica"
$SOURCE_REGION = "us-east-1"
$DEST_REGION   = "us-west-2"

# Step 1 — Delete all versions from source bucket
Write-Host "Deleting all versions from source bucket..."

$ALL_VERSIONS = aws s3api list-object-versions `
  --bucket $SOURCE_BUCKET | ConvertFrom-Json

if ($ALL_VERSIONS.Versions) {
  foreach ($version in $ALL_VERSIONS.Versions) {
    aws s3api delete-object `
      --bucket $SOURCE_BUCKET `
      --key $version.Key `
      --version-id $version.VersionId | Out-Null
  }
}

if ($ALL_VERSIONS.DeleteMarkers) {
  foreach ($marker in $ALL_VERSIONS.DeleteMarkers) {
    aws s3api delete-object `
      --bucket $SOURCE_BUCKET `
      --key $marker.Key `
      --version-id $marker.VersionId | Out-Null
  }
}

Write-Host "All versions deleted from source bucket"

# Step 2 — Delete source bucket
aws s3api delete-bucket --bucket $SOURCE_BUCKET --region $SOURCE_REGION
Write-Host "Source bucket deleted"

# Step 3 — Empty and delete destination bucket
Write-Host "Deleting destination bucket..."
aws s3 rm s3://$DEST_BUCKET --recursive --region $DEST_REGION

$DEST_VERSIONS = aws s3api list-object-versions `
  --bucket $DEST_BUCKET --region $DEST_REGION | ConvertFrom-Json

if ($DEST_VERSIONS.Versions) {
  foreach ($version in $DEST_VERSIONS.Versions) {
    aws s3api delete-object `
      --bucket $DEST_BUCKET `
      --key $version.Key `
      --version-id $version.VersionId `
      --region $DEST_REGION | Out-Null
  }
}

if ($DEST_VERSIONS.DeleteMarkers) {
  foreach ($marker in $DEST_VERSIONS.DeleteMarkers) {
    aws s3api delete-object `
      --bucket $DEST_BUCKET `
      --key $marker.Key `
      --version-id $marker.VersionId `
      --region $DEST_REGION | Out-Null
  }
}

aws s3api delete-bucket --bucket $DEST_BUCKET --region $DEST_REGION
Write-Host "Destination bucket deleted"

# Step 4 — Delete IAM replication role
aws iam delete-role-policy `
  --role-name s3-replication-role `
  --policy-name s3-replication-permissions -ErrorAction SilentlyContinue

aws iam delete-role --role-name s3-replication-role -ErrorAction SilentlyContinue
Write-Host "IAM replication role deleted"

# Step 5 — Verify everything is gone
aws s3 ls | Select-String "versioning-lab"
```
