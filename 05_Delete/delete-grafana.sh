#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará completamente Grafana y todos sus recursos."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Desinstalar Grafana
echo "🛑 Eliminando Grafana..."
helm uninstall grafana --namespace grafana

# Eliminar el namespace de Grafana
echo "🛑 Eliminando namespace 'grafana'..."
kubectl delete namespace grafana --ignore-not-found

# Eliminar los PersistentVolumeClaims (PVC) asociados
echo "🛑 Eliminando volúmenes persistentes de Grafana..."
kubectl delete pvc --all -n grafana --ignore-not-found

# Verificar que todo fue eliminado
echo "✅ Verificando que Grafana fue eliminado correctamente..."
kubectl get all -n grafana
kubectl get pvc -n grafana

echo "✅ Eliminación completada."
