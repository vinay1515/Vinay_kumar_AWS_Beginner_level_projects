# Testing & Verification Procedures

Because this project focuses on account setup and identity, our testing procedures involve validating access, authentication, and alarm configurations.

## 1. Verify Root Account MFA
**Objective:** Ensure the root account cannot be accessed with just a password.
1. Sign out of the AWS Management Console completely.
2. Navigate back to the AWS login page and enter your root email and password.
3. **Expected Result:** You are immediately prompted to enter a 6-digit MFA code from your authenticator app before access is granted.

## 2. Verify IAM Console Access
**Objective:** Ensure the new IAM user can access the console with administrative rights.
1. Use the custom IAM sign-in URL provided in your `.csv` file.
2. Enter the IAM username (e.g., `admin-yourname`) and the password you created.
3. **Expected Result:** You successfully log into the console. Navigate to the EC2 or S3 dashboard to verify you do not see any "Access Denied" errors, proving your `AdministratorAccess` policy is active.

## 3. Verify AWS CLI Configuration
**Objective:** Ensure local programmatic access is configured correctly.
1. Open PowerShell, Command Prompt, or your Bash terminal.
2. Run the command: `aws sts get-caller-identity`
3. **Expected Result:** The command returns a JSON object containing your Account ID and the ARN of your IAM user (`arn:aws:iam::123456789012:user/admin-yourname`). This confirms your local `~/.aws/credentials` file is properly configured.

## 4. Verify Billing Alarm & SNS Subscription
**Objective:** Ensure CloudWatch will successfully deliver billing alerts.
1. Open the CloudWatch console and navigate to **Alarms**.
2. Select the `Monthly-Billing-Alert-5USD` alarm.
3. Check the **State**.
    - **Expected Result:** The state should read `OK`.
4. Navigate to the SNS console and check **Subscriptions**.
    - **Expected Result:** The subscription status for your email address must show `Confirmed`. If it shows `Pending confirmation`, check your email inbox and click the confirmation link.