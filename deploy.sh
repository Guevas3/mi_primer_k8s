#!/bin/bash

# 🚀 Script de Deploy para Proyecto Web en Kubernetes

# --- FAIL FAST & SANITY CHECKS ---
set -euo pipefail
IFS=$'\n\t'

# --- CONFIGURACIÓN ---
STATIC_REPO="https://github.com/Guevas3/static-website.git"
PROJECT_REPO="https://github.com/Guevas3/mi_primer_k8s.git"
STATIC_DIR="static-website"
PROJECT_DIR="mi_primer_k8s"
MOUNT_SRC="$(pwd)/$STATIC_DIR"
MOUNT_DEST="/mnt/web"
HOSTS_FILE="/etc/hosts"
INGRESS_DOMAIN="local.service"

# --- VERIFICAR DEPENDENCIAS ---
function check_dependencies() {
    echo "🔍 Verificando dependencias..."
    for cmd in minikube kubectl docker git; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "❌ $cmd no está instalado. Abortando."
            exit 1
        fi
    done
    echo "✅ Todas las dependencias están presentes"
}

# --- CLONAR REPOSITORIOS ---
function clone_repos() {
    echo "📥 Clonando repositorios..."
    [ -d "$PROJECT_DIR" ] || git clone "$PROJECT_REPO"
    [ -d "$STATIC_DIR" ] || git clone "$STATIC_REPO"
}

# --- INICIAR MINIKUBE ---
function start_minikube() {
    echo "🚀 Iniciando Minikube con montaje de carpeta: $MOUNT_SRC"
    minikube delete
    minikube start --memory=4096 --cpus=2 --mount --mount-string="$MOUNT_SRC:$MOUNT_DEST"
}

# --- APLICAR ARCHIVOS K8S ---
function apply_manifests() {
    echo "📄 Aplicando archivos de Kubernetes..."
    cd "$PROJECT_DIR" || { echo "❌ No se encontró la carpeta $PROJECT_DIR. Abortando."; exit 1; }
    cd manifiestos_k8s || { echo "❌ No se encontró la carpeta manifiestos_k8s. Abortando."; exit 1; }

    for dir in volumes deployments services; do
        if [ -d "$dir" ]; then
            echo "📁 Aplicando archivos en $dir..."
            kubectl apply -f "$dir/"
        else
            echo "⚠️ Carpeta $dir no encontrada. Saltando."
        fi
    done
}

# --- ESPERAR POD EN RUNNING ---
function wait_for_pod() {
    echo "⏳ Esperando que el pod esté en estado 'Running' (hasta 10 minutos)..."
    local start_time=$(date +%s)
    while true; do
        POD_STATUS=$(kubectl get pods --no-headers | awk '{print $3}')
        if [ "$POD_STATUS" == "Running" ]; then
            echo "✅ El pod está en estado Running."
            break
        fi
        local now=$(date +%s)
        local elapsed=$((now - start_time))
        if [ "$elapsed" -ge 600 ]; then
            echo "❌ El pod no llegó a estado 'Running' tras 10 minutos. Abortando."
            exit 1
        fi
        echo "⌛ Estado actual: $POD_STATUS. Reintentando en 10s..."
        sleep 10
    done
}

# --- ACCEDER AL SERVICIO ---
function open_service() {
    echo "🌐 Accediendo al servicio sitio-web-service en el navegador..."
    minikube service sitio-web-service &
}

# --- CONFIGURAR INGRESS ---
function configure_ingress() {
    echo "🔌 Habilitando complemento ingress..."
    minikube addons enable ingress

    echo "❗ Eliminando webhook que causa errores..."
    kubectl delete ValidatingWebhookConfiguration ingress-nginx-admission || true

    echo "⏳ Esperando que el Ingress Controller esté en estado 'Running' (hasta 10 minutos)..."
    local start_time=$(date +%s)
    while true; do
        CONTROLLER_STATUS=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller --no-headers 2>/dev/null | awk '{print $3}')
        if [ "$CONTROLLER_STATUS" == "Running" ]; then
            echo "✅ Ingress Controller está en estado Running."
            break
        fi
        local now=$(date +%s)
        local elapsed=$((now - start_time))
        if [ "$elapsed" -ge 600 ]; then
            echo "❌ El Ingress Controller no está listo tras 10 minutos. Abortando."
            exit 1
        fi
        echo "⌛ Estado actual del controller: $CONTROLLER_STATUS. Reintentando en 10s..."
        sleep 10
    done
}

# --- APLICAR INGRESS.YAML ---
function apply_ingress() {
    if [ -d "ingress" ]; then
        echo "📄 Aplicando archivo ingress.yaml desde carpeta ingress/..."
        cd ingress || exit 1
        kubectl apply -f .
        cd ..
    else
        echo "⚠️ Carpeta ingress no encontrada. Saltando aplicación de ingress.yaml."
    fi
}

# --- CONFIGURAR /ETC/HOSTS ---
function configure_hosts() {
    local ip=$(minikube ip)
    echo "🖥️ La IP de Minikube es: $ip"
    if ! grep -q "$INGRESS_DOMAIN" "$HOSTS_FILE"; then
        echo "$ip $INGRESS_DOMAIN" | sudo tee -a "$HOSTS_FILE"
    else
        echo "🟢 Entrada en /etc/hosts ya existe"
    fi
}

# --- MOSTRAR URL FINAL ---
function show_final_url() {
    echo "✅ Abrí tu navegador y entrá a: http://$INGRESS_DOMAIN/"
}

# --- MAIN ---
function main() {
    check_dependencies
    clone_repos
    start_minikube
    apply_manifests
    wait_for_pod
    open_service
    configure_ingress
    apply_ingress
    configure_hosts
    show_final_url
}

main "$@"
