#!/usr/bin/env bash

ADDR='http://169.254.169.254/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance'

# Pull the credentials
CREDENTIALS=$(curl -s "$ADDR" -E ~/creds/my-cert.crt --key ~/creds/my-key.key --cacert /home/aws/cert.pem | python -m json.tool)
[[ "$?" == 0 ]] || { echo 1>&2 "Couldnt get credentials..."; exit 1; }

# Create the creds file
echo '[default]'
echo "$CREDENTIALS" | sed -rn 's/^\s*"AccessKeyId":\s*"([^"]+)".*$/AWS_ACCESS_KEY_ID=\1/p'
echo "$CREDENTIALS" | sed -rn 's/^\s*"SecretAccessKey":\s*"([^"]+)".*$/AWS_SECRET_ACCESS_KEY=\1/p'
echo "$CREDENTIALS" | sed -rn 's/^\s*"SessionToken":\s*"([^"]+)".*$/AWS_SESSION_TOKEN=\1/p'

exit 0

