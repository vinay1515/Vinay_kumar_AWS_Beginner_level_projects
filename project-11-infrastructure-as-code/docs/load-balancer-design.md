# Application Load Balancer in CloudFormation

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>


Building an ALB in CloudFormation requires deploying three distinct but interconnected resources: the Load Balancer itself, a Listener, and a Target Group.

## 1. The Application Load Balancer

The ALB acts as the public entry point. It must be designated as `internet-facing` and attached to the Public Subnets across multiple Availability Zones.

```yaml
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub "${ProjectName}-alb"
      Subnets:
        - !Ref PublicSubnetA
        - !Ref PublicSubnetB
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Scheme: internet-facing
      Type: application
```

## 2. The Target Group

The Target Group maintains the list of instances that the ALB forwards traffic to. It defines the routing protocol and the health check parameters.

```yaml
  WebServerTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub "${ProjectName}-tg"
      Protocol: HTTP
      Port: 80
      VpcId: !Ref VPC
```

## 3. The Listener

The Listener acts as the "glue" connecting the ALB to the Target Group. It listens on a specific port (Port 80) and executes default routing rules.

```yaml
  ALBListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Protocol: HTTP
      Port: 80
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref WebServerTargetGroup
```

### Dependency Chain

CloudFormation processes these resources sequentially based on their `!Ref` statements:
1. It creates the **Target Group**.
2. It creates the **Load Balancer**.
3. It creates the **Listener**, binding the Load Balancer to the Target Group.

If you omit the Listener, the ALB will be provisioned but will drop all incoming traffic because it doesn't know where to route it.


