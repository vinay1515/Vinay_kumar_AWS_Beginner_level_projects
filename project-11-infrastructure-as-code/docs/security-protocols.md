# Security Protocols

- **Template Security:** Store CloudFormation templates in a Git repository (like CodeCommit). Treat infrastructure changes with the same scrutiny as application code (Pull Requests, Code Reviews).
- **Drift Detection:** CloudFormation provides Drift Detection, which identifies if an administrator has manually modified a resource (e.g. manually opening port 22 in a security group) outside of the template, enabling quick remediation of security violations.