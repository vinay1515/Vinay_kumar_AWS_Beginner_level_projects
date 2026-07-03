# Cleanup Guide

To tear down the CI/CD pipeline and avoid ongoing charges:

1. **Delete Pipeline:** Navigate to CodePipeline and delete the pipeline.
2. **Delete CodeDeploy:** Navigate to CodeDeploy, delete the deployment group, then delete the application.
3. **Delete CodeBuild:** Navigate to CodeBuild and delete the build project.
4. **Delete CodeCommit:** Navigate to CodeCommit and delete the repository.
5. **Delete S3 Artifact Bucket:** Empty the S3 bucket created by CodePipeline (starts with `codepipeline-us-east-1-`), then delete it.
6. **Terminate EC2:** Terminate the target EC2 instance.
