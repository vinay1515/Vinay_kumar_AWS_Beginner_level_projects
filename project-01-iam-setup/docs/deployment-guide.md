# Deployment Guide: Step-by-Step Instructions

## 🔐 CHECKPOINT A — Secure the root account
**Console Steps:**
1. Go to https://console.aws.amazon.com and sign in with your root email + password (the one you used to create the account).
2. In the top-right corner, click your account name → Security credentials.
3. Under Multi-factor authentication (MFA) → click Assign MFA device. 
    - Device name: root-mfa
    - MFA type: Authenticator app (use Google Authenticator or Authy on your phone)
    - Scan the QR code with your authenticator app
    - Enter two consecutive 6-digit codes → click Add MFA
4. ✅ Verify: Sign out, sign back in — you should now be prompted for an MFA code.

> [!IMPORTANT]
> Write down your root email + password in a password manager. You'll rarely use root after today.

## 💳 CHECKPOINT B — Set up a billing alarm
**Console Steps:**
1. In the search bar at the top, type Billing → click Billing and Cost Management.
2. In the left panel → Billing preferences → enable: 
    - ✅ Receive PDF Invoice By Email
    - ✅ Receive Free Tier Usage Alerts (enter your email)
    - ✅ Receive Billing Alerts
    - Click Save preferences
3. Now go to the search bar → type CloudWatch → click it.
4. Make sure your region (top right) is set to US East (N. Virginia) — us-east-1. Billing metrics only exist in this region.
5. Left panel → Alarms → All alarms → Create alarm.
6. Click Select metric → Billing → Total Estimated Charge → USD → click the checkbox → Select metric.
7. Set the threshold: 
    - Threshold type: Static
    - Condition: Greater than
    - Value: 5 (triggers if your bill exceeds $5)
    - Click Next
8. Under Send a notification to → Create new topic: 
    - Topic name: billing-alert-topic
    - Email: your email address
    - Click Create topic
9. Click Next → Alarm name: Monthly-Billing-Alert-5USD → Next → Create alarm
10. ✅ Check your email — confirm the SNS subscription (click the link in the email).

✅ Verify: The alarm status shows OK (green) in CloudWatch.

## 👤 CHECKPOINT C — Create your IAM admin user
**Console Steps:**
1. Search bar → IAM → left panel → Users → Create user
2. User name: admin-yourname (e.g., admin-raj) → check Provide user access to the AWS Management Console → I want to create an IAM user → Custom password (set a strong one) → uncheck "require reset" → Next
3. Set permissions → Attach policies directly → search for and check AdministratorAccess → Next → Create user
4. ✅ Download the .csv on the confirmation screen — this has your console sign-in URL.
5. Click Return to users list → click your new user → Security credentials tab → Create access key 
    - Use case: Command Line Interface (CLI)
    - Check the confirmation box → Next
    - Description: aws-cli-windows
    - Create access key
    - ⚠️ Download the .csv now — you cannot retrieve the secret again
6. Sign out of root. Sign in using the IAM user URL from the .csv (looks like https://123456789012.signin.aws.amazon.com/console).

✅ Verify: You can log in as your IAM user and see the AWS console.

## 💻 CHECKPOINT D — Install & configure AWS CLI v2 on Windows
**Install AWS CLI v2:**
1. Open your browser → go to: https://aws.amazon.com/cli/
2. Download the Windows installer (.msi)
3. Run the installer → accept all defaults → click Finish
4. Open PowerShell (press Win + X → Windows PowerShell)

**Verify installation:**
```powershell
aws --version
# Expected output: aws-cli/2.x.x Python/3.x.x Windows/x
```

**Configure CLI with your IAM user credentials:**
```powershell
aws configure
```
Enter when prompted:
```text
AWS Access Key ID:     [paste from your .csv]
AWS Secret Access Key: [paste from your .csv]
Default region name:   us-east-1
Default output format: json
```

**Verify your identity:**
```powershell
aws sts get-caller-identity
```
Expected output:
```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/admin-yourname"
}
```
✅ If you see your Account ID and username in the Arn — your CLI is wired up correctly.