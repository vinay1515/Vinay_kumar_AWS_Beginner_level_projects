$BUCKET_NAME = (Get-Content ..\..\.env | Where-Object { $_ -match '^BUCKET_NAME=' } | ForEach-Object { $_ -replace '^BUCKET_NAME=','' })
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}}'
