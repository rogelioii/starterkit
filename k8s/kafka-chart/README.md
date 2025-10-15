# Kafka Chart

A Helm chart for deploying Apache Kafka with Zookeeper, configured with Alpha and Beta queues.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume support

## Installation

```bash
# Add the chart repository (if using a repository)
helm repo add starterkit ./k8s/kafka-chart

# Install Kafka in the kafka namespace (creates namespace if it doesn't exist)
helm install kafka ./k8s/kafka-chart --create-namespace --namespace kafka

# Or with custom values
helm install kafka ./k8s/kafka-chart -f custom-values.yaml --create-namespace --namespace kafka

# Or install in a different namespace
helm install kafka ./k8s/kafka-chart --create-namespace --namespace my-kafka-namespace

# If namespace already exists, omit --create-namespace flag
helm install kafka ./k8s/kafka-chart --namespace kafka
```

## Configuration

### Default Topics

The chart automatically creates two topics:

- **alpha-queue**: 3 partitions, 3 replicas, 7-day retention
- **beta-queue**: 3 partitions, 3 replicas, 7-day retention

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace.create` | Create dedicated namespace | `true` |
| `namespace.name` | Namespace name | `kafka` |
| `replicaCount` | Number of Kafka brokers | `3` |
| `image.repository` | Kafka image repository | `confluentinc/cp-kafka` |
| `image.tag` | Kafka image tag | `7.4.0` |
| `kafka.topics.alpha-queue.partitions` | Alpha queue partitions | `3` |
| `kafka.topics.beta-queue.partitions` | Beta queue partitions | `3` |
| `persistence.enabled` | Enable persistent storage | `false` (for testing) |
| `persistence.size` | Storage size per pod | `10Gi` |

### Example Custom Values

```yaml
replicaCount: 5

kafka:
  topics:
    alpha-queue:
      partitions: 10
      replicationFactor: 3
      config:
        retention.ms: "86400000"  # 1 day
    beta-queue:
      partitions: 5
      replicationFactor: 3
      config:
        retention.ms: "604800000"  # 7 days

persistence:
  size: 50Gi
  storageClass: "fast-ssd"

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi
```

## Usage

### Connecting to Kafka

```bash
# Get Kafka service details (specify namespace)
kubectl get svc -n kafka

# Port forward for local access
kubectl port-forward svc/kafka 9092:9092 -n kafka

# Test connection
kafka-console-producer --bootstrap-server localhost:9092 --topic alpha-queue
kafka-console-consumer --bootstrap-server localhost:9092 --topic alpha-queue --from-beginning
```

### Using Kafka from Applications

```yaml
# In your application deployment
env:
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: "kafka-headless.kafka.svc.cluster.local:9092"
```

### Topic Management

```bash
# List topics
kubectl exec -it kafka-0 -n kafka -- kafka-topics --bootstrap-server localhost:9092 --list

# Create additional topics
kubectl exec -it kafka-0 -n kafka -- kafka-topics --bootstrap-server localhost:9092 \
  --create --topic my-topic --partitions 3 --replication-factor 3

# Describe topic
kubectl exec -it kafka-0 -n kafka -- kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic alpha-queue
```

## Architecture

### Components

- **Kafka StatefulSet**: 3 Kafka brokers with persistent storage
- **Zookeeper StatefulSet**: 3 Zookeeper nodes for coordination
- **Services**: Headless services for internal communication, ClusterIP for external access
- **ConfigMaps**: Kafka and Zookeeper configuration
- **PersistentVolumes**: Data persistence for both Kafka and Zookeeper

### Network Topology

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kafka-0       │    │   Kafka-1       │    │   Kafka-2       │
│   Port: 9092    │    │   Port: 9092    │    │   Port: 9092    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
         │  Zookeeper-0    │    │  Zookeeper-1    │    │  Zookeeper-2    │
         │  Port: 2181     │    │  Port: 2181     │    │  Port: 2181     │
         └─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Monitoring

### Health Checks

- **Liveness Probe**: Kafka broker API version check
- **Readiness Probe**: Kafka broker API version check
- **Zookeeper Health**: `ruok` command check

### Metrics (Optional)

Enable monitoring by setting:

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
```

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check persistent volume claims
2. **Topics not created**: Check init container logs
3. **Connection refused**: Verify service endpoints

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=kafka-chart -n kafka

# Check logs
kubectl logs kafka-0 -c kafka -n kafka
kubectl logs kafka-0 -c create-topics -n kafka

# Check services
kubectl get svc -l app.kubernetes.io/name=kafka-chart -n kafka

# Check persistent volumes
kubectl get pvc -l app.kubernetes.io/name=kafka-chart -n kafka
```

## Scaling

```bash
# Scale Kafka brokers
kubectl scale statefulset kafka --replicas=5 -n kafka

# Scale Zookeeper (not recommended to change)
kubectl scale statefulset kafka-zookeeper --replicas=3 -n kafka
```

## Uninstallation

```bash
helm uninstall kafka -n kafka
```

**Note**: This will delete all Kafka data. Backup important topics before uninstalling.

## Security Considerations

- Currently configured for PLAINTEXT communication
- For production, consider:
  - SASL/SSL authentication
  - TLS encryption
  - Network policies
  - RBAC configuration
