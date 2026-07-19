# Troubleshooting Guide: 3-Tier HA Architecture

This guide provides a structured approach for diagnosing and resolving common issues encountered during the deployment or operation of the 3-Tier Capstone architecture.

## 📋 Quick Reference Table
| Problem | Quick Fix |
| :--- | :--- |
| **ALB shows 502 Bad Gateway** | Check App SG inbound rules. Ensure port 80 is open from ALB SG. |
| **ALB targets are Unhealthy** | Check EC2 User Data execution logs (`/var/log/cloud-init-output.log`). Apache may not be running. |
| **Web UI missing DB Name** | Check IAM role `secrets-access` policy. EC2 cannot reach Secrets Manager. |
| **Timeouts reaching ALB** | Check IGW attachment and Public Route Table associations. |

---

## 🌐 Network Errors

### Symptom: Connection times out when accessing the ALB DNS.
- **Cause:** The Internet Gateway (IGW) is not attached to the VPC, or the public subnets do not have a route to the IGW.
- **Fix:** Verify the route table associated with the public subnets has a route for `0.0.0.0/0` targeting the IGW.

### Symptom: EC2 instances fail to bootstrap (User Data script silently fails).
- **Cause:** The private subnets lack internet access. Instances cannot run `yum update` or reach the AWS Secrets Manager API.
- **Fix:** Ensure the NAT Gateway is in the `Available` state inside a *Public* subnet. Ensure the private route table has a route for `0.0.0.0/0` targeting the NAT Gateway.

---

## 🔒 Security Group Errors

### Symptom: ALB Health Checks are failing; instances stuck in `unhealthy` state.
- **Cause:** The Application Security Group is blocking the health checks from the ALB.
- **Fix:** Verify the `capstone-app-sg` has an inbound rule allowing TCP Port 80, and the source is strictly set to the ID of `capstone-alb-sg`.

### Symptom: Application UI loads, but database fields show errors.
- **Cause:** The Database Security Group is blocking connections from the EC2 instances.
- **Fix:** Verify the `capstone-db-sg` has an inbound rule allowing TCP Port 3306, and the source is strictly set to the ID of `capstone-app-sg`.

---

## 🔑 Authentication Errors

### Symptom: EC2 instances cannot retrieve database credentials.
- **Cause:** The EC2 Instance Profile is missing or the inline policy for Secrets Manager is malformed.
- **Fix:** 
  1. Verify `capstone-ec2-profile` is attached to the instances (check the ASG Launch Template).
  2. Review the inline policy `secrets-access` on the `capstone-ec2-role` to ensure the exact Secret ARN is listed in the `Resource` block.

---

## 🔍 Debug Commands

If the problem persists, use these CLI commands to probe the environment:

**Check ALB Target Health:**
```bash
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN>
```

**Check ASG Activity History (Identifies launch failures):**
```bash
aws autoscaling describe-scaling-activities --auto-scaling-group-name capstone-asg
```

**Check NAT Gateway Status:**
```bash
aws ec2 describe-nat-gateways --filter "Name=state,Values=available"
```

**View EC2 Bootstrapping Logs (via SSM):**
```bash
# Connect to instance
aws ssm start-session --target <INSTANCE_ID>
# Read the cloud-init logs
cat /var/log/cloud-init-output.log
```
