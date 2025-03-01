#!/bin/bash

# Variables
CLUSTER_NAME="mundosE-EKS-cluster-G1"
AWS_REGION="us-east-2"

# Set AWS credentials
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]
then
  echo "Credenciales testeadas, proceder con la creacion de cluster."

  # ✅ **Habilitar OIDC antes de la creación del clúster**
  eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=$CLUSTER_NAME --approve

  # Creación de cluster
  eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $AWS_REGION \
    --nodegroup-name ng-default \
    --node-type t2.small \
    --nodes 3 \
    --zones us-east-2a,us-east-2b \
    --managed

  if [ $? -eq 0 ]
  then
    echo "✅ Cluster Setup Completo con eksctl."

    # ✅ **Esperar unos segundos para estabilidad**
    sleep 30

    # ✅ **Actualizar todos los addons para evitar problemas de compatibilidad**
    eksctl update addon --name vpc-cni --cluster $CLUSTER_NAME --region $AWS_REGION --force
    eksctl update addon --name metrics-server --cluster $CLUSTER_NAME --region $AWS_REGION --force
    eksctl update addon --name kube-proxy --cluster $CLUSTER_NAME --region $AWS_REGION --force
    eksctl update addon --name coredns --cluster $CLUSTER_NAME --region $AWS_REGION --force

  else
    echo "❌ Cluster Setup Falló mientras se ejecuto eksctl."
  fi
else
  echo "❌ Error: AWS credentials no configuradas. Ejecuta 'aws configure' y verifica tu acceso."
fi
