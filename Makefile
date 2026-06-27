include .env
export

apply:
	helm upgrade --install chatops ./k3s/chatops

apply-dev:
	helm upgrade --install chatops ./k3s/chatops -f k3s/chatops/values.local.yaml
	kubectl rollout restart deployment backend-api backend-worker frontend

import-images:
	docker save chatops-frontend:latest -o frontend.tar && k3s ctr images import frontend.tar && rm frontend.tar
	docker save chatops-backend:latest -o backend.tar && k3s ctr images import backend.tar && rm backend.tar

status:
	kubectl get pods

ingress:
	kubectl get ingress

setup-ngrok:
	helm repo add ngrok https://charts.ngrok.com 
	helm repo update
	helm upgrade --install ngrok-operator ngrok/ngrok-operator \
		--namespace ngrok-operator \
		--create-namespace \
		--set credentials.apiKey=$(NGROK_API_KEY) \
		--set credentials.authtoken=$(NGROK_AUTHTOKEN)