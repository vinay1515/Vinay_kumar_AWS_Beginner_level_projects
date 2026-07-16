# Security Protocols: Infrastructure as Code

When managing infrastructure as code, security shifts from just configuring AWS resources correctly to also securing the code and the deployment pipeline itself.

## 🛡️ The Principle of Least Privilege (IAM)

### 1. CloudFormation Execution Role
By default, CloudFormation uses the permissions of the IAM user executing the stack creation. 
- **Best Practice:** In an enterprise environment, a dedicated **IAM Service Role** should be passed to CloudFormation. This restricts CloudFormation to only build specific resources (e.g., EC2 and VPC, but denying IAM or RDS creation), preventing privilege escalation.
- **CAPABILITY_IAM:** When a CloudFormation template creates IAM resources (Roles, Policies, Users), AWS requires you to explicitly acknowledge this by passing the `--capabilities CAPABILITY_IAM` flag. This prevents templates from secretly granting administrative access.

## 🔗 Security Group Chaining in IaC

The CloudFormation template enforces a strict security posture using **Security Group Chaining**, defined programmatically:

1. **ALB Security Group (`ALBSecurityGroup`)**:
   - Ingress: Allows HTTP (Port 80) from `0.0.0.0/0` (the internet).
2. **EC2 Security Group (`EC2SecurityGroup`)**:
   - Ingress: Allows HTTP (Port 80) **only** from the `ALBSecurityGroup` ID.
   
```yaml
SecurityGroupIngress:
  - IpProtocol: tcp
    FromPort: 80
    ToPort: 80
    SourceSecurityGroupId: !Ref ALBSecurityGroup
```
*Because this is defined in code, it is impossible to accidentally misconfigure the EC2 instance to be open to the public internet during deployment.*

## 🤫 Parameter Security (NoEcho)

When writing CloudFormation templates, hardcoding passwords or API keys is a critical security vulnerability.

### NoEcho Parameters
For sensitive inputs (like database passwords), CloudFormation provides the `NoEcho: true` property. When applied to a Parameter, AWS masks the value in the Console, CLI outputs, and logs.

### AWS Systems Manager (SSM) Parameter Store & Secrets Manager
Modern templates integrate with AWS Secrets Manager or SSM Parameter Store using dynamic references (`{{resolve:ssm-secure:...}}`). This allows the template to fetch secrets at deployment time without the secret ever being visible in the template or the parameter inputs.

## 🕵️‍♂️ Drift Detection for Security Auditing

CloudFormation's **Drift Detection** acts as a security auditing tool. 
If a malicious actor or an inexperienced developer manually opens Port 22 (SSH) to the world `0.0.0.0/0` via the AWS Console, the CloudFormation stack will report **MODIFIED** during a drift check, immediately flagging the security breach for remediation.
