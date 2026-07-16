# Testing Procedures

This document details how to validate the elasticity and self-healing properties of our architecture.

## 1. Load Distribution Test (ALB)
The Application Load Balancer should distribute incoming requests across all healthy instances in the Target Group.

1. Navigate to the **EC2 Dashboard** -> **Load Balancers**.
2. Copy the **DNS name** of `my-alb`.
3. Open a terminal and run a curl loop to send multiple requests:
   ```bash
   for i in {1..10}; do curl -s http://<ALB-DNS-NAME> | grep "Instance ID"; sleep 1; done
   ```
4. **Expected Result**: The output should alternate between different Instance IDs (e.g., `i-0abcd...` and `i-0efgh...`), proving that the ALB is distributing traffic.

## 2. Self-Healing Test (ASG)
The Auto Scaling Group should automatically detect terminated instances and replace them.

1. Navigate to the **EC2 Dashboard** -> **Instances**.
2. Select one of the running instances in the `web-server-asg`.
3. Click **Instance state** -> **Terminate instance**.
4. Navigate to **Auto Scaling Groups** -> `web-server-asg` -> **Activity**.
5. **Expected Result**: Within 1-2 minutes, you will see a new activity log stating "Terminating EC2 instance..." followed shortly by "Launching a new EC2 instance...". The desired capacity of 2 will be restored automatically.

## 3. Dynamic Scaling Test (CPU Load)
The scaling policy is set to add instances if average CPU utilization exceeds 50%.

1. Access one of the instances via **AWS Systems Manager (Session Manager)** or SSH.
2. Run the `stress` utility in the background to max out the CPU:
   ```bash
   sudo stress --cpu 2 --timeout 300 &
   ```
3. Navigate to **CloudWatch** -> **Alarms**.
4. **Expected Result**: After a few minutes, the `TargetTracking-web-server-asg-AlarmHigh` alarm will enter the **In alarm** state.
5. Navigate to the **Auto Scaling Group** activity tab. You will see a new instance being launched to handle the increased load.
6. Once the 300-second stress test completes, the CPU utilization will drop, the low alarm will trigger, and the ASG will terminate the extra instance (Scale In).