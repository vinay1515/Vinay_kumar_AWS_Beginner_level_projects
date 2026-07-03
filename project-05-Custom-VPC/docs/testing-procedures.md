# Testing Procedures

To verify your custom VPC is routed correctly:

1. SSH into the Bastion Host using PuTTY (via its Public IP).
2. Once inside the Bastion, copy your `.pem` key to it, and SSH into the Private Instance using its *Private IP*.
3. Once inside the Private Instance, attempt to ping the internet:
   ```bash
   ping google.com
   ```
   *Expected Result:* The ping should succeed. This proves the Private Route Table is successfully pushing traffic out through the NAT Gateway.
4. Attempt to SSH into the Private Instance from your local machine.
   *Expected Result:* Connection timeout (as designed, it is isolated).