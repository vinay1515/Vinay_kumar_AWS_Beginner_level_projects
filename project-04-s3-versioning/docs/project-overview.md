# Project Overview

## The Business Problem
Storing data in S3 natively is cheap, but human errors or malicious actors deleting data can result in catastrophic data loss. Furthermore, as data grows, storing petabytes of infrequently accessed logs in S3 Standard becomes prohibitively expensive.

## The Solution
This project configures an automated, resilient storage tier. By enabling **Versioning**, we protect against deletions and overwrites. By enabling **Lifecycle Rules**, we seamlessly move cold data to cheaper storage. By configuring **Cross-Region Replication (CRR)**, we maintain a disaster recovery copy in a separate geographical region.