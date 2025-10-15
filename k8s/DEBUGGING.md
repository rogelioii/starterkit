# Kubernetes Troubleshooting Commands

This document provides a comprehensive list of kubectl commands for troubleshooting Kubernetes applications and clusters.

## Basic Resource Inspection

### Pod Commands
```bash
# List all pods in the current namespace
kubectl get pods
# Shows pod status, restart counts, and age

# List pods across all namespaces
kubectl get pods --all-namespaces
# Useful for cluster-wide pod visibility

# Get detailed pod information
kubectl describe pod <pod-name>
# Shows events, conditions, volumes, and detailed pod spec

# Get pod logs
kubectl logs <pod-name>
# Shows current logs from the pod

# Get logs from previous container instance
kubectl logs <pod-name> --previous
# Useful when pod crashed and restarted

# Follow logs in real-time
kubectl logs -f <pod-name>
# Streams logs as they're generated

# Get logs from specific container in multi-container pod
kubectl logs <pod-name> -c <container-name>
# When pod has multiple containers

# Get pod YAML configuration
kubectl get pod <pod-name> -o yaml
# Shows complete pod specification
```

### Service Commands
```bash
# List all services
kubectl get services
# Shows service types, cluster IPs, and external IPs

# Describe service details
kubectl describe service <service-name>
# Shows endpoints, selector, and port mappings

# Get service endpoints
kubectl get endpoints <service-name>
# Shows which pods are backing the service
```

### Deployment Commands
```bash
# List deployments
kubectl get deployments
# Shows desired vs current replicas and rollout status

# Describe deployment
kubectl describe deployment <deployment-name>
# Shows rollout history, events, and pod template

# Get deployment rollout history
kubectl rollout history deployment/<deployment-name>
# Shows previous revisions and their configurations

# Get rollout status
kubectl rollout status deployment/<deployment-name>
# Shows current rollout progress

# Rollback to previous version
kubectl rollout undo deployment/<deployment-name>
# Reverts to previous deployment revision
```

## Advanced Debugging

### Resource Status and Events
```bash
# Get all events in namespace
kubectl get events --sort-by=.metadata.creationTimestamp
# Shows chronological events that can indicate issues

# Get events for specific resource
kubectl get events --field-selector involvedObject.name=<pod-name>
# Shows events related to specific pod

# Get resource utilization
kubectl top pods
# Shows CPU and memory usage (requires metrics-server)

# Get node resource utilization
kubectl top nodes
# Shows cluster node resource usage
```

### Network Debugging
```bash
# Test connectivity from pod
kubectl exec <pod-name> -- curl <service-url>
# Tests network connectivity from within cluster

# Port forward to pod
kubectl port-forward <pod-name> <local-port>:<pod-port>
# Creates local tunnel to pod for testing

# Port forward to service
kubectl port-forward service/<service-name> <local-port>:<service-port>
# Creates tunnel to service

# Get network policies
kubectl get networkpolicies
# Shows network policies that might block traffic
```

### Storage Debugging
```bash
# List persistent volumes
kubectl get pv
# Shows available persistent volumes

# List persistent volume claims
kubectl get pvc
# Shows PVC status and bindings

# Describe persistent volume claim
kubectl describe pvc <pvc-name>
# Shows detailed PVC information and events

# List storage classes
kubectl get storageclass
# Shows available storage classes
```

## Interactive Debugging

### Pod Execution
```bash
# Execute command in pod
kubectl exec <pod-name> -- <command>
# Runs command in pod container

# Get interactive shell in pod
kubectl exec -it <pod-name> -- /bin/bash
# Opens bash shell in pod (or /bin/sh if bash unavailable)

# Execute command in specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash
# For multi-container pods
```

### Debug Pods
```bash
# Create debug pod with busybox
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- /bin/sh
# Creates temporary pod for debugging network/storage

# Create debug pod in same node
kubectl debug <pod-name> -it --image=busybox --target=<container-name>
# Creates debug container in same pod (requires kubectl debug plugin)
```

## Configuration and Secrets

### ConfigMap and Secrets
```bash
# List configmaps
kubectl get configmaps
# Shows available configuration maps

# Describe configmap
kubectl describe configmap <configmap-name>
# Shows configmap data and usage

# List secrets
kubectl get secrets
# Shows available secrets

# Describe secret
kubectl describe secret <secret-name>
# Shows secret metadata (not actual values)

# Decode secret value
kubectl get secret <secret-name> -o jsonpath='{.data.<key>}' | base64 -d
# Decodes base64 encoded secret values
```

## Resource Management

### Scaling and Updates
```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=<number>
# Changes replica count

# Update deployment image
kubectl set image deployment/<deployment-name> <container-name>=<new-image>
# Updates container image

# Restart deployment
kubectl rollout restart deployment/<deployment-name>
# Restarts all pods in deployment
```

### Resource Quotas and Limits
```bash
# Get resource quotas
kubectl get resourcequotas
# Shows namespace resource limits

# Describe resource quota
kubectl describe resourcequota <quota-name>
# Shows detailed quota usage

# Get limit ranges
kubectl get limitranges
# Shows resource limits for namespace
```

## Cluster Information

### Node and Cluster Status
```bash
# Get cluster nodes
kubectl get nodes
# Shows node status and roles

# Describe node
kubectl describe node <node-name>
# Shows node resources, conditions, and events

# Get cluster info
kubectl cluster-info
# Shows cluster endpoints and services

# Get API versions
kubectl api-versions
# Shows available API versions

# Get API resources
kubectl api-resources
# Shows all available resource types
```

## Troubleshooting Workflow

### Common Debugging Steps
1. **Check pod status**: `kubectl get pods` and `kubectl describe pod <pod-name>`
2. **Check logs**: `kubectl logs <pod-name>` and `kubectl logs <pod-name> --previous`
3. **Check events**: `kubectl get events --sort-by=.metadata.creationTimestamp`
4. **Check service connectivity**: `kubectl get svc` and `kubectl describe svc <service-name>`
5. **Test network**: `kubectl exec <pod-name> -- curl <service-url>`
6. **Check resource usage**: `kubectl top pods` and `kubectl top nodes`
7. **Verify configuration**: `kubectl get configmaps` and `kubectl get secrets`

### Quick Health Check Script
```bash
#!/bin/bash
# Quick cluster health check
echo "=== Pod Status ==="
kubectl get pods --all-namespaces | grep -v Running

echo "=== Recent Events ==="
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp | tail -10

echo "=== Node Status ==="
kubectl get nodes

echo "=== Resource Usage ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
```

## Useful Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'
```
