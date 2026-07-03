# Project Overview

## The Business Problem
Clicking through the AWS Console to build complex architectures (like the VPC/ALB/ASG in previous projects) is prone to human error, difficult to replicate across regions or accounts, and provides no audit trail of infrastructure changes.

## The Solution
Infrastructure as Code (IaC) solves these problems. This project uses AWS CloudFormation to define the entire architecture in a single declarative YAML template. CloudFormation parses this template, calculates dependencies, and automatically provisions or updates the AWS resources exactly as defined.