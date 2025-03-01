#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará todos los Persistent Volumes (PV) y Persistent Volume Claims (PVC) en el clúster."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Eliminar todos los Persistent Volume Claims (PVC)
echo "🛑 Eliminando Persistent Volume Claims (PVC)..."
kubectl delete pvc --all --all-namespaces --ignore-not-found

# Eliminar todos los Persistent Volumes (PV)
echo "🛑 Eliminando Persistent Volumes (PV)..."
kubectl delete pv --all --ignore-not-found

# Verificar que todo fue eliminado
echo "✅ Verificando que los volúmenes persistentes fueron eliminados..."
kubectl get pv
kubectl get pvc --all-namespaces

echo "✅ Eliminación completada."
