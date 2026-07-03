# Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| **Instances failing Health Checks** | Security Groups / User Data | Ensure `EC2-SG` accepts port 80 from `ALB-SG`. Ensure your User Data script successfully installed and started the `httpd` daemon. |
| **502 Bad Gateway from ALB** | Target Group Empty | The ALB has no healthy instances to route to. Check the Target Group to see if the instances are registered and healthy. |
| **Cannot delete ALB or ASG** | Dependency Order | You must delete the ASG first (which terminates the instances). Then delete the ALB, then the Target Group. |
