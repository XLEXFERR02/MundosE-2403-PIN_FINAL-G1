#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará completamente Prometheus y todos sus recursos."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Desinstalar Prometheus
echo "🛑 Eliminando Prometheus..."
helm uninstall prometheus --namespace prometheus

# Eliminar el namespace de Prometheus
echo "🛑 Eliminando namespace 'prometheus'..."
kubectl delete namespace prometheus --ignore-not-found

# Eliminar los PersistentVolumeClaims (PVC) asociados
echo "🛑 Eliminando volúmenes persistentes de Prometheus..."
kubectl delete pvc --all -n prometheus --ignore-not-found

# Verificar que todo fue eliminado
echo "✅ Verificando que Prometheus fue eliminado correctamente..."
kubectl get all -n prometheus
kubectl get pvc -n prometheus

echo "✅ Eliminación completada."
