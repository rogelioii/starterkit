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

# External Secrets How To
## Install External Secrets Operator
```
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace
```

## Set up SecretStore
```
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
  namespace: default
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: your-service-account-with-IRSA
```

## Define the ExternalSecret
```
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-ecr-secret
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: my-ecr-secret
    template:
      type: kubernetes.io/dockerconfigjson
  data:
    - secretKey: .dockerconfigjson
      remoteRef:
        key: my-ecr-secret
```

The value of my-ecr-secret in SecretsManager must be valid .dockerconfigjson content
```
{
  "auths": {
    "123456789012.dkr.ecr.us-east-1.amazonaws.com": {
      "username": "AWS",
      "password": "your-ecr-token",
      "email": "you@example.com",
      "auth": "base64(username:password)"
    }
  }
}
```

## Use the ExternalSecret
```
imagePullSecrets:
  - name: my-ecr-secret
```