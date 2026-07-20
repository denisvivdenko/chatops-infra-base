#!/bin/bash

set -a
source .env
set +a

if [ -z "$CLOUDFLARE_TUNNEL_CREDENTIALS_PATH" ]; then
    echo "CLOUDFLARE_TUNNEL_CREDENTIALS_PATH is not set"
    exit 1
fi

CLOUDFLARE_TUNNEL_CREDENTIALS=$(cat "$CLOUDFLARE_TUNNEL_CREDENTIALS_PATH")

if [ -z "$CLOUDFLARE_TUNNEL_CREDENTIALS" ]; then
    echo "CLOUDFLARE_TUNNEL_CREDENTIALS is not set"
    exit 1
fi

echo "CLOUDFLARE_TUNNEL_CREDENTIALS: ${CLOUDFLARE_TUNNEL_CREDENTIALS:0:4}..."

export ENCODED_CLOUDFLARE_TUNNEL_CREDENTIALS=$(echo -n "$CLOUDFLARE_TUNNEL_CREDENTIALS" | base64 -w0)

kubectl create namespace cloudflared --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f -<<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-tunnel-credentials
  namespace: cloudflared
data:
  credentials.json: "$ENCODED_CLOUDFLARE_TUNNEL_CREDENTIALS"
EOF

if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY is not set"
    exit 1
fi

echo "OPENAI_API_KEY: ${OPENAI_API_KEY:0:4}..."

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic openai-api-key \
    --namespace dev \
    --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY" \
    --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f argocd/root-app.yaml