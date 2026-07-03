# Testing Procedures

## Load Balancing Test
1. Copy the DNS Name of the ALB from the console.
2. Open it in your web browser. You should see the Instance ID rendered by the user data script.
3. Hard refresh the page multiple times. The Instance ID should alternate, proving the ALB is distributing traffic between the two instances.

## Self-Healing Test
1. Go to the EC2 console and intentionally Terminate one of the running instances.
2. Navigate to the ASG console and view the "Activity" tab.
3. Within minutes, you will see a log indicating the ASG detected the termination and launched a new replacement instance automatically.

## Auto-Scaling Test
1. SSH into one of the instances and run a CPU stress test (`stress --cpu 8 --timeout 600`).
2. Watch the ASG Activity tab. As the CloudWatch CPU alarm breaches 50%, the ASG will launch a 3rd (and potentially 4th) instance to handle the load.