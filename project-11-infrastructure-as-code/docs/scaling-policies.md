# Auto Scaling Policies in CloudFormation

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>


In CloudFormation, scaling logic is separated from the Auto Scaling Group (ASG) itself. You deploy the ASG resource, and then deploy a `ScalingPolicy` resource that references it.

## 1. The Auto Scaling Group Base

The base ASG defines the minimum, maximum, and desired capacity. In this template, we expose these as CloudFormation **Parameters**, allowing you to scale up the infrastructure simply by executing a Change Set without touching the code.

```yaml
  WebServerASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: !Sub "${ProjectName}-asg"
      MinSize: !Ref MinInstances
      MaxSize: !Ref MaxInstances
      DesiredCapacity: !Ref DesiredInstances
      VPCZoneIdentifier:
        - !Ref PublicSubnetA
        - !Ref PublicSubnetB
      TargetGroupARNs:
        - !Ref WebServerTargetGroup
```
*Note the `TargetGroupARNs` property: this automatically registers any newly launched instance with the ALB's Target Group.*

## 2. Target Tracking Scaling Policy

To allow the ASG to scale dynamically beyond the `DesiredCapacity`, we attach a Target Tracking Scaling Policy.

```yaml
  CPUScalingPolicy:
    Type: AWS::AutoScaling::ScalingPolicy
    Properties:
      AutoScalingGroupName: !Ref WebServerASG
      PolicyType: TargetTrackingScaling
      TargetTrackingConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ASGAverageCPUUtilization
        TargetValue: 50.0
        EstimatedInstanceWarmup: 120
```

### How CloudFormation Implements This
When you deploy this code, CloudFormation automatically creates two underlying **CloudWatch Alarms** on your behalf:
1. **AlarmHigh:** Triggers a scale-out event if the average CPU exceeds 50%.
2. **AlarmLow:** Triggers a scale-in event if the CPU drops significantly below the target, ensuring costs are optimized.

The `EstimatedInstanceWarmup` parameter prevents the policy from scaling out again before a newly launched instance has fully booted and started contributing to the CPU metric.


