
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
    <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" class="subtitle">pipeline-stages.md</text>
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

## Overview

CodePipeline orchestrates three sequential stages.
Each stage must succeed before the next begins.
Any stage failure stops the pipeline and can trigger rollback.

```
SOURCE → BUILD → DEPLOY
  ↓        ↓       ↓
 10s      90s     60s
```

---

## Stage 1 — Source

### What happens
CodePipeline polls (or receives an event from) CodeCommit.
When a new commit is detected on the `main` branch,
it fetches the repository contents and stores them
as a ZIP in the S3 artifact bucket.

### Trigger mechanism
```
git push origin main
      │
      ▼
CodeCommit stores commit
      │
      ▼
CloudWatch Events rule fires (within seconds)
      │
      ▼
CodePipeline execution starts
```

### Configuration
```
Provider:   AWS CodeCommit
Repository: my-web-app
Branch:     main
Detection:  Amazon CloudWatch Events (recommended)
            vs PollForSourceChanges (legacy, 1-min polling)
Output:     SourceOutput artifact (ZIP in S3)
```

### What is in SourceOutput
```
SourceOutput.zip
├── index.html
├── buildspec.yml
├── appspec.yml
└── scripts/
    ├── before_install.sh
    ├── after_install.sh
    ├── start_application.sh
    └── validate_service.sh
```

### Source stage states
| State | Meaning |
|---|---|
| InProgress | Fetching from CodeCommit |
| Succeeded | Source ZIP stored in S3 |
| Failed | Cannot access repo or branch not found |

---

## Stage 2 — Build

### What happens
CodeBuild downloads the SourceOutput ZIP from S3,
extracts it, and runs the instructions in `buildspec.yml`
inside a fresh Linux container.

### Environment
```
Image:        aws/codebuild/standard:7.0 (Ubuntu 22.04)
Compute type: BUILD_GENERAL1_SMALL
              → 3 GB RAM, 2 vCPU
              → sufficient for most web app builds
Runtime:      Python 3.11 (specified in buildspec)
```

### Build phases executed
```
install phase    (~10 sec)
  └── Sets up Python 3.11 runtime

pre_build phase  (~5 sec)
  └── Validates index.html structure
  └── Checks required files exist
  └── Fails fast if anything missing

build phase      (~5 sec)
  └── Creates dist/ directory
  └── Copies files to dist/
  └── Generates build-info.txt with metadata

post_build phase (~2 sec)
  └── Confirms package ready
  └── Logs completion
```

### Build artifact
```
BuildOutput.zip (stored in S3)
├── index.html
├── appspec.yml
├── build-info.txt (generated by build)
└── scripts/
    ├── before_install.sh
    ├── after_install.sh
    ├── start_application.sh
    └── validate_service.sh
```

### Build environment variables
| Variable | Value | Set by |
|---|---|---|
| CODEBUILD_BUILD_NUMBER | auto-incrementing int | CodeBuild |
| CODEBUILD_BUILD_ID | unique build identifier | CodeBuild |
| AWS_DEFAULT_REGION | ap-south-1 | CodeBuild |
| CODEBUILD_SRC_DIR | /codebuild/output/src | CodeBuild |

### Build logs location
```
CloudWatch Logs group: /aws/codebuild/my-web-app-build
Log stream: build-ID (one per build)
```

### Build stage states
| State | Meaning |
|---|---|
| InProgress | Build container running |
| Succeeded | BuildOutput ZIP in S3 |
| Failed | Build phase error — check CloudWatch logs |

---

## Stage 3 — Deploy

### What happens
CodeDeploy downloads the BuildOutput ZIP from S3,
finds EC2 instances matching the tag filter,
and instructs the CodeDeploy agent on each instance
to run the deployment lifecycle hooks.

### How CodeDeploy finds instances
```
Deployment group tag filter:
  Key:   Environment
  Value: production
  Type:  KEY_AND_VALUE

CodeDeploy scans all EC2 instances in ap-south-1
  → Finds instances with Environment=production tag
  → Sends deployment instructions to their agents
```

### CodeDeploy agent on EC2
The agent is a background service running on the EC2 instance:
```bash
systemctl status codedeploy-agent
# Active: active (running)

# Agent polls CodeDeploy service for pending deployments
# Downloads deployment bundle from S3
# Extracts to /opt/codedeploy-agent/deployment-root/
# Runs lifecycle hooks in sequence
```

### Lifecycle hook execution order
```
BeforeInstall
    ↓ (scripts/before_install.sh)
    Stop old app, install Apache, clean old files

[CodeDeploy copies files]
    ↓ (files: section in appspec.yml)
    Copies index.html → /var/www/html/
    Copies build-info.txt → /var/www/html/

AfterInstall
    ↓ (scripts/after_install.sh)
    Set file permissions, display build info

ApplicationStart
    ↓ (scripts/start_application.sh)
    Start httpd, enable on boot

ValidateService
    ↓ (scripts/validate_service.sh)
    curl http://localhost/ → expect HTTP 200
    If 200: deployment succeeds
    If not: deployment FAILS → auto-rollback fires
```

### Deployment configurations
```
AllAtOnce (used in this project):
  Deploy to all instances simultaneously
  Fast, but zero tolerance for failure on single instance
  Downtime during deployment if instance count = 1

HalfAtATime:
  Deploy to 50% of fleet, then remaining 50%
  Maintains 50% capacity during deployment
  Used for larger fleets

OneAtATime:
  Deploy to one instance at a time
  Always maintains (n-1)/n capacity
  Slowest but safest for large fleets
```

### Auto-rollback behavior
```
Deployment fails at any hook
       │
       ▼
Auto-rollback triggers (if configured)
       │
       ▼
CodeDeploy re-deploys last successful revision
       │
       ▼
Previous working version is restored
```

### Deploy stage states
| State | Meaning |
|---|---|
| InProgress | Hooks executing on EC2 |
| Succeeded | ValidateService returned HTTP 200 |
| Failed | Hook script exited non-zero or validation failed |

---

## Pipeline Execution States

| State | Meaning | Action |
|---|---|---|
| InProgress | Currently running | Wait |
| Succeeded | All stages passed | Check app is live |
| Failed | A stage failed | Click stage for error details |
| Stopped | Manually stopped | Resume or re-run |
| Superseded | Newer execution replaced this one | Normal behavior on rapid pushes |

---

## Pipeline Execution History

```powershell
# List last 5 executions
aws codepipeline list-pipeline-executions `
  --pipeline-name my-web-app-pipeline `
  --max-results 5 `
  --query "pipelineExecutionSummaries[*].{
    ID:pipelineExecutionId,
    Status:status,
    Start:startTime,
    Stop:lastUpdateTime,
    Trigger:trigger.triggerType}" `
  --output table
```

---

## How to Manually Trigger the Pipeline

```powershell
# Trigger a manual pipeline run (without a code push)
aws codepipeline start-pipeline-execution `
  --name my-web-app-pipeline

# Monitor it
aws codepipeline get-pipeline-state `
  --name my-web-app-pipeline `
  --query "stageStates[*].{Stage:stageName,Status:latestExecution.status}" `
  --output table
```

---

## Stage Timing Reference

| Stage | Typical Time | What Drives Duration |
|---|---|---|
| Source | 10–15 sec | Repo size, S3 upload |
| Build | 60–120 sec | Build commands, container startup |
| Deploy | 30–90 sec | Hook execution, app startup |
| **Total** | **~3–4 min** | |

Build time is the biggest variable — complex builds with
many dependencies can take 5–10 minutes. Our simple
HTML app builds in under 2 minutes.

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

