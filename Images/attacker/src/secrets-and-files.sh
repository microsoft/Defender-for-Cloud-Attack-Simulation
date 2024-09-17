#!/bin/sh
echo "--- Secrets Gathering ---"
echo "searching for kubernetes service account token"
if (test -f "/var/run/secret/kubernetes.io/serviceaccount/token"); then
    echo "found Kubernetes service account in /var/run/secret/kubernetes.io/serviceaccount/token"
    cat /var/run/secret/kubernetes.io/serviceaccount/token | head -c 50 && echo "..."
else
    echo "Kubernetes service account token not found"
fi
echo " "
echo "looking for secrets in environment variables"
if (`curl -sf -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/" -o /dev/null`); then
    set | grep GOOGLE_DEFAULT_CLIENT_SECRET= || echo "variables not found"
elif (`curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -o /dev/null`); then
    set | grep AWS_SECRET_ACCESS_KEY= || echo "variables not found"
else
    set | grep AZURE_CREDENTIAL_FILE= || echo "variables not found"
fi
echo " "
