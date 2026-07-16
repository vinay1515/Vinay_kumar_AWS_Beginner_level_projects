# Troubleshooting Guide

Common issues encountered when setting up an Auto Scaling Group and Application Load Balancer.

## 1. Target Group Health Checks Failing
**Symptom**: Instances show as `unhealthy` in the Target Group, and the ALB returns a 502 Bad Gateway.
- **Cause 1**: Apache (`httpd`) failed to start on the instance.
  - *Fix*: Connect to the instance via Session Manager and check `systemctl status httpd`. Ensure the User Data script ran successfully by checking `/var/log/cloud-init-output.log`.
- **Cause 2**: The `asg-ec2-sg` security group is not allowing traffic from the ALB.
  - *Fix*: Verify the inbound rules for `asg-ec2-sg`. It must have an HTTP rule (Port 80) where the Source is the `alb-sg` Security Group ID (not an IP address).
- **Cause 3**: The `/` path does not exist.
  - *Fix*: Ensure the User Data script correctly generated the `index.html` file in `/var/www/html/`.

## 2. Instances Failing to Launch
**Symptom**: The Auto Scaling Group activity log shows "Failed to launch EC2 instance."
- **Cause**: The Launch Template references an invalid AMI, missing Key Pair, or an incorrect Security Group ID.
  - *Fix*: Edit the Launch Template to create a new version. Verify the AMI ID is available in `ap-south-1`. Ensure the specified Key Pair actually exists in your account. Update the ASG to use the `$Latest` version of the template.

## 3. Auto Scaling Not Triggering
**Symptom**: You run the `stress` command, but no new instances are launched.
- **Cause 1**: The stress test did not run long enough.
  - *Fix*: Target Tracking policies require the metric to stay above the threshold for 3 consecutive minutes by default. Run `stress --cpu 4 --timeout 600` to ensure a sustained load.
- **Cause 2**: The instance warm-up time is preventing consecutive scaling.
  - *Fix*: Check the `EstimatedInstanceWarmup` setting in the ASG. If it is set to 300 seconds, the ASG will wait 5 minutes before evaluating whether another scale-out is needed.