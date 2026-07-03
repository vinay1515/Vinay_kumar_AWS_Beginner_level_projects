# Architecture Details

## Amazon CloudWatch
- **Metrics:** Collects default metrics at 5-minute intervals (or 1-minute with detailed monitoring).
- **Alarms:** Configured to watch metrics like `CPUUtilization`, `DatabaseConnections`, and `EstimatedCharges`. They transition between `OK`, `ALARM`, and `INSUFFICIENT_DATA`.
- **Dashboards:** A single pane of glass visualizing the health of all monitored resources using line graphs and number widgets.

## Amazon SNS (Simple Notification Service)
- A Pub/Sub messaging service.
- **Topic:** A logical access point that CloudWatch Alarms publish to.
- **Subscription:** An email address subscribed to the topic. When a message hits the topic, AWS automatically forwards it via email.