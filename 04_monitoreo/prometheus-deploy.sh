#!/bin/bash

# Verificar si los repositorios de Helm están configurados
if ! helm repo list | grep -q prometheus-community; then
  echo "🛠️ Agregando repositorio de Prometheus..."
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
fi

if ! helm repo list | grep -q grafana; then
  echo "🛠️ Agregando repositorio de Grafana..."
  helm repo add grafana https://grafana.github.io/helm-charts
fi

# Actualizar repositorios
helm repo update

# ✅ **Instalar el AWS EBS CSI Driver si no está presente**
eksctl create addon --name aws-ebs-csi-driver --cluster mundosE-EKS-cluster-G1 --region us-east-2 --force

# ✅ **Asegurar que gp2 sea la StorageClass por defecto**
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Crear el namespace para Prometheus si no existe
kubectl get namespace prometheus &>/dev/null || kubectl create namespace prometheus

# Desplegar Prometheus en EKS
helm install prometheus prometheus-community/prometheus \
  --namespace prometheus \
  --set alertmanager.persistentVolume.storageClass="gp2" \
  --set server.persistentVolume.storageClass="gp2"

# Verificar la instalación
kubectl get all -n prometheus

# Exponer Prometheus en la instancia de EC2 en el puerto 8080
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090 --address 0.0.0.0
