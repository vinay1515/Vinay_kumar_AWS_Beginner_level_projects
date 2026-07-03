# Project Overview

## The Business Problem
Using the Default VPC is generally unacceptable for production workloads because its architecture is flat (all subnets are public) and it cannot be properly secured or peered easily if IP ranges overlap.

## The Solution
This project creates a Custom Virtual Private Cloud (VPC) implementing standard 3-tier networking principles. It establishes a secure perimeter by isolating resources in Private Subnets that have no direct inbound internet access, routing outbound traffic through a highly available NAT Gateway.