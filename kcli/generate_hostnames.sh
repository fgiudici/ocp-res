#!/bin/bash

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Usage: $0 \${DOMAIN}"
    exit 1
fi

DNS_NAMES="api console-openshift-console.apps oauth-openshift.apps prometheus-k8s-openshift-monitoring.apps grafana-openshift-monitoring.apps openshift-authentication-openshift-authentication multicloud-console.apps"

for i in $DNS_NAMES; do
    dns_output="$dns_output $i.$DOMAIN"
done

echo $dns_output
