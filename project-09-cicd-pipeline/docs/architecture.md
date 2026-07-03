# Architecture Details

## Source (AWS CodeCommit)
- A managed, private Git repository.
- Contains application code, `buildspec.yml` (for CodeBuild), and `appspec.yml` (for CodeDeploy).

## Build (AWS CodeBuild)
- A fully managed build server.
- Spins up a container, pulls the code, executes the commands in `buildspec.yml` (e.g. compiling, testing), and outputs a `.zip` artifact to S3.

## Deploy (AWS CodeDeploy)
- The CodeDeploy Agent installed on the target EC2 instance pulls the artifact from S3.
- Executes lifecycle hooks defined in `appspec.yml` (e.g. stopping the web server, copying files, starting the web server).

## Orchestration (AWS CodePipeline)
- The overarching workflow that links Source -> Build -> Deploy, passing the S3 artifacts between stages and triggering automatically on Git pushes.
