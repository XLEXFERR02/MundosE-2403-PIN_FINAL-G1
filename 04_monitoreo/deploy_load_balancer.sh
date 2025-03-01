#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script creará un Classic Load Balancer para exponer Grafana y Prometheus."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando configuración."
  exit 1
fi

# Modificar el servicio de Grafana para exponerlo con LoadBalancer
echo "🛠️ Configurando Grafana con LoadBalancer..."
kubectl patch svc grafana -n grafana -p '{"spec": {"type": "LoadBalancer"}}'

# Modificar el servicio de Prometheus para exponerlo con LoadBalancer
echo "🛠️ Configurando Prometheus con LoadBalancer..."
kubectl patch svc prometheus-server -n prometheus -p '{"spec": {"type": "LoadBalancer"}}'

# Verificar que los servicios han sido actualizados
echo "✅ Verificando servicios..."
kubectl get svc -n grafana
kubectl get svc -n prometheus

echo "✅ Classic Load Balancer configurado correctamente. Espera unos minutos para que AWS asigne una IP externa."
