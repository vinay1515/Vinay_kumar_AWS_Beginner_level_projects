# Project Overview

## The Business Problem
Running databases directly on EC2 instances (IaaS) requires massive administrative overhead—managing OS patching, database engine patching, manual backups, and manual failovers. Furthermore, hardcoding database credentials in application code is a severe security risk.

## The Solution
This project utilizes Amazon Relational Database Service (RDS) to offload database management to AWS. The architecture deploys the database in a private subnet, connects an EC2 web server to it, and securely retrieves credentials at runtime using AWS Secrets Manager.