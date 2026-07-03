# Architecture Details

## CloudFormation Template Structure
- **Parameters:** Allow dynamic inputs during deployment (e.g., Instance Type, VPC CIDR).
- **Mappings:** Static lookup tables (e.g., mapping Region to the correct AMI ID).
- **Resources:** The actual AWS components being provisioned (VPC, IGW, Subnets, SG, LaunchTemplate, ASG, ALB).
- **Outputs:** Values returned after deployment (e.g., the ALB DNS URL).

## Intrinsic Functions
The template utilizes intrinsic functions heavily to link resources:
- `!Ref` (Get the ID of a resource)
- `!GetAtt` (Get an attribute, like an ARN)
- `!Sub` (Substitute variables in a string)
