#!/bin/bash

# 🚀 Script de Deploy para Proyecto Web en Kubernetes

# -------------------------
# 🛠️ Verificar Requisitos
# -------------------------
for cmd in minikube kubectl docker git; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ $cmd no está instalado. Abortando."
    exit 1
  fi
done

# -------------------------
# 📂 Clonar Repositorios
# -------------------------
echo "📥 Clonando repositorios..."
[ -d "mi_primer_k8s" ] || git clone https://github.com/Guevas3/mi_primer_k8s.git
[ -d "static-website" ] || git clone https://github.com/Guevas3/static-website.git

# -------------------------
# 🧪 Iniciar Minikube
# -------------------------
STATIC_SITE_PATH="$(pwd)/static-website"
echo "🚀 Iniciando Minikube con montaje de carpeta: $STATIC_SITE_PATH"
minikube delete
minikube start --memory=4096 --cpus=2 --mount --mount-string="$STATIC_SITE_PATH:/mnt/web"

# -------------------------
# 📦 Aplicar Archivos K8s
# -------------------------
echo "📄 Aplicando archivos de Kubernetes..."

cd mi_primer_k8s || { echo "❌ No se encontró la carpeta mi_primer_k8s. Abortando."; exit 1; }
cd manifiestos_k8s || { echo "❌ No se encontró la carpeta manifiestos_k8s. Abortando."; exit 1; }

for dir in volumes deployments services; do
  if [ -d "$dir" ]; then
    echo "📁 Aplicando archivos en $dir..."
    kubectl apply -f "$dir/"
  else
    echo "⚠️ Carpeta $dir no encontrada. Saltando."
  fi
done

# -------------------------
# ✅ Esperar Pod en Running (hasta 10 min)
# -------------------------
echo "⏳ Esperando que el pod esté en estado 'Running' (hasta 10 minutos)..."
start_time=$(date +%s)
while true; do
  POD_STATUS=$(kubectl get pods --no-headers | awk '{print $3}')
  if [ "$POD_STATUS" == "Running" ]; then
    echo "✅ El pod está en estado Running."
    break
  fi
  now=$(date +%s)
  elapsed=$((now - start_time))
  if [ "$elapsed" -ge 600 ]; then
    echo "❌ El pod no llegó a estado 'Running' tras 10 minutos. Abortando."
    exit 1
  fi
  echo "⌛ Estado actual: $POD_STATUS. Reintentando en 10s..."
  sleep 10
done

# -------------------------
# 🌐 Acceder al Servicio
# -------------------------
echo "🌐 Accediendo al servicio sitio-web-service en el navegador..."
minikube service sitio-web-service &

# -------------------------
# 🌉 Activar Ingress
# -------------------------
echo "🔌 Habilitando complemento ingress..."
minikube addons enable ingress

#Eliminamos el webhook porque tira error
kubectl delete ValidatingWebhookConfiguration ingress-nginx-admission

# Esperar al Ingress Controller
echo "⏳ Esperando que el Ingress Controller esté en estado 'Running' (hasta 10 minutos)..."
start_time=$(date +%s)
while true; do
  CONTROLLER_STATUS=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | awk '{print $3}')
  if [ "$CONTROLLER_STATUS" == "Running" ]; then
    echo "✅ Ingress Controller está en estado Running."
    break
  fi
  now=$(date +%s)
  elapsed=$((now - start_time))
  if [ "$elapsed" -ge 600 ]; then
    echo "❌ El Ingress Controller no está listo tras 10 minutos. Abortando."
    exit 1
  fi
  echo "⌛ Estado actual del controller: $CONTROLLER_STATUS. Reintentando en 10s..."
  sleep 10
done


# -------------------------
# 📄 Aplicar ingress.yaml
# -------------------------
if [ -d "ingress" ]; then
  echo "📄 Aplicando archivo ingress.yaml desde carpeta ingress/..."
  cd ingress || exit 1
  kubectl apply -f .

  cd ..
else
  echo "⚠️ Carpeta ingress no encontrada. Saltando aplicación de ingress.yaml."
fi

# -------------------------
# 🌍 Configurar /etc/hosts
# -------------------------
MINIKUBE_IP=$(minikube ip)
echo "🖥️ La IP de Minikube es: $MINIKUBE_IP"
echo "$MINIKUBE_IP local.service" | sudo tee -a /etc/hosts

# -------------------------
# 🖥️ Acceder a la Página
# -------------------------
echo "✅ Abrí tu navegador y entrá a: http://local.service/"
