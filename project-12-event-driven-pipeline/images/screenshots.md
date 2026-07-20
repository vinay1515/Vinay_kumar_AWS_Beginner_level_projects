# Project 12 Screenshot List

Here are all screenshots needed for the Project 12 screenshots folder:

## Infrastructure Created
* **01-s3-source-bucket.png**
  * **Where:** S3 console → event-pipeline-source-ACCOUNT
  * **Capture:** Bucket properties — versioning enabled, region ap-south-1
* **02-s3-output-bucket.png**
  * **Where:** S3 console → event-pipeline-output-ACCOUNT
  * **Capture:** Bucket created, public access all blocked
* **03-sqs-main-queue-details.png**
  * **Where:** SQS console → file-processing-queue
  * **Capture:** Queue details — URL, visibility timeout 60s, wait time 20s
* **04-sqs-dlq-details.png**
  * **Where:** SQS console → file-processing-dlq
  * **Capture:** DLQ details — retention 14 days
* **05-sqs-redrive-policy.png**
  * **Where:** SQS console → file-processing-queue → Dead-letter queue tab
  * **Capture:** Redrive policy showing DLQ configured, maxReceiveCount=3
* **06-sqs-access-policy.png**
  * **Where:** SQS console → file-processing-queue → Access policy tab
  * **Capture:** Policy JSON showing s3.amazonaws.com allowed to SendMessage
* **07-s3-event-notification-csv.png**
  * **Where:** S3 → source bucket → Properties → Event notifications
  * **Capture:** SendToSQSOnUpload notification — prefix uploads/, suffix .csv
* **08-s3-event-notification-json.png**
  * **Where:** Same Event notifications panel
  * **Capture:** SendToSQSOnJsonUpload notification — suffix .json visible

## Lambda Setup
* **09-lambda-function-overview.png**
  * **Where:** Lambda console → file-processor → Overview tab
  * **Capture:** Function name, runtime Python 3.12, memory 256MB, timeout 60s
* **10-lambda-code-editor.png**
  * **Where:** Lambda console → file-processor → Code tab
  * **Capture:** lambda_function.py code visible in editor
* **11-lambda-environment-vars.png**
  * **Where:** Lambda → Configuration → Environment variables
  * **Capture:** OUTPUT_BUCKET and REGION variables listed
* **12-lambda-iam-role-policies.png**
  * **Where:** IAM → lambda-file-processor-role → Permissions tab
  * **Capture:** Three policies — BasicExecution, SQSExecution, s3-pipeline-access inline
* **13-lambda-trigger-sqs.png**
  * **Where:** Lambda → Configuration → Triggers
  * **Capture:** SQS file-processing-queue shown as trigger, State=Enabled, BatchSize=1

## Pipeline Execution
* **14-files-uploaded-s3.png**
  * **Where:** S3 → source bucket → uploads/ folder
  * **Capture:** test-employees.csv and test-orders.json both listed with sizes
* **15-sqs-messages-in-flight.png**
  * **Where:** SQS console → file-processing-queue → Send and receive messages
  * **Capture:** ApproximateNumberOfMessagesNotVisible > 0 (catch quickly after upload)
* **16-lambda-monitor-invocations.png**
  * **Where:** Lambda → file-processor → Monitor tab → Metrics
  * **Capture:** Invocations graph showing spikes (2 invocations)
* **17-lambda-monitor-duration.png**
  * **Where:** Lambda → Monitor tab → Duration graph
  * **Capture:** Duration metric showing execution time per invocation
* **18-cloudwatch-logs-overview.png**
  * **Where:** CloudWatch → Log groups → /aws/lambda/file-processor
  * **Capture:** Log group with log streams listed
* **19-cloudwatch-log-stream-detail.png**
  * **Where:** CloudWatch → click latest log stream
  * **Capture:** Individual log events showing "Successfully processed" messages
* **20-output-bucket-results.png**
  * **Where:** S3 → output bucket → processed/YYYY-MM-DD/
  * **Capture:** Two result files — test-employees-result.json and test-orders-result.json

## Result Contents
* **21-csv-result-json.png**
  * **Where:** PowerShell terminal or S3 Select
  * **Capture:** JSON output showing numeric_stats with salary avg/min/max
* **22-json-result-json.png**
  * **Where:** PowerShell terminal or S3 Select
  * **Capture:** JSON output showing record_count=4, order keys listed

## DLQ Test
* **23-dlq-message-count.png**
  * **Where:** SQS console → file-processing-dlq
  * **Capture:** ApproximateNumberOfMessages = 1 after simulated failure
* **24-lambda-errors-graph.png**
  * **Where:** Lambda → Monitor → Errors graph
  * **Capture:** Error spikes visible during DLQ test
