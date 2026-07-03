# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Deploy Stage Fails** | CodeDeploy Agent | Verify the CodeDeploy agent is running on the EC2 instance (`sudo systemctl status codedeploy-agent`). Verify the EC2 instance has an IAM role allowing S3 access. |
| **Deploy Stage Fails (No Instances)** | Tags | CodeDeploy identifies targets via EC2 tags. Ensure the tag in your Deployment Group matches the tag on your EC2 instance exactly. |
| **Build Stage Fails** | `buildspec.yml` Error | Check the CodeBuild logs. Ensure `buildspec.yml` is at the root of the repository and formatted correctly. |