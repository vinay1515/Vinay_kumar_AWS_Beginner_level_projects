# Deployment Guide

## Step 1: Create Repository & EC2 Target
1. Create a CodeCommit repo. Clone it locally.
2. Launch an EC2 instance running Amazon Linux 2023. Attach an IAM Role granting `AmazonS3ReadOnlyAccess`. Install the CodeDeploy Agent via user data.
3. Tag the EC2 instance (e.g., `Environment=Production`).

## Step 2: Configure CodeDeploy
1. Create a CodeDeploy Application (EC2/On-premises).
2. Create a Deployment Group. Select the EC2 tag created in Step 1.
3. Attach a service role granting CodeDeploy access to read EC2 tags.

## Step 3: Create Pipeline
1. Navigate to CodePipeline > Create pipeline.
2. **Source:** Select CodeCommit and your repository/branch.
3. **Build:** Select CodeBuild. Create a new build project. Select standard Amazon Linux 2 image.
4. **Deploy:** Select CodeDeploy, your application, and deployment group.
5. Create Pipeline.

## Step 4: Push Code
1. Commit your application code, `appspec.yml`, and `buildspec.yml` to the repository.
2. Run `git push`. The pipeline will trigger automatically.
