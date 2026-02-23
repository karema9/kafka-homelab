# Kafka KRaft Cluster with Prometheus & Grafana Monitoring

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Configuration Details](#configuration-details)
- [Accessing Services](#accessing-services)
- [Monitoring & Metrics](#monitoring--metrics)
- [Operating the Cluster](#operating-the-cluster)
- [Troubleshooting](#troubleshooting)
- [Maintenance & Operations](#maintenance--operations)
- [Appendix](#appendix)

---

## Overview

This documentation provides comprehensive guidance for deploying and operating a development Apache Kafka cluster running in KRaft mode (Kafka Raft - without Zookeeper) with full observability through Prometheus and Grafana.

### Key Features

- **KRaft Mode**: Runs without Zookeeper, using Kafka's native Raft consensus protocol
- **High Availability**: 3-node cluster with replication factor of 3
- **Full Observability**: JMX metrics exported to Prometheus and visualized in Grafana
- **Containerized**: All services run in Docker containers with Docker Compose
- **Web UI**: Kafka UI for easy cluster management and topic administration

### Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Apache Kafka | 7.8.0 (Confluent) | Message broker and streaming platform |
| Prometheus | Latest | Metrics collection and storage |
| Grafana | Latest | Metrics visualization and dashboards |
| Kafka UI | Latest | Web-based Kafka management interface |
| JMX Exporter | 0.20.0 | JMX to Prometheus metrics bridge |

---

## Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Docker Network                          │
│                        (kafka-network)                          │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ kafka-node1  │  │ kafka-node2  │  │ kafka-node3  │           │
│  │              │  │              │  │              │           │
│  │ Port: 9092   │  │ Port: 9092   │  │ Port: 9092   │           │
│  │ JMX:  7071   │  │ JMX:  7071   │  │ JMX:  7071   │           │
│  │ Raft: 9093   │  │ Raft: 9093   │  │ Raft: 9093   │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                   │
│         └─────────────────┴─────────────────┘                   │
│                          │                                      │
│         ┌────────────────┴────────────────┐                     │
│         │                                 │                     │
│    ┌────▼─────┐                    ┌─────▼──────┐               │
│    │ Kafka UI │                    │ Prometheus │               │
│    │          │                    │            │               │
│    │ Port:    │                    │ Port: 9090 │               │
│    │ 8080     │                    │ (Internal) │               │
│    └──────────┘                    └─────┬──────┘               │
│                                           │                     │
│                                     ┌─────▼──────┐              │
│                                     │  Grafana   │              │
│                                     │            │              │
│                                     │ Port: 3000 │              │
│                                     └────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                          │
                          │ Port Mappings
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Host Machine                            │
│                                                                 │
│  localhost:9192 → kafka-node1:9092                              │
│  localhost:9194 → kafka-node2:9092                              │
│  localhost:9196 → kafka-node3:9092                              │
│  localhost:8080 → kafka-ui:8080                                 │
│  localhost:9190 → prometheus:9090                               │
│  localhost:3000 → grafana:3000                                  │
└─────────────────────────────────────────────────────────────────┘
```

### KRaft Consensus

```
┌─────────────────────────────────────────────────────────────┐
│                    KRaft Quorum                             │
│                                                             │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐           │
│  │  Node 1  │      │  Node 2  │      │  Node 3  │           │
│  │ (Voter)  │◄────►│ (Voter)  │◄────►│ (Leader) │           │
│  └──────────┘      └──────────┘      └──────────┘           │
│                                                             │
│  • All nodes participate in consensus                       │
│  • One node elected as active controller                    │
│  • Minimum 2 nodes required for quorum                      │
│  • Metadata replicated across all nodes                     │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
Producer                    Kafka Cluster                  Consumer
   │                             │                             │
   │  1. Send Message            │                             │
   ├────────────────────────────►│                             │
   │                             │                             │
   │  2. Replicate to followers  │                             │
   │                        ┌────┴────┐                        │
   │                        │ Node 1  │                        │
   │                        │ Node 2  │                        │
   │                        │ Node 3  │                        │
   │                        └────┬────┘                        │
   │  3. Acknowledge             │                             │
   │◄────────────────────────────┤                             │
   │                             │  4. Fetch Messages          │
   │                             │◄────────────────────────────┤
   │                             │                             │
   │                             │  5. Return Messages         │
   │                             ├────────────────────────────►│
```

---

## Prerequisites

### System Requirements

**Minimum Requirements:**
- CPU: 4 cores
- RAM: 8 GB
- Disk: 20 GB free space
- OS: Linux, macOS, or Windows with WSL2

**Recommended:**
- CPU: 8 cores
- RAM: 16 GB
- Disk: 50 GB SSD
- OS: Linux (Ubuntu 20.04+ / RHEL 8+)

### Software Dependencies

- Docker Engine 20.10+
- Docker Compose 2.0+
- curl (for testing)
- jq (optional, for JSON parsing)

### Installation Verification

```bash
# Check Docker version
docker --version
# Expected: Docker version 20.10.0 or higher

# Check Docker Compose version
docker-compose --version
# Expected: Docker Compose version 2.0.0 or higher

# Verify Docker is running
docker ps
# Should return an empty list or running containers
```

---

## Installation & Setup

### Step 1: Project Structure

Create the following directory structure:

```
kafka-cluster/
├── configs/
│   ├── jmx/
│   │   ├── jmx_prometheus_javaagent.jar
│   │   └── kafka_config.yml
│   └── prometheus/
│       └── prometheus.yml
├── docker-compose.yml
├── kafka-node1/
│   └── data/
├── kafka-node2/
│   └── data/
└── kafka-node3/
    └── data/
```

**Create directories:**

```bash
mkdir -p kafka-cluster/{configs/{jmx,prometheus},kafka-node{1,2,3}/data}
cd kafka-cluster
```

### Step 2: Download JMX Exporter

```bash
# Download JMX Prometheus Java Agent
curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar \
  -o configs/jmx/jmx_prometheus_javaagent.jar

# Verify download
ls -lh configs/jmx/jmx_prometheus_javaagent.jar
```

### Step 3: Create Configuration Files

#### JMX Exporter Configuration

Create `configs/jmx/kafka_config.yml`:

```yaml
lowercaseOutputName: true
lowercaseOutputLabelNames: true

rules:
  # Broker Topic Metrics
  - pattern: 'kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec|MessagesInPerSec), topic=(.+)><>Count'
    name: kafka_topic_$1_total
    labels:
      topic: "$2"

  - pattern: 'kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec|MessagesInPerSec)><>Count'
    name: kafka_cluster_$1_total

  # Request Metrics
  - pattern: 'kafka.network<type=RequestMetrics, name=RequestsPerSec, request=(Produce|FetchConsumer|FetchFollower)><>Count'
    name: kafka_request_$1_total

  # Log Size
  - pattern: 'kafka.log<type=Log, name=Size, topic=(.+), partition=(\d+)><>Value'
    name: kafka_topic_partition_log_size_bytes
    labels:
      topic: "$1"
      partition: "$2"

  # Cluster Health
  - pattern: 'kafka.server<type=ReplicaManager, name=UnderReplicatedPartitions><>Value'
    name: kafka_under_replicated_partitions

  - pattern: 'kafka.server<type=ReplicaManager, name=(IsrShrinksPerSec|IsrExpandsPerSec)><>Count'
    name: kafka_$1_total

  # Controller Metrics
  - pattern: 'kafka.controller<type=KafkaController, name=(ActiveControllerCount|OfflinePartitionsCount)><>Value'
    name: kafka_controller_$1

  - pattern: 'kafka.raft<type=KafkaRaftMetrics, name=(LeaderCount|UncommittedEntries)><>Value'
    name: kafka_raft_$1

  # JVM Metrics
  - pattern: 'java.lang<type=Memory><>HeapMemoryUsage.used'
    name: jvm_heap_used_bytes

  - pattern: 'java.lang<type=Threading><>ThreadCount'
    name: jvm_threads

  - pattern: 'java.lang<type=GarbageCollector, name=(.+)><>CollectionTime'
    name: jvm_gc_collection_time_ms
    labels:
      gc: "$1"
```

#### Prometheus Configuration

Create `configs/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "prometheus:9090"

  - job_name: "kafka-brokers"
    static_configs:
      - targets:
          - "kafka-node1:7071"
          - "kafka-node2:7071"
          - "kafka-node3:7071"
    relabel_configs:
      - source_labels: [__address__]
        regex: "(kafka-node[0-9]+):7071"
        target_label: kafka_broker
        replacement: "$1"

  - job_name: "kafka-jvm"
    static_configs:
      - targets:
          - "kafka-node1:7071"
          - "kafka-node2:7071"
          - "kafka-node3:7071"
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: "jvm_.*|process_.*"
        action: keep
```

#### Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

networks:
  kafka-network:
    driver: bridge

volumes:
  grafana_data:
  kafka-node1-data:
  kafka-node2-data:
  kafka-node3-data:

x-service-defaults: &service_defaults
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

x-kafka-service: &kafka_service
  image: confluentinc/cp-kafka:7.8.0
  networks:
    - kafka-network
  healthcheck:
    test: ["CMD-SHELL", "unset KAFKA_OPTS; kafka-broker-api-versions --bootstrap-server localhost:9092"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s

x-kafka-env: &kafka_env
  KAFKA_PROCESS_ROLES: 'broker,controller'
  KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: 'CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT'
  KAFKA_CONTROLLER_LISTENER_NAMES: 'CONTROLLER'
  KAFKA_INTER_BROKER_LISTENER_NAME: 'PLAINTEXT'
  KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
  KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
  KAFKA_DEFAULT_REPLICATION_FACTOR: 3
  KAFKA_MIN_INSYNC_REPLICAS: 2
  KAFKA_JMX_PORT: 9101
  KAFKA_JMX_HOSTNAME: localhost
  CLUSTER_ID: '33a278a3-4856-4046-b151-6b6044f43b1b'
  KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_LOG_RETENTION_HOURS: 168
  KAFKA_OPTS: "-javaagent:/usr/share/jmx_exporter/jmx_prometheus_javaagent.jar=7071:/usr/share/jmx_exporter/kafka_config.yml"

services:
  kafka-node1:
    <<: [*service_defaults, *kafka_service]
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - "9192:9092"
      - "9193:9093"
    environment:
      <<: *kafka_env
      KAFKA_NODE_ID: 1
      KAFKA_LISTENERS: "PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://kafka-node1:9092"
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node1-data:/var/lib/kafka/data
      - ./configs/jmx/jmx_prometheus_javaagent.jar:/usr/share/jmx_exporter/jmx_prometheus_javaagent.jar
      - ./configs/jmx/kafka_config.yml:/usr/share/jmx_exporter/kafka_config.yml

  kafka-node2:
    <<: [*service_defaults, *kafka_service]
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - "9194:9092"
      - "9195:9093"
    environment:
      <<: *kafka_env
      KAFKA_NODE_ID: 2
      KAFKA_LISTENERS: "PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://kafka-node2:9092"
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node2-data:/var/lib/kafka/data
      - ./configs/jmx/jmx_prometheus_javaagent.jar:/usr/share/jmx_exporter/jmx_prometheus_javaagent.jar
      - ./configs/jmx/kafka_config.yml:/usr/share/jmx_exporter/kafka_config.yml

  kafka-node3:
    <<: [*service_defaults, *kafka_service]
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - "9196:9092"
      - "9197:9093"
    environment:
      <<: *kafka_env
      KAFKA_NODE_ID: 3
      KAFKA_LISTENERS: "PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://kafka-node3:9092"
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node3-data:/var/lib/kafka/data
      - ./configs/jmx/jmx_prometheus_javaagent.jar:/usr/share/jmx_exporter/jmx_prometheus_javaagent.jar
      - ./configs/jmx/kafka_config.yml:/usr/share/jmx_exporter/kafka_config.yml

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-cluster-ui
    ports:  
      - "8080:8080"
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka-node1:9092,kafka-node2:9092,kafka-node3:9092
    depends_on:
      kafka-node1:
        condition: service_healthy
      kafka-node2:
        condition: service_healthy
      kafka-node3:
        condition: service_healthy
    networks:
      - kafka-network

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9190:9090"
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    volumes:
      - ./configs/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - kafka-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      prometheus:
        condition: service_healthy
    networks:
      - kafka-network
```

### Step 4: Start the Cluster

```bash
# Start all services
docker-compose up -d

# Monitor startup logs
docker-compose logs -f kafka-node1 kafka-node2 kafka-node3

# Wait for healthy status (look for these messages):
# - "High watermark set to..."
# - "Becoming the active controller..."
# - "Transition from STARTING to STARTED"

# Verify all services are running
docker-compose ps
```

Expected output:
```
NAME                IMAGE                              STATUS
kafka-node1         confluentinc/cp-kafka:7.8.0       Up (healthy)
kafka-node2         confluentinc/cp-kafka:7.8.0       Up (healthy)
kafka-node3         confluentinc/cp-kafka:7.8.0       Up (healthy)
kafka-cluster-ui    provectuslabs/kafka-ui:latest     Up (healthy)
prometheus          prom/prometheus:latest            Up (healthy)
grafana             grafana/grafana:latest            Up (healthy)
```

---

## Configuration Details

### Network Configuration

**Internal Docker Network:**
- Name: `kafka-network`
- Driver: `bridge`
- Subnet: Auto-assigned by Docker

**Port Mappings:**

| Service | Container Port | Host Port | Purpose |
|---------|---------------|-----------|---------|
| kafka-node1 | 9092 | 9192 | Kafka broker |
| kafka-node1 | 9093 | 9193 | KRaft controller |
| kafka-node2 | 9092 | 9194 | Kafka broker |
| kafka-node2 | 9093 | 9195 | KRaft controller |
| kafka-node3 | 9092 | 9196 | Kafka broker |
| kafka-node3 | 9093 | 9197 | KRaft controller |
| prometheus | 9090 | 9190 | Prometheus UI |
| grafana | 3000 | 3000 | Grafana UI |
| kafka-ui | 8080 | 8080 | Kafka UI |

### Kafka Configuration

**Key Settings:**

```yaml
KAFKA_PROCESS_ROLES: 'broker,controller'
# Each node acts as both broker and controller

KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
# Consumer offset topic replicated 3 times

KAFKA_DEFAULT_REPLICATION_FACTOR: 3
# Default replication for new topics

KAFKA_MIN_INSYNC_REPLICAS: 2
# Minimum replicas that must acknowledge writes

KAFKA_LOG_RETENTION_HOURS: 168
# Keep messages for 7 days

KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
# JVM heap size (1GB initial and maximum)
```

### Volume Mounts

**Persistent Data:**
- `kafka-node1-data`: Stores Kafka logs and metadata for node 1
- `kafka-node2-data`: Stores Kafka logs and metadata for node 2
- `kafka-node3-data`: Stores Kafka logs and metadata for node 3
- `grafana_data`: Stores Grafana dashboards and settings

**Configuration Files:**
- `./configs/jmx/jmx_prometheus_javaagent.jar`: JMX exporter Java agent
- `./configs/jmx/kafka_config.yml`: JMX metric export rules
- `./configs/prometheus/prometheus.yml`: Prometheus scrape configuration

---

## Accessing Services

### Kafka UI

**URL:** `http://localhost:8080`

**Features:**
- Browse topics, partitions, and consumer groups
- Produce and consume messages
- View broker configurations
- Monitor cluster health

**Screenshots:**

```
┌─────────────────────────────────────────────────┐
│ Kafka UI Dashboard                              │
├─────────────────────────────────────────────────┤
│                                                 │
│  Cluster: local                    ✓ Connected  │
│                                                 │
│  Brokers: 3                Topics: 0            │
│  Partitions: 0             Consumer Groups: 0   │
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │ Topics        Brokers      Consumers     │   │
│  ├──────────────────────────────────────────┤   │
│  │ __consumer_offsets                       │   │
│  │ __cluster_metadata                       │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### Prometheus

**URL:** `http://localhost:9190`

**Targets:** `http://localhost:9190/targets`

**Useful Queries:**
```promql
# Cluster message rate
rate(kafka_cluster_messagesinpersec_total[5m])

# Under-replicated partitions
kafka_under_replicated_partitions

# JVM heap usage
jvm_heap_used_bytes / 1024 / 1024 / 1024
```

### Grafana

**URL:** `http://localhost:3000`

**Default Credentials:**
- Username: `admin`
- Password: `admin`

**Initial Setup:**

1. **Add Prometheus Data Source:**
   - Navigate to: Connections → Data sources
   - Click: Add data source
   - Select: Prometheus
   - URL: `http://prometheus:9090`
   - Click: Save & Test

2. **Import Dashboard:**
   - Navigate to: Dashboards → New → Import
   - Enter Dashboard ID: `7589` or `11962`
   - Select: Prometheus data source
   - Click: Import

---

## Monitoring & Metrics

### Key Metrics to Monitor

#### Cluster Health

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `kafka_controller_ActiveControllerCount` | Number of active controllers | Should = 1 |
| `kafka_under_replicated_partitions` | Partitions not fully replicated | Should = 0 |
| `kafka_controller_OfflinePartitionsCount` | Partitions without leader | Should = 0 |

#### Performance Metrics

| Metric | Description | Query |
|--------|-------------|-------|
| Message Rate | Messages per second | `rate(kafka_cluster_messagesinpersec_total[5m])` |
| Byte Rate In | Bytes in per second | `rate(kafka_cluster_bytesinpersec_total[5m])` |
| Byte Rate Out | Bytes out per second | `rate(kafka_cluster_bytesoutpersec_total[5m])` |
| Request Rate | Requests per second | `rate(kafka_request_Produce_total[5m])` |

#### Resource Utilization

| Metric | Description | Query |
|--------|-------------|-------|
| JVM Heap | Heap memory usage | `jvm_heap_used_bytes` |
| GC Time | Garbage collection time | `rate(jvm_gc_collection_time_ms[5m])` |
| Thread Count | Active JVM threads | `jvm_threads` |

### Sample Grafana Dashboard

**Panels to Create:**

**Panel 1: Cluster Overview**
```promql
# Active Controllers
kafka_controller_ActiveControllerCount

# Under-Replicated Partitions  
kafka_under_replicated_partitions

# Offline Partitions
kafka_controller_OfflinePartitionsCount
```

**Panel 2: Throughput**
```promql
# Messages In
rate(kafka_cluster_messagesinpersec_total[5m])

# Bytes In (MB/s)
rate(kafka_cluster_bytesinpersec_total[5m]) / 1024 / 1024

# Bytes Out (MB/s)
rate(kafka_cluster_bytesoutpersec_total[5m]) / 1024 / 1024
```

**Panel 3: JVM Memory**
```promql
# Heap Usage per Broker
jvm_heap_used_bytes{job="kafka-jvm"} / 1024 / 1024 / 1024
```

**Panel 4: Request Latency** (if available)
```promql
# Producer Request Time
kafka_network_requestmetrics_totaltimems{request="Produce"}
```

### Alert Rules

Create `prometheus-alerts.yml`:

```yaml
groups:
  - name: kafka_alerts
    interval: 30s
    rules:
      - alert: KafkaControllerDown
        expr: kafka_controller_ActiveControllerCount != 1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Kafka cluster has no active controller"
          
      - alert: UnderReplicatedPartitions
        expr: kafka_under_replicated_partitions > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Kafka has under-replicated partitions"
          
      - alert: OfflinePartitions
        expr: kafka_controller_OfflinePartitionsCount > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Kafka has offline partitions"
          
      - alert: HighJVMMemory
        expr: (jvm_heap_used_bytes / 1024 / 1024 / 1024) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "JVM heap usage above 80%"
```

---

## Operating the Cluster

### Creating Topics

**Important:** Always unset `KAFKA_OPTS` when running CLI commands to avoid JMX port conflicts.

```bash
# Create a topic
docker exec kafka-node1 bash -c "unset KAFKA_OPTS; kafka-topics --create \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092 \
  --partitions 3 \
  --replication-factor 3"

# List topics
docker exec kafka-node1 bash -c "unset KAFKA_OPTS; kafka-topics --list \
  --bootstrap-server kafka-node1:9092"

# Describe a topic
docker exec kafka-node1 bash -c "unset KAFKA_OPTS; kafka-topics --describe \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092"

# Delete a topic
docker exec kafka-node1 bash -c "unset KAFKA_OPTS; kafka-topics --delete \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092"
```

### Producing Messages

```bash
# Interactive producer
docker exec -it kafka-node1 bash -c "unset KAFKA_OPTS; kafka-console-producer \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092"

# Produce from file
cat messages.txt | docker exec -i kafka-node1 bash -c \
  "unset KAFKA_OPTS; kafka-console-producer \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092"

# Produce with key
docker exec -it kafka-node1 bash -c "unset KAFKA_OPTS; kafka-console-producer \
  --topic my-topic \
  --bootstrap-server kafka-node1:9092 \
  --property 'parse