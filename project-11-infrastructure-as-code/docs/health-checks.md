# Auto Scaling & Load Balancer Health Checks

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>

Robust health checking is vital for maintaining a highly available and self-healing infrastructure. In this CloudFormation stack, health checks are configured at both the Load Balancer and Auto Scaling Group levels via YAML code.

## 1. Application Load Balancer (Target Group) Health Checks

The `WebServerTargetGroup` is defined to actively monitor the health of the EC2 instances.

```yaml
  WebServerTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      HealthCheckProtocol: HTTP
      HealthCheckPath: /
      HealthCheckIntervalSeconds: 30
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 2
```

**Behavior:**
The ALB sends an HTTP GET request to port 80 on each instance every 30 seconds. If an instance responds with an HTTP 200 OK status twice in a row, it is marked as **Healthy** and receives traffic. If it fails to respond or returns an error twice in a row, it is marked as **Unhealthy** and the ALB stops routing traffic to it.

## 2. Auto Scaling Group (ASG) Health Checks

By default, an Auto Scaling Group only replaces an instance if it fails the standard **EC2 Status Checks** (e.g., hypervisor failure, underlying hardware failure). This is dangerous because an instance can pass EC2 status checks while the Apache web server has crashed.

To fix this, we explicitly configure the ASG in CloudFormation to use `ELB` health checks:

```yaml
  WebServerASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      HealthCheckType: ELB
      HealthCheckGracePeriod: 120
```

**Behavior:**
- `HealthCheckType: ELB`: Instructs the ASG to rely on the Application Load Balancer's health assessment. If the ALB marks an instance as Unhealthy (because Apache crashed), the ASG will terminate the instance and launch a replacement.
- `HealthCheckGracePeriod: 120`: Gives the newly launched instance 120 seconds to boot up and run its `UserData` script before the ASG starts evaluating its health. Without this, the ASG might prematurely terminate instances that are simply slow to boot.

