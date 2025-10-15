# PostgreSQL Helm Chart

This Helm chart deploys a PostgreSQL database using the official PostgreSQL Docker image as a StatefulSet for better data persistence and stable network identity.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PersistentVolume provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-postgres`:

```bash
helm install my-postgres ./postgres-chart
```

The command deploys PostgreSQL on the Kubernetes cluster with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-postgres` deployment:

```bash
helm uninstall my-postgres
```

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `nameOverride`            | String to partially override postgres-chart.fullname template with a string will prepend the release name | `""` |
| `fullnameOverride`        | String to fully override postgres-chart.fullname template with a string | `""` |

### PostgreSQL parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `postgresql.database`     | PostgreSQL database name                        | `starterkit` |
| `postgresql.username`     | PostgreSQL username                             | `starterkit` |
| `postgresql.password`     | PostgreSQL password                             | `starterkit123` |
| `postgresql.initdbArgs`   | PostgreSQL initdb arguments                     | `--encoding=UTF-8 --lc-collate=C --lc-ctype=C` |

### Image parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `image.repository`       | PostgreSQL image repository                     | `postgres` |
| `image.tag`               | PostgreSQL image tag (immutable tags are recommended) | `15-alpine` |
| `image.pullPolicy`        | PostgreSQL image pull policy                    | `IfNotPresent` |

### Service parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `service.type`            | PostgreSQL service type                         | `ClusterIP` |
| `service.port`            | PostgreSQL service port                         | `5432` |

### Persistence parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `persistence.enabled`     | Enable persistence using PVC                    | `true` |
| `persistence.storageClass` | PVC storage class for PostgreSQL volume        | `""` |
| `persistence.accessMode`  | PVC access mode for PostgreSQL volume          | `ReadWriteOnce` |
| `persistence.size`        | PVC storage size for PostgreSQL volume         | `10Gi` |

### Resource parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `resources.limits.cpu`     | CPU resource limits                             | `500m` |
| `resources.limits.memory` | Memory resource limits                          | `512Mi` |
| `resources.requests.cpu`  | CPU resource requests                           | `250m` |
| `resources.requests.memory` | Memory resource requests                       | `256Mi` |

## Configuration and installation details

### PostgreSQL Configuration

The chart includes a ConfigMap with PostgreSQL configuration parameters that can be customized in the `values.yaml` file under `postgresql.postgresqlConf`.

### Database Initialization

The PostgreSQL container will automatically create the database and user specified in the values. The initialization arguments can be customized using the `postgresql.initdbArgs` parameter.

### Health Checks

Health checks are enabled by default and can be configured using the `postgresql.healthcheck` parameters in `values.yaml`.

### Security

The chart creates a Secret to store PostgreSQL credentials. The password should be changed in production environments.

## Examples

### Install with custom values

```bash
helm install my-postgres ./postgres-chart \
  --set postgresql.database=myapp \
  --set postgresql.username=myuser \
  --set postgresql.password=mypassword \
  --set persistence.size=20Gi
```

### Install with custom values file

```bash
helm install my-postgres ./postgres-chart -f custom-values.yaml
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -l app.kubernetes.io/name=postgres-chart
```

### Check logs
```bash
kubectl logs -l app.kubernetes.io/name=postgres-chart
```

### Connect to PostgreSQL
```bash
kubectl exec -it <pod-name> -- psql -U starterkit -d starterkit
```

### Check persistent volume
```bash
kubectl get pvc -l app.kubernetes.io/name=postgres-chart
```

### StatefulSet Benefits

This chart uses a StatefulSet instead of a Deployment for PostgreSQL because:

- **Stable network identity**: Each pod gets a predictable hostname (`postgres-chart-0`)
- **Ordered deployment**: Pods are created/deleted in order (important for databases)
- **Stable persistent storage**: Each pod gets its own persistent volume that persists across pod restarts
- **Better for databases**: Maintains data consistency and proper startup/shutdown order

The StatefulSet automatically creates PVCs using the `volumeClaimTemplates` section, so you don't need to manually create PVCs.
