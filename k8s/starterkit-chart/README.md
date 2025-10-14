# Starterkit Chart

This is a Helm chart for the starterkit application.

## Usage

```bash
# Install the chart
helm install starterkit ./k8s/starterkit-chart

# Install with custom values
helm install starterkit ./k8s/starterkit-chart --set replicaCount=3

# Enable ingress
helm install starterkit ./k8s/starterkit-chart --set ingress.enabled=true

# Upgrade
helm upgrade starterkit ./k8s/starterkit-chart

# Uninstall
helm uninstall starterkit
```