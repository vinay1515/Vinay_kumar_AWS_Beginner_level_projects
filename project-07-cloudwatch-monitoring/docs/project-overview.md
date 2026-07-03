# Project Overview

## The Business Problem
Without automated monitoring, administrators are blind to system failures until users report them. Furthermore, without billing alerts, a misconfigured service can rack up thousands of dollars in charges before it is noticed.

## The Solution
This project implements AWS CloudWatch to collect and visualize metrics across EC2 and RDS. It utilizes CloudWatch Alarms to monitor thresholds and Amazon SNS to send immediate email notifications when a threshold is breached, enabling a proactive operational posture.