#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará los Load Balancers de Prometheus, Grafana y Nginx."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Eliminar LoadBalancer de Grafana
echo "🛑 Eliminando LoadBalancer de Grafana..."
kubectl delete svc grafana -n grafana --ignore-not-found

# Eliminar LoadBalancer de Prometheus
echo "🛑 Eliminando LoadBalancer de Prometheus..."
kubectl delete svc prometheus-server -n prometheus --ignore-not-found

# Eliminar LoadBalancer de Nginx
echo "🛑 Eliminando LoadBalancer de Nginx..."
kubectl delete svc nginx-service -n nginx --ignore-not-found

# Verificar que todo fue eliminado
echo "✅ Verificando que los Load Balancers fueron eliminados..."
kubectl get svc -A | grep LoadBalancer || echo "No hay Load Balancers activos."

echo "✅ Eliminación completada."
