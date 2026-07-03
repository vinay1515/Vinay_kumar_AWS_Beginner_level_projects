# Security Protocols

- **Versioning as Backup:** Enabling versioning prevents Ransomware from destroying data. If objects are overwritten with encrypted garbage, administrators simply roll back to the previous version.
- **KMS Encryption with CRR:** If using KMS Customer Managed Keys, the replication IAM role must be granted explicit permissions to `kms:Decrypt` using the source key and `kms:GenerateDataKey` using the destination key.
- **MFA Delete:** For maximum security, MFA Delete can be enabled (via CLI only) which requires a physical token code to permanently delete any object version.