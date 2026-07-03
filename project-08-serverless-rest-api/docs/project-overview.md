# Project Overview

## The Business Problem
Traditional web backends require provisioning EC2 instances, configuring load balancers, and managing operating systems. If traffic spikes, the servers might crash before Auto Scaling can react. If traffic is zero, you still pay for idle compute time.

## The Solution
This project implements a Serverless REST API. API Gateway provides a public endpoint that scales infinitely. AWS Lambda executes code only when requested (billing by the millisecond). DynamoDB provides a serverless NoSQL database. You pay literally zero dollars when there is no traffic.