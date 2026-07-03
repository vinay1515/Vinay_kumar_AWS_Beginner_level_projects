# Project Overview

## The Business Problem
Deploying code manually (via FTP, SCP, or manual git pulls on servers) is error-prone, slow, and impossible to scale across fleets of servers. It leads to downtime and configuration drift.

## The Solution
This project establishes a Continuous Integration and Continuous Deployment (CI/CD) pipeline using AWS Developer Tools. Code pushed to the repository is automatically built, tested, and deployed to the target EC2 instance with zero manual intervention.