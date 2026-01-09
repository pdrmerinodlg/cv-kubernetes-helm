#!/bin/bash

# Script de setup rápido para CV Kubernetes + Helm
# Para macOS/Linux

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  CV Kubernetes + Helm Setup${NC}"
echo -e "${BLUE}  Pedro Merino - DevOps Engineer${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Verificar prerrequisitos
check_prerequisites() {
    echo -e "${YELLOW}Verificando prerrequisitos...${NC}"
    
    local missing_tools=()
    
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if ! command -v helm &> /dev/null; then
        missing_tools+=("helm")
    fi
    
    if ! command -v minikube &> /dev/null && ! command -v kind &> /dev/null; then
        missing_tools+=("minikube o kind")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}ERROR: Faltan las siguientes herramientas:${NC}"
        printf '%s\n' "${missing_tools[@]}"
        echo -e "\n${YELLOW}Instala las herramientas faltantes:${NC}"
        echo "brew install docker kubectl helm minikube"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Todos los prerrequisitos están instalados${NC}\n"
}

# Iniciar clúster
start_cluster() {
    echo -e "${YELLOW}Iniciando clúster Kubernetes...${NC}"
    
    if command -v minikube &> /dev/null; then
        echo "Usando Minikube..."
        minikube start --nodes 3 --driver=docker --cpus=2 --memory=4096
        minikube addons enable ingress
        echo -e "${GREEN}✓ Clúster Minikube iniciado${NC}\n"
    elif command -v kind &> /dev/null; then
        echo "Usando Kind..."
        kind create cluster --config=kind-config.yaml
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        echo -e "${GREEN}✓ Clúster Kind iniciado${NC}\n"
    fi
}

# Construir imagen
build_image() {
    echo -e "${YELLOW}Construyendo imagen Docker...${NC}"
    docker build -t cv-web:latest ./app
    
    if command -v minikube &> /dev/null; then
        echo "Cargando imagen en Minikube..."
        minikube image load cv-web:latest
    elif command -v kind &> /dev/null; then
        echo "Cargando imagen en Kind..."
        kind load docker-image cv-web:latest --name cv-cluster
    fi
    
    echo -e "${GREEN}✓ Imagen construida y cargada${NC}\n"
}

# Desplegar con Helm
deploy_helm() {
    echo -e "${YELLOW}Desplegando con Helm...${NC}"
    helm install cv-release ./helm-chart
    
    echo -e "${GREEN}✓ Aplicación desplegada${NC}\n"
}

# Esperar a que los pods estén listos
wait_for_pods() {
    echo -e "${YELLOW}Esperando a que los pods estén listos...${NC}"
    kubectl wait --for=condition=ready pod -l app=cv-web --timeout=120s
    echo -e "${GREEN}✓ Todos los pods están listos${NC}\n"
}

# Mostrar información
show_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Estado del Despliegue${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    echo -e "${YELLOW}Nodos del clúster:${NC}"
    kubectl get nodes
    
    echo -e "\n${YELLOW}Pods:${NC}"
    kubectl get pods -o wide
    
    echo -e "\n${YELLOW}Servicios:${NC}"
    kubectl get svc
    
    echo -e "\n${YELLOW}Ingress:${NC}"
    kubectl get ingress
    
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN}✓ Despliegue completado exitosamente!${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    
    if command -v minikube &> /dev/null; then
        echo -e "${YELLOW}Para acceder a la aplicación:${NC}"
        echo "minikube service cv-release-cv-pedro-merino --url"
        echo ""
        echo -e "${YELLOW}O habilita el túnel en otra terminal:${NC}"
        echo "minikube tunnel"
        echo "Luego accede a: http://cv.local"
    elif command -v kind &> /dev/null; then
        echo -e "${YELLOW}Para acceder a la aplicación:${NC}"
        echo "kubectl port-forward svc/cv-release-cv-pedro-merino 8080:80"
        echo "Luego accede a: http://localhost:8080"
    fi
    
    echo -e "\n${YELLOW}Comandos útiles:${NC}"
    echo "kubectl get pods                              # Ver pods"
    echo "kubectl logs <pod-name>                       # Ver logs"
    echo "kubectl describe pod <pod-name>               # Detalles del pod"
    echo "helm list                                     # Ver releases"
    echo "helm status cv-release                        # Estado del release"
    echo "kubectl exec -it <pod-name> -- /bin/sh       # Shell en pod"
}

# Función de limpieza
cleanup() {
    echo -e "\n${YELLOW}Limpiando recursos...${NC}"
    helm uninstall cv-release 2>/dev/null || true
    
    if command -v minikube &> /dev/null; then
        minikube delete
    elif command -v kind &> /dev/null; then
        kind delete cluster --name cv-cluster
    fi
    
    echo -e "${GREEN}✓ Limpieza completada${NC}"
}

# Menú principal
main() {
    case "${1:-}" in
        start)
            check_prerequisites
            start_cluster
            build_image
            deploy_helm
            wait_for_pods
            show_info
            ;;
        stop)
            cleanup
            ;;
        restart)
            cleanup
            sleep 2
            check_prerequisites
            start_cluster
            build_image
            deploy_helm
            wait_for_pods
            show_info
            ;;
        status)
            show_info
            ;;
        *)
            echo "Uso: $0 {start|stop|restart|status}"
            echo ""
            echo "  start   - Inicia el clúster y despliega la aplicación"
            echo "  stop    - Detiene y limpia todos los recursos"
            echo "  restart - Reinicia todo el entorno"
            echo "  status  - Muestra el estado actual"
            exit 1
            ;;
    esac
}

# Ejecutar
main "$@"
