#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará completamente Nginx y su Load Balancer."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Eliminar el Deployment de Nginx
echo "🛑 Eliminando Nginx..."
kubectl delete deployment nginx-deployment -n nginx --ignore-not-found

# Eliminar el ConfigMap de configuración de Nginx
echo "🛑 Eliminando ConfigMap de Nginx..."
kubectl delete configmap nginx-config -n nginx --ignore-not-found

# Eliminar el Service de Nginx
echo "🛑 Eliminando servicio de Nginx..."
kubectl delete svc nginx-service -n nginx --ignore-not-found

# Eliminar el namespace de Nginx si no hay más recursos
echo "🛑 Eliminando namespace 'nginx' si está vacío..."
kubectl delete namespace nginx --ignore-not-found

# Verificar que todo fue eliminado
echo "✅ Verificando que Nginx fue eliminado correctamente..."
kubectl get all -n nginx

echo "✅ Eliminación completada."
