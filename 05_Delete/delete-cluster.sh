#!/bin/bash
# Variables
CLUSTER_NAME="mundosE-EKS-cluster-G1"
AWS_REGION="us-east-2"

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script eliminará TODOS los recursos asociados al clúster $CLUSTER_NAME."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando eliminación."
  exit 1
fi

# Eliminar el clúster EKS y los nodos
echo "🛑 Eliminando el clúster EKS..."
eksctl delete cluster --name $CLUSTER_NAME --region $AWS_REGION

# Esperar a que AWS actualice el estado del clúster
echo "⌛ Esperando a que el clúster sea completamente eliminado..."
sleep 90  # Espera de 1.5 minutos para asegurar la eliminación

# Verificar si el clúster fue eliminado completamente
eksctl get cluster --name $CLUSTER_NAME --region $AWS_REGION &> /dev/null
if [[ $? -eq 0 ]]; then
  echo "❌ Error: El clúster aún existe. Revisa manualmente."
else
  echo "✅ Clúster eliminado exitosamente."
fi

# Verificar si el clúster sigue existiendo antes de eliminar la cuenta de servicio IAM
eksctl get cluster --name $CLUSTER_NAME --region $AWS_REGION &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "🛑 Eliminando la cuenta de servicio IAM de vpc-cni..."
  eksctl delete iamserviceaccount \
    --name amazon-vpc-cni \
    --namespace kube-system \
    --cluster $CLUSTER_NAME
  echo "✅ Eliminación de la cuenta de servicio completada."
else
  echo "⚠️ El clúster aún no ha sido eliminado completamente. Intenta eliminar la cuenta de servicio más tarde."
fi

echo "✅ Eliminación de recursos completada."
