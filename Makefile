apply:
	helm upgrade --install chatops ./k3s/chatops

import-local-images:
	docker save chatops-frontend:latest -o frontend.tar && k3s ctr images import frontend.tar && rm frontend.tar
	docker save chatops-backend:latest -o backend.tar && k3s ctr images import backend.tar && rm backend.tar

apply-local:
	helm upgrade --install chatops ./k3s/chatops -f k3s/chatops/values.local.yaml

status:
	kubectl get pods

ingress-info:
	kubectl get ingress
