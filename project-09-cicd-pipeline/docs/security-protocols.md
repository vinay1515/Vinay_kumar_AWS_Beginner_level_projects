# Security Protocols

- **Artifact Encryption:** CodePipeline inherently stores build artifacts in a dedicated S3 bucket, encrypted at rest using AWS KMS.
- **IAM Service Roles:** Every component requires explicit IAM permissions. CodeBuild requires a role to push to S3 and write CloudWatch logs. CodeDeploy requires a role to describe EC2 instances. CodePipeline requires a role to assume the other roles.
- **Agent Verification:** The CodeDeploy agent operates via outbound HTTPS polling to the AWS endpoint, meaning you do not need to open inbound SSH ports for deployments to occur.