include .env
export

apply:
	helm upgrade --install chatops ./k3s/chatops \
		-f k3s/chatops/values.yaml \
		--namespace prod \
		--create-namespace

apply-dev:
	helm upgrade --install chatops ./k3s/chatops \
		-f k3s/chatops/values.local.yaml \
		--namespace dev \
		--create-namespace

status-dev:
	kubectl get pods -n dev

ingress-dev:
	kubectl get ingress -n dev

restart-dev:
	kubectl rollout restart deployment backend-api backend-worker frontend -n dev

import-images:
	docker save chatops-frontend:latest -o frontend.tar && \
		k3s ctr images import frontend.tar && \
		rm frontend.tar
	docker save chatops-backend:latest -o backend.tar && \
		k3s ctr images import backend.tar && \
		rm backend.tar

setup-reverse-proxy:
	helm repo add ngrok https://charts.ngrok.com 
	helm repo update
	helm upgrade --install ngrok-operator ngrok/ngrok-operator \
		--namespace ngrok-operator \
		--create-namespace \
		--set credentials.apiKey=$(NGROK_API_KEY) \
		--set credentials.authtoken=$(NGROK_AUTHTOKEN)

setup-monitoring:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm upgrade --install loki grafana/loki \
		--namespace dev \
		-f k3s/chatops/values.loki.yaml
	helm upgrade --install grafana grafana/grafana \
		--namespace dev \
		-f k3s/chatops/values.grafana.yaml
	helm upgrade --install alloy grafana/alloy \
		--namespace dev \
		-f k3s/chatops/values.alloy.yaml

ngrok-status:
	kubectl get pods -n ngrok-operator
