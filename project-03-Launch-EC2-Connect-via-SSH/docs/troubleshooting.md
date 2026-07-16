# Troubleshooting Guide

This guide covers common issues encountered when provisioning and connecting to EC2 instances via SSH, PuTTY, Session Manager, or accessing web servers — along with root causes and step-by-step resolution procedures.

---

## 1. Network & Connectivity Errors

### Browser Spins Indefinitely (Website Not Loading)
**Symptom:** The browser shows a loading spinner but never displays the website.

**Cause:** The Security Group does not have an Inbound Rule allowing HTTP (Port 80). The packets are being silently dropped by the firewall.

**Fix:**
1. Go to **EC2** → **Security Groups** → Select your security group
2. Click **Edit inbound rules**
3. Add a rule: Type = `HTTP`, Port = `80`, Source = `0.0.0.0/0`
4. Save and retry the browser

### Browser Says "Connection Refused"
**Symptom:** Browser displays `ERR_CONNECTION_REFUSED` when accessing the public IP.

**Cause:** Network traffic reached the server (Security Group is fine), but Apache is not running. The User Data script likely failed or had a typo.

**Fix:**
1. SSH into the instance
2. Check Apache status: `sudo systemctl status httpd`
3. If dead, start it: `sudo systemctl start httpd`
4. Check the User Data log for errors: `cat /var/log/cloud-init-output.log`

### Cannot Reach Website via HTTPS
**Symptom:** `https://` URL fails, but `http://` works.

**Cause:** No SSL certificate is installed, and Port 443 is not open in the Security Group.

**Fix:** Ensure your browser URL explicitly says `http://` (not `https://`). Some modern browsers force HTTPS by default.

---

## 2. SSH & Authentication Errors

### SSH Command Hangs and Times Out
**Symptom:** `ssh -i key.pem ec2-user@IP` hangs for 30+ seconds, then shows `Operation timed out`.

**Cause:** The Security Group does not allow Port 22 from your current IP. This commonly happens when you change Wi-Fi networks after creating the rule.

**Fix:**
1. Go to **EC2** → **Security Groups** → Edit inbound rules
2. Find the SSH rule → change Source to **My IP** to inject your new IP
3. Save and retry SSH

### Permission Denied (publickey)
**Symptom:** `Permission denied (publickey)` error.

**Cause:**
- Wrong `.pem` file specified
- Wrong username (e.g., trying `root` instead of `ec2-user`)

**Fix:**
1. Verify you're using the correct key: `ssh -i my-web-key.pem ec2-user@<IP>`
2. For Amazon Linux: username is `ec2-user`
3. For Ubuntu: username is `ubuntu`

### UNPROTECTED PRIVATE KEY FILE! (Mac/Linux)
**Symptom:** SSH refuses to connect, showing `WARNING: UNPROTECTED PRIVATE KEY FILE!`

**Cause:** Your `.pem` file is readable by other users. SSH considers this insecure and refuses to use it.

**Fix:**
```bash
chmod 400 my-web-key.pem
```

---

## 3. PuTTY-Specific Errors

### PuTTY: "Connection Refused"
**Symptom:** PuTTY shows `Network error: Connection refused`.

**Cause:** Security group is missing the SSH rule, or the instance is still booting.

**Fix:**
1. Check that the security group has port `22` open to your current IP
2. Wait for instance status checks to show **2/2 passed** in the EC2 console

### PuTTY: "Connection Timed Out"
**Symptom:** PuTTY shows `Network error: Connection timed out`.

**Cause:** Incorrect IP address, or the security group is not attached to the instance.

**Fix:**
1. Verify the **Public IPv4 address** directly in the EC2 console
2. Confirm that `ec2-web-sg` is attached to the instance

### PuTTY: "No Supported Authentication Methods"
**Symptom:** PuTTY rejects the key file.

**Cause:** Wrong key file format or path selected in PuTTY configuration.

**Fix:** Open PuTTY session settings → **Connection** → **SSH** → **Auth** → Browse and select the correct `.ppk` file. Note: PuTTY requires `.ppk` format, not `.pem`. Use PuTTYgen to convert if needed.

---

## 4. Session Manager Issues

### "Connect" Button Is Greyed Out
**Symptom:** In the EC2 console, the Session Manager **Connect** button is disabled.

**Cause:** The required IAM role is not attached, or the SSM agent is still initializing.

**Fix:**
1. Ensure the instance IAM role includes the `AmazonSSMManagedInstanceCore` policy
2. Wait up to 5 minutes after attaching the role for the agent to register
3. Verify SSM agent status by SSH: `sudo systemctl status amazon-ssm-agent`

---

## 5. Provisioning Errors

### Cannot Find t2.micro Instance Type
**Symptom:** `t2.micro` is not available in the instance type list.

**Cause:** Some newer AWS regions (like `eu-north-1` or `af-south-1`) do not have `t2` family hardware.

**Fix:** Select `t3.micro` instead — it is also Free Tier eligible in regions where `t2.micro` is absent.

### Public IP Changed After Instance Restart
**Symptom:** After stopping and starting the instance, the public IP is different.

**Cause:** Default EC2 public IPs are **dynamic** and release upon stop/start.

**Fix:** This is expected behavior. Update your connection string with the new IP. For a permanent fix, associate an **Elastic IP** to the instance.

### AWS CLI `wait` Command Times Out
**Symptom:** `aws ec2 wait instance-running` times out before completing.

**Cause:** Instance initialization is taking longer than the default timeout window.

**Fix:** Run the manual status check:
```bash
aws ec2 describe-instances --instance-ids <INSTANCE_ID> \
  --query "Reservations[0].Instances[0].State.Name" --output text
```

---

## 📋 Quick Reference Table

| Problem | Cause | Quick Fix |
|:---|:---|:---|
| Browser won't load site | Missing HTTP rule (port 80) | Add inbound HTTP rule to security group |
| SSH connection refused | Missing SSH rule (port 22) | Add SSH rule with **My IP** source |
| SSH permission denied | Wrong key file or username | Use `ec2-user` and correct `.pem` file |
| PuTTY authentication fails | Wrong `.ppk` format | Convert `.pem` to `.ppk` with PuTTYgen |
| Session Manager greyed out | Missing IAM role | Attach `AmazonSSMManagedInstanceCore` |
| IP changed after restart | Dynamic public IP | Associate an Elastic IP |

## 🔍 Debug Commands

```bash
# Check instance state and status checks
aws ec2 describe-instance-status --instance-ids <INSTANCE_ID>

# Verify security group rules
aws ec2 describe-security-groups --group-ids <SG_ID>

# Check SSM agent registration
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=<INSTANCE_ID>"

# View User Data execution log (from within the instance)
sudo cat /var/log/cloud-init-output.log

# Check Apache status (from within the instance)
sudo systemctl status httpd
```

> [!TIP]
> **Security Best Practice:** When opening port 22 for SSH troubleshooting, avoid using `0.0.0.0/0`. Always restrict the source to **My IP** to secure your instance from unauthorized access attempts.