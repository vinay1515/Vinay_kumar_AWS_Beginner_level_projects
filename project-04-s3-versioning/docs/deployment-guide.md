# Deployment Guide

## Step 1: Create Buckets
1. Create a Source Bucket in `ap-south-1`. Under properties, **Enable Versioning**.
2. Create a Destination Bucket in `ap-south-2`. Under properties, **Enable Versioning**.

## Step 2: Implement Lifecycle Policies
1. On the Source Bucket, navigate to the **Management** tab.
2. Create Lifecycle Rule. Apply to all objects.
3. Select "Transition current versions between storage classes".
4. Add Transition 1: Standard-IA after 30 days.
5. Add Transition 2: Glacier Flexible Retrieval after 90 days.

## Step 3: Configure CRR
1. On the Source Bucket, navigate to the **Management** tab.
2. Create Replication Rule.
3. Destination: Select the bucket in `ap-south-2`.
4. IAM Role: Select "Create new role".
5. Save. Do not replicate existing objects.
