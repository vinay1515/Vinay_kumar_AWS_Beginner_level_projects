# Testing Procedures: 3-Tier HA Architecture

To ensure the architecture meets the High Availability (HA) and Fault Tolerance requirements, we perform a series of functional, security, and performance tests (Chaos Engineering).

## 🧪 1. Functional Testing (Stack Verification)
Before simulating failures, ensure the stack is operating normally. Run the `08-verify-stack` script or perform the following manual checks:

- **ALB Resolution:** Navigate to the ALB DNS name in a web browser. The page should render with a green "All Three Tiers Healthy" message.
- **Dynamic Data:** Refresh the page multiple times. The `Instance ID`, `Availability Zone`, and `Private IP` values should alternate, proving the ALB is successfully load balancing across instances in different AZs.
- **Database Connection:** The UI should display the database name (e.g., `capstonedb`), proving the EC2 instance successfully queried Secrets Manager and connected to the RDS instance.

## 💥 2. Chaos Engineering (Failover Testing)
Run the `09-failover-testing` script to automate these scenarios, or perform them manually to witness the architecture's resilience.

### Scenario A: Compute Failure (App Tier)
**Objective:** Prove the ASG and ALB can detect a dead instance and automatically recover.
1. In the EC2 console, locate one of the `capstone-app-server` instances.
2. Forcefully **Terminate** the instance.
3. **Observation:**
   - Within 30 seconds, the ALB health checks (`/health.json`) will fail for that instance. The ALB stops routing traffic to it. Your web app remains online via the second instance.
   - Within 3-4 minutes, the Auto Scaling Group detects the instance count (1) dropped below the desired capacity (2).
   - The ASG launches a replacement instance using the Launch Template.
   - The new instance bootstraps, passes health checks, and begins serving traffic.

### Scenario B: Database Failure (DB Tier)
**Objective:** Prove the Multi-AZ RDS configuration can survive a total AZ failure.
1. In the RDS console, select `capstone-database`.
2. Click **Actions -> Reboot**. Check the box for **Reboot With Failover**.
3. **Observation:**
   - The primary RDS instance in AZ1 goes offline.
   - RDS automatically updates the DNS endpoint to point to the synchronous standby replica in AZ2.
   - This process takes 60-120 seconds.
   - Once DNS propagates, the EC2 instances reconnect to the database without any configuration changes.

### Scenario C: Traffic Spike (Scale-Out)
**Objective:** Prove the ASG can dynamically scale to handle increased load.
1. Use AWS Systems Manager (SSM) Session Manager to connect to one of the EC2 instances.
2. Install a stress tool: `sudo yum install -y stress`
3. Max out the CPU: `sudo stress --cpu 1 --timeout 600 &`
4. **Observation:**
   - Wait 3-5 minutes. CloudWatch will detect the `ASGAverageCPUUtilization` exceeding 60%.
   - The `Capstone-ASG-CPU-High` alarm will enter the `ALARM` state.
   - The ASG Target Tracking policy will trigger, provisioning new instances (up to the maximum of 4) to distribute the load and lower the average CPU.

## 🔒 3. Security Testing
- **Network Isolation:** Attempt to ping or SSH into the private IP of an EC2 instance from your local machine. It must fail. Attempt to connect directly to the RDS endpoint from your local machine. It must fail.
- **SSM Access:** Verify that you can successfully connect to the EC2 instances using AWS Systems Manager Session Manager from the AWS Console. This proves the IAM role is attached and functioning.
