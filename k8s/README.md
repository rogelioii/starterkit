# Kubernetes Setup
Macbook: Use Docker Desktop with Kubernetes enabled.

# Example: Deploy a simple app
```bash
# Create cluster
kind create cluster --name dev

# Deploy nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Get service info
kubectl get services
```
