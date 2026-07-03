
<div align="center">
  <svg width="800" height="150" xmlns="http://www.w3.org/2000/svg">
    <style>
      .bg { fill: url(#grad); stroke: #e1e4e8; stroke-width: 2px; rx: 12px; }
      .title { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 28px; font-weight: 800; fill: #ffffff; }
      .subtitle { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 500; fill: #e1e4e8; }
      .glow { animation: pulse 3s infinite alternate; }
      @keyframes pulse {
        0% { opacity: 0.8; filter: drop-shadow(0 0 4px rgba(255,153,0,0.4)); }
        100% { opacity: 1; filter: drop-shadow(0 0 12px rgba(255,153,0,0.9)); }
      }
      @media (prefers-color-scheme: dark) {
        .bg { stroke: #30363d; }
      }
    </style>
    <defs>
      <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#232f3e;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#ff9900;stop-opacity:1" />
      </linearGradient>
    </defs>
    <rect width="100%" height="100%" class="bg" />
    <text x="50%" y="45%" dominant-baseline="middle" text-anchor="middle" class="title glow">CI/CD Pipeline (CodePipeline)</text>
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">deployment-workflow.md</text>
  </svg>
</div>



<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Serverless Rest Api</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-10-auto-scaling-alb/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Auto Scaling Alb</b> ⏩</a></td>
    </tr>
  </table>
</div>


<br>

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

## End-to-End Workflow: From Code to Production

```text
Developer edits code on Windows PC
            │
            │ 1. Edit index.html locally
            ▼
git add . && git commit -m "feat: update v2"
            │
            │ 2. git push origin main
            ▼
CodeCommit receives push (~1 second)
            │
            │ 3. CloudWatch Events detects branch update
            ▼
CodePipeline execution starts (~5 seconds)
            │
            ├──── Stage 1: Source ────────────────────────── ~10 sec
            │     CodePipeline fetches source from CodeCommit
            │     Zips repo contents → stores as SourceOutput in S3
            │
            ├──── Stage 2: Build ─────────────────────────── ~90 sec
            │     CodeBuild spins up Linux container
            │     install: sets up Python 3.11
            │     pre_build: validates HTML, checks files
            │     build: creates dist/, generates build-info.txt
            │     post_build: confirms artifact ready
            │     Zips dist/ → stores as BuildOutput in S3
            │
            └──── Stage 3: Deploy ────────────────────────── ~60 sec
                  CodeDeploy downloads BuildOutput from S3
                  Finds EC2 instances tagged Environment=production
                  CodeDeploy agent runs lifecycle hooks:
                    BeforeInstall  → stop old app, clean files
                    [file copy]    → index.html → /var/www/html/
                    AfterInstall   → set permissions
                    AppStart       → start httpd
                    ValidateService→ curl localhost, check HTTP 200
                  Deployment: SUCCEEDED ✅

Total time: ~3-4 minutes
Result: Updated app live at http://EC2_PUBLIC_IP
```

---

## First Deployment vs Subsequent Deployments

### First deployment (triggered on pipeline creation)

```text
Pipeline created
      │
      ▼ immediately
First execution starts automatically
      │
      ▼
Source → Build → Deploy
      │
      ▼
Version 1.0 live on EC2
```

### Subsequent deployments (triggered by code push)

```text
git push origin main
      │
      ▼ within seconds
CloudWatch Events fires
      │
      ▼
CodePipeline execution N+1 starts
      │
      ▼
Source → Build → Deploy
      │
      ▼
New version live on EC2
```

---

## Deployment Lifecycle on EC2

When the CodeDeploy agent receives a deployment instruction:

```text
Agent receives deployment notification
              │
              ▼
Agent downloads BuildOutput.zip from S3
              │
              ▼
Agent extracts to:
/opt/codedeploy-agent/deployment-root/DEPLOYMENT_ID/
              │
              ▼
Reads appspec.yml from extracted root
              │
              ▼
Executes: BeforeInstall hook
  → scripts/before_install.sh runs as root
  → stops httpd
  → installs httpd if missing
  → deletes old index.html
              │
              ▼
Copies files (appspec files: section)
  → index.html → /var/www/html/index.html
  → build-info.txt → /var/www/html/build-info.txt
              │
              ▼
Executes: AfterInstall hook
  → scripts/after_install.sh runs as root
  → chown apache:apache /var/www/html/
  → chmod 644 files
              │
              ▼
Executes: ApplicationStart hook
  → scripts/start_application.sh runs as root
  → systemctl start httpd
  → systemctl enable httpd
              │
              ▼
Executes: ValidateService hook
  → scripts/validate_service.sh runs as root
  → sleep 3 (wait for httpd to fully start)
  → curl http://localhost/ → HTTP 200?
    YES → exit 0 → DEPLOYMENT SUCCEEDED ✅
    NO  → exit 1 → DEPLOYMENT FAILED ❌ → rollback
```

---

## Version Update Workflow (V1 → V2)

This is the core demo of CI/CD working end-to-end:

### Step 1 — Edit code locally

```powershell
cd C:\Users\YourName\my-web-app

# Change Version 1.0 to Version 2.0 in index.html
(Get-Content index.html) -replace 'Version 1.0', 'Version 2.0' |
  Set-Content index.html

# Verify change
Select-String "Version" index.html
```

### Step 2 — Commit and push

```powershell
git add index.html
git commit -m "feat: bump version to 2.0"
git push origin main
```

### Step 3 — Watch pipeline

```powershell
# Poll every 30 seconds
while ($true) {
  aws codepipeline get-pipeline-state `
    --name my-web-app-pipeline `
    --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" `
    --output table
  Start-Sleep -Seconds 30
}
```

### Step 4 — Verify deployment

```powershell
# Hit the endpoint
$PUBLIC_IP = aws ec2 describe-instances `
  --filters "Name=tag:Name,Values=cicd-deploy-server" `
  --query "Reservations[0].Instances[0].PublicIpAddress" `
  --output text

Invoke-WebRequest -Uri "http://$PUBLIC_IP" | Select-Object -ExpandProperty Content
# Should contain: "Version 2.0"

# Or open in browser
Start-Process "http://$PUBLIC_IP"
```

---

## Auto-Rollback Workflow

When a deployment fails (e.g., ValidateService returns HTTP 500):

```text
Deployment D-NEW (Version 2.0) fails at ValidateService
                │
                ▼
CodeDeploy detects failure: DEPLOYMENT_FAILURE event
                │
                ▼ (auto-rollback is enabled)
CodeDeploy creates new deployment D-ROLLBACK
                │
                ▼
D-ROLLBACK deploys last SUCCESSFUL revision
(Version 1.0 artifact from S3)
                │
                ▼
Lifecycle hooks run again:
  BeforeInstall → AfterInstall → AppStart → ValidateService
                │
                ▼
Version 1.0 restored and validated
                │
                ▼
EC2 running Version 1.0 again ✅
CodePipeline Deploy stage: FAILED (no auto-retry)
Developer must fix code and push again
```

---

## Monitoring Deployments in Real Time

### Console approach

```text
CodePipeline → my-web-app-pipeline → click Deploy stage
      └── Click "AWS CodeDeploy" link
           └── Deployments → latest deployment
                └── Deployment lifecycle events
                     ├── BeforeInstall: Succeeded ✅
                     ├── Install: Succeeded ✅
                     ├── AfterInstall: Succeeded ✅
                     ├── ApplicationStart: Succeeded ✅
                     └── ValidateService: Succeeded ✅
```

### CLI approach

```powershell
# Get latest deployment ID
$DEPLOY_ID = aws deploy list-deployments `
  --application-name my-web-app `
  --deployment-group-name production `
  --query "deployments[0]" --output text

# Watch deployment status
aws deploy get-deployment `
  --deployment-id $DEPLOY_ID `
  --query "deploymentInfo.{Status:status,Overview:deploymentOverview}" `
  --output table

# Watch deployment lifecycle events
aws deploy list-deployment-instances `
  --deployment-id $DEPLOY_ID `
  --query "instancesList" --output text
```

---

## Deployment History

```powershell
# List all deployments for the application
aws deploy list-deployments `
  --application-name my-web-app `
  --deployment-group-name production `
  --query "deployments" --output table

# Get details of a specific deployment
aws deploy get-deployment `
  --deployment-id DEPLOYMENT_ID `
  --query "deploymentInfo.{
    ID:deploymentId,
    Status:status,
    CreateTime:createTime,
    CompleteTime:completeTime,
    Revision:revision.s3Location.key,
    Creator:creator
  }" --output table
```

---

## Key Deployment Files on EC2

After a successful deployment, these files exist on EC2:

```text
/var/www/html/
├── index.html        ← Your deployed application
└── build-info.txt    ← Build metadata from CodeBuild

/opt/codedeploy-agent/deployment-root/
└── DEPLOYMENT_GROUP_ID/
    └── DEPLOYMENT_ID/
        ├── deployment-archive/    ← Extracted BuildOutput.zip
        │   ├── index.html
        │   ├── appspec.yml
        │   ├── build-info.txt
        │   └── scripts/
        └── logs/
            └── scripts/
                ├── BeforeInstall  ← Hook script output
                ├── AfterInstall
                ├── ApplicationStart
                └── ValidateService

/var/log/aws/codedeploy-agent/
└── codedeploy-agent.log  ← Agent activity log
```

### Read deployment logs on EC2

```bash
# SSH or SSM into EC2
# Read hook output
sudo cat /opt/codedeploy-agent/deployment-root/*/LATEST/logs/scripts/ValidateService

# Read agent log
sudo tail -50 /var/log/aws/codedeploy-agent/codedeploy-agent.log

# Check build-info.txt
cat /var/www/html/build-info.txt
```

<br>


<div align="center" style="margin: 30px 0; padding: 15px; border: 1px solid #e1e4e8; border-radius: 8px; background-color: #f6f8fa;">
  <table style="width: 100%; text-align: center; border: none; background: transparent;">
    <tr style="border: none;">
      <td style="width: 33%; border: none;"><a href='../../project-08-serverless-rest-api/README.md' style='font-size: 16px; text-decoration: none;'>⏪ <b>Previous: Serverless Rest Api</b></a></td>
      <td style="width: 33%; border: none;"><a href="../README.md" style="font-size: 16px; text-decoration: none;">🏠 <b>Project Home</b></a></td>
      <td style="width: 33%; border: none;"><a href='../../project-10-auto-scaling-alb/README.md' style='font-size: 16px; text-decoration: none;'><b>Next: Auto Scaling Alb</b> ⏩</a></td>
    </tr>
  </table>
</div>

