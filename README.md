# Crear directorio principal
mkdir -p cv-kubernetes-helm
cd cv-kubernetes-helm

# Crear estructura de directorios
mkdir -p app/html
mkdir -p helm-chart/templates
mkdir -p .github/workflows
mkdir -p k8s

# Estructura del directorio

<img width="442" height="856" alt="image" src="https://github.com/user-attachments/assets/08f31745-e967-4f48-801c-dcf601d813e8" />



# Instalar Docker

# Instalar herramientas
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verificar instalaciones
docker --version
kubectl version --client
helm version
minikube version

Opción A: Usando el script de setup (MÁS FÁCIL)
bash# Iniciar todo automáticamente
./setup.sh start
Opción B: Usando Makefile (RECOMENDADO)
bash# Ver todos los comandos disponibles
make help

# Despliegue completo automático
make full-deploy

# O paso a paso:
make cluster-start    # Inicia el clúster
make build           # Construye la imagen
make install         # Instala con Helm
make status          # Ver estado
Paso 6: Acceder a tu CV
Después del despliegue, tienes varias opciones:
Opción 1: Port Forward (más simple)
bashmake port-forward

# O manualmente:
kubectl port-forward svc/cv-release-cv-pedro-merino 8080:80
Luego abre: http://localhost:8080
Opción 2: Minikube Service
bashminikube service cv-release-cv-pedro-merino

# Esto abrirá automáticamente tu navegador
Opción 3: Minikube Tunnel (para usar el Ingress)
bash# En una terminal separada:
make tunnel

# O manualmente:
minikube tunnel

# Añade a /etc/hosts:
echo "127.0.0.1 cv.local" | sudo tee -a /etc/hosts

# Accede a:
open http://cv.local
Paso 7: Comandos útiles
bash# Ver el estado de todo
make status

# Ver logs en tiempo real
make logs

# Escalar a 5 réplicas
make scale REPLICAS=5

# Ver pods en tiempo real
make watch-pods

# Acceder a un pod
make exec-pod POD=nombre-del-pod

# Actualizar después de cambios
make upgrade

# Limpiar todo
make clean
