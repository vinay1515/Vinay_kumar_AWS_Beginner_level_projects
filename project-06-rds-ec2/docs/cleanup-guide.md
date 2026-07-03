# Cleanup Guide

> [!WARNING]
> RDS databases are expensive if left running outside the Free Tier. Always delete unused databases.

1. **Delete RDS Database:** Navigate to RDS. Select the database and choose Delete. Uncheck "Create final snapshot" and acknowledge the deletion. This will take ~5-10 minutes.
2. **Delete EC2 Instance:** Terminate the App Server EC2 instance.
3. **Delete Secret:** Navigate to Secrets Manager and delete the secret. (Note: Secrets have a mandatory recovery window, so it will go into a scheduled deletion state).
4. **Delete Security Groups:** Once the EC2 and RDS instances are fully terminated, delete the `DB-SG` and `Web-SG`.