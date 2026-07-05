$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
$AWS_REGION = (Get-Content ..\..\.env | Where-Object { $_ -match '^AWS_REGION=' } | ForEach-Object { $_ -replace '^AWS_REGION=','' })
aws s3 sync ..\..\website\ s3://$BUCKET_NAME/ --region $AWS_REGION
