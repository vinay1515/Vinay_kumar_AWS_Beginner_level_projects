# EC2 Launch Templates in CloudFormation

<div style="background-color: #fdfdfe; border-left: 4px solid #ff9900; padding: 15px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
  <i>The following granular documentation is designed to provide enterprise-level clarity for deploying and managing this AWS architecture. Pay close attention to the architectural specifications and step-by-step methodologies below.</i>
</div>

<br>


A Launch Template defines the blueprint that an Auto Scaling Group uses to provision new EC2 instances. In CloudFormation, this is handled by the `AWS::EC2::LaunchTemplate` resource.

## Code Definition

```yaml
  WebServerLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub "${ProjectName}-lt"
      LaunchTemplateData:
        ImageId: !Sub '{{resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64}}'
        InstanceType: !Ref InstanceType
        KeyName: !Ref KeyPairName
        SecurityGroupIds:
          - !Ref EC2SecurityGroup
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>CloudFormation Deployed Instance</h1>" > /var/www/html/index.html
```

## Key IaC Concepts

### 1. Resolving AMIs Dynamically
Instead of hardcoding an AMI ID (like `ami-0c2b8ca1dad447f8a`), which breaks if deployed in another region, the template queries AWS Systems Manager (SSM) at deployment time to fetch the latest Amazon Linux 2023 AMI.
- Syntax: `{{resolve:ssm:/aws/service/ami-amazon-linux-latest/...}}`

### 2. User Data Encoding
EC2 instances expect User Data to be passed in Base64 encoding. Instead of encoding the script manually, CloudFormation provides the `Fn::Base64` intrinsic function.

Combined with `!Sub` (Substitute), you can inject CloudFormation variables directly into your bash script at launch:
```yaml
            echo "<h1>CloudFormation Deployed Instance</h1>
            <p>Environment: ${EnvironmentType}</p>
            <p>Stack: ${AWS::StackName}</p>" > /var/www/html/index.html
```

### 3. Referencing in the ASG
Once the template is created, the Auto Scaling Group must explicitly refer to its ID and Version:
```yaml
      LaunchTemplate:
        LaunchTemplateId: !Ref WebServerLaunchTemplate
        Version: !GetAtt WebServerLaunchTemplate.LatestVersionNumber
```
Using `LatestVersionNumber` ensures that if you update the Launch Template in a subsequent Change Set, the ASG automatically uses the new configuration.


