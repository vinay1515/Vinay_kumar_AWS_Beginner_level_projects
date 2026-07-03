# Troubleshooting Guide

If you encounter issues during this project, consult the table below for common symptoms and their fixes.

| Problem | Cause | Fix |
|:--------|:------|:----|
| **PuTTY shows Connection refused** | Security group missing SSH rule or instance not ready | Check security group has port 22 open to your IP; wait for 2/2 status checks |
| **PuTTY shows Connection timed out** | Wrong IP or security group not attached | Verify Public IP in EC2 console; confirm `ec2-web-sg` is attached to instance |
| **PuTTY shows No supported authentication methods** | Wrong key file selected | Browse again and select the `.ppk` file specifically |
| **Apache page not loading in browser** | HTTP rule missing or Apache not started | Check security group port 80 rule; SSH in and run `sudo systemctl start httpd` |
| **Session Manager Connect button greyed out** | IAM role not attached or SSM agent not ready | Wait 5 min after attaching role; verify role has `AmazonSSMManagedInstanceCore` |
| **Public IP changed after restart** | Expected behavior — EC2 IPs are dynamic | Use the new IP shown in console; Elastic IP fixes this (covered in later projects) |
| **`aws ec2 wait` times out** | Instance taking longer than usual | Run the describe command manually to check state |