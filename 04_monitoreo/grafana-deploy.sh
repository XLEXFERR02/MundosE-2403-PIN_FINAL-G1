#!/bin/bash

# Verificar si el repositorio de Grafana está agregado
if ! helm repo list | grep -q grafana; then
  echo "🛠️ Agregando repositorio de Grafana..."
  helm repo add grafana https://grafana.github.io/helm-charts
fi

# Actualizar repositorio
helm repo update

# Crear el namespace para Grafana si no existe
kubectl get namespace grafana &>/dev/null || kubectl create namespace grafana

# Desplegar Grafana en EKS
helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword="TuContraseña" \
    --set service.type=ClusterIP

# Verificar la instalación
kubectl get all -n grafana
