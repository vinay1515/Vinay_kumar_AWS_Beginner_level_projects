# Testing Procedures

To verify your alarm works, you must simulate a high CPU load on your EC2 instance.

1. SSH into the EC2 instance being monitored.
2. Install the `stress` utility:
   ```bash
   sudo amazon-linux-extras install epel -y
   sudo yum install stress -y
   ```
3. Run a CPU stress test:
   ```bash
   stress --cpu 8 --timeout 600
   ```
4. Wait 5-10 minutes. 
5. Check your email. You should receive a notification from AWS SNS stating the alarm has entered the `ALARM` state.
6. Check your CloudWatch Dashboard. The CPU graph should clearly show the spike.