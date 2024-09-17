#!/bin/sh
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
