# Architecture Details

## Application Load Balancer (ALB)
- Resides in public subnets across at least 2 Availability Zones.
- Configured with a Listener on Port 80 (HTTP) that forwards traffic to a Target Group.
- **Target Group:** Evaluates health checks against the instances. Only healthy instances receive traffic.

## Auto Scaling Group (ASG)
- **Desired Capacity:** Automatically adjusted between Min and Max.
- **Health Check Type:** Set to `ELB`, meaning if the ALB considers the instance unhealthy (e.g. Apache crashes), the ASG will terminate it and launch a replacement.
- **Scaling Policy:** A Target Tracking policy monitors Average CPU Utilization, dynamically adding/removing instances to maintain a target (e.g. 50%).

## Launch Template
- The blueprint the ASG uses to launch new instances. Contains the AMI ID, Instance Type (t2.micro), Security Groups, and User Data script to install the web server.
