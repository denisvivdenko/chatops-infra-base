#!/bin/bash

set -a
source .env
set +a

if [ -z "$NGROK_AUTHTOKEN" ]; then
    echo "NGROK_AUTHTOKEN is not set"
    exit 1
fi

if [ -z "$NGROK_API_KEY" ]; then
    echo "NGROK_API_KEY is not set"
    exit 1
fi

echo "NGROK_AUTHTOKEN: ${NGROK_AUTHTOKEN:0:4}..."
echo "NGROK_API_KEY: ${NGROK_API_KEY:0:4}..."

export ENCODED_NGROK_AUTHTOKEN=$(echo -n "$NGROK_AUTHTOKEN" | base64)
export ENCODED_NGROK_API_KEY=$(echo -n "$NGROK_API_KEY" | base64)

kubectl apply -f -<<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ngrok-operator-credentials
  namespace: ngrok-operator
data:
  API_KEY: "$ENCODED_NGROK_API_KEY"
  AUTHTOKEN: "$ENCODED_NGROK_AUTHTOKEN"
EOF

kubectl apply -f argocd/root-app.yaml