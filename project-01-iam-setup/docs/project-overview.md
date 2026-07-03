# Project Overview

## The Business Problem
When creating a new AWS account, the Root user has unrestricted access to all resources and billing. Using the Root user for daily tasks is a massive security risk. Furthermore, untracked spending is a common issue for cloud beginners.

## The Solution
This project implements AWS security best practices by locking down the Root user with Multi-Factor Authentication (MFA), creating a restricted IAM Administrator user for daily operations, and setting up automated billing alerts to prevent unexpected charges.