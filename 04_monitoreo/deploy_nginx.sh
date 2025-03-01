#!/bin/bash

# Confirmación antes de proceder
echo "⚠️ ATENCIÓN: Este script desplegará un pod Nginx con Exporter y lo expondrá externamente con un Load Balancer."
read -p "¿Estás seguro de que deseas continuar? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelando despliegue."
  exit 1
fi

# Crear el namespace si no existe
echo "🛠️ Creando namespace 'nginx'..."
kubectl get namespace nginx &>/dev/null || kubectl create namespace nginx

# Desplegar Nginx con Exporter en Kubernetes
echo "🛠️ Desplegando Nginx con Exporter..."
kubectl apply -n nginx -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      - name: nginx-exporter
        image: nginx/nginx-prometheus-exporter:latest
        args:
          - "-nginx.scrape-uri=http://localhost:80/stub_status"
        ports:
          - containerPort: 9113
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
EOF

# Crear ConfigMap para configurar Nginx con stub_status
echo "🛠️ Configurando Nginx para métricas..."
kubectl apply -n nginx -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 80;
        location / {
          root /usr/share/nginx/html;
          index index.html;
        }
        location /stub_status {
          stub_status;
          allow all;
        }
      }
    }
EOF

# Exponer Nginx externamente con un LoadBalancer
echo "🛠️ Creando LoadBalancer para Nginx..."
kubectl apply -n nginx -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - name: service
      nodePort: 30464 
      protocol: TCP
      port: 80
      targetPort: 80
    - name: service2 
      nodePort: 30465 
      protocol: TCP
      port: 9113
      targetPort: 9113
EOF

echo "✅ Despliegue completado. Verifica la IP externa del Load Balancer con:"
echo "kubectl get svc -n nginx"
