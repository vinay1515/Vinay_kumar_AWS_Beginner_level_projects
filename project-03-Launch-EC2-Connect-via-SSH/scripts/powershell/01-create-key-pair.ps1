# Create the keys folder
mkdir C:\Users\$env:USERNAME\aws-keys -ErrorAction SilentlyContinue

# Create key pair and save private key
aws ec2 create-key-pair `
  --key-name aws-ec2-keypair `
  --key-type RSA `
  --key-format ppk `
  --query "KeyMaterial" `
  --output text | Out-File `
  -FilePath "C:\Users\$env:USERNAME\aws-keys\aws-ec2-keypair.ppk" `
  -Encoding ascii

# Verify it was created in AWS
aws ec2 describe-key-pairs --key-names aws-ec2-keypair `
  --query "KeyPairs[*].{Name:KeyName,ID:KeyPairId}" `
  --output table
