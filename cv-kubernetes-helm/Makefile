.PHONY: help install uninstall upgrade status logs port-forward clean build test

# Variables
RELEASE_NAME := cv-release
NAMESPACE := default
IMAGE_NAME := cv-web
IMAGE_TAG := latest

help: ## Muestra esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

cluster-start: ## Inicia el clúster Minikube
	@echo "Iniciando clúster Minikube con 3 nodos..."
	minikube start --nodes 3 --driver=docker --cpus=2 --memory=4096 
	minikube addons enable ingress
	@echo "✓ Clúster iniciado"

cluster-stop: ## Detiene el clúster
	@echo "Deteniendo clúster..."
	minikube stop
	@echo "✓ Clúster detenido"

cluster-delete: ## Elimina el clúster
	@echo "Eliminando clúster..."
	minikube delete
	@echo "✓ Clúster eliminado"

build: ## Construye la imagen Docker
	@echo "Construyendo imagen Docker..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) ./app
	@echo "Cargando imagen en Minikube..."
	minikube image load $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "✓ Imagen construida y cargada"

install: build ## Construye e instala el Helm chart
	@echo "Instalando Helm chart..."
	helm install $(RELEASE_NAME) ./helm-chart
	@echo "✓ Chart instalado"
	@echo "Esperando a que los pods estén listos..."
	kubectl wait --for=condition=ready pod -l app=cv-web --timeout=120s
	@echo "✓ Pods listos"

upgrade: build ## Actualiza el despliegue
	@echo "Actualizando Helm chart..."
	helm upgrade $(RELEASE_NAME) ./helm-chart
	@echo "✓ Chart actualizado"

uninstall: ## Desinstala el Helm chart
	@echo "Desinstalando Helm chart..."
	helm uninstall $(RELEASE_NAME)
	@echo "✓ Chart desinstalado"

status: ## Muestra el estado del despliegue
	@echo "=== Estado del Clúster ==="
	kubectl get nodes
	@echo "\n=== Pods ==="
	kubectl get pods -o wide
	@echo "\n=== Servicios ==="
	kubectl get svc
	@echo "\n=== Ingress ==="
	kubectl get ingress
	@echo "\n=== Helm Release ==="
	helm status $(RELEASE_NAME)

logs: ## Muestra los logs de todos los pods
	@echo "Logs de los pods:"
	kubectl logs -l app=cv-web --tail=50 --follow

logs-pod: ## Muestra logs de un pod específico (uso: make logs-pod POD=nombre-pod)
	kubectl logs $(POD) --tail=100 --follow

describe-pod: ## Describe un pod específico (uso: make describe-pod POD=nombre-pod)
	kubectl describe pod $(POD)

exec-pod: ## Abre shell en un pod (uso: make exec-pod POD=nombre-pod)
	kubectl exec -it $(POD) -- /bin/sh

port-forward: ## Reenvía el puerto del servicio a localhost:8080
	@echo "Reenviando puerto 80 del servicio a localhost:8080..."
	@echo "Accede a: http://localhost:8080"
	kubectl port-forward svc/$(RELEASE_NAME)-cv-pedro-merino 8080:80

tunnel: ## Inicia el túnel de Minikube
	@echo "Iniciando túnel de Minikube..."
	@echo "Mantén esta terminal abierta y accede a: http://cv.local"
	minikube tunnel

service-url: ## Obtiene la URL del servicio en Minikube
	minikube service $(RELEASE_NAME)-cv-pedro-merino --url

test: ## Ejecuta tests básicos
	@echo "Verificando que los pods estén corriendo..."
	kubectl get pods -l app=cv-web | grep Running || (echo "✗ Los pods no están corriendo" && exit 1)
	@echo "✓ Pods corriendo"
	@echo "Verificando health endpoint..."
	@POD=$$(kubectl get pod -l app=cv-web -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec $$POD -- wget -q -O- http://localhost/health | grep healthy || (echo "✗ Health check falló" && exit 1)
	@echo "✓ Health check OK"

scale: ## Escala el deployment (uso: make scale REPLICAS=5)
	@echo "Escalando a $(REPLICAS) réplicas..."
	kubectl scale deployment/cv-release-cv-pedro-merino --replicas=$(REPLICAS)
	@echo "✓ Deployment escalado"

clean: uninstall cluster-delete ## Limpia todo (desinstala y elimina clúster)
	@echo "✓ Limpieza completa"

full-deploy: cluster-start install status ## Despliegue completo desde cero
	@echo "✓ Despliegue completo exitoso!"

lint-helm: ## Valida el Helm chart
	@echo "Validando Helm chart..."
	helm lint ./helm-chart
	@echo "✓ Chart válido"

template-helm: ## Muestra los manifests generados por Helm
	helm template $(RELEASE_NAME) ./helm-chart

dry-run: ## Simula la instalación
	helm install $(RELEASE_NAME) ./helm-chart --dry-run --debug

watch-pods: ## Observa el estado de los pods en tiempo real
	watch -n 2 kubectl get pods -o wide

dashboard: ## Abre el dashboard de Kubernetes
	minikube dashboard

monitoring-install: ## Instala stack de monitoreo (Prometheus + Grafana)
	@echo "Instalando stack de monitoreo..."
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install prometheus prometheus-community/kube-prometheus-stack
	@echo "✓ Monitoreo instalado"
	@echo "Accede a Grafana: kubectl port-forward svc/prometheus-grafana 3000:80"

# Variables por defecto
REPLICAS ?= 3
POD ?= $(shell kubectl get pod -l app=cv-web -o jsonpath='{.items[0].metadata.name}')
