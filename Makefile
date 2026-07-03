include .env
export

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

port-forward-argocd:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

port-forward-grafana:
	kubectl port-forward -n monitoring svc/grafana 3000:80

get-grafana-admin-password:
	kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 -d
