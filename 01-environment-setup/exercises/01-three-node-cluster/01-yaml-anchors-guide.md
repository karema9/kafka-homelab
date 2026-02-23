

# YAML Anchors — Complete Kafka Production Guide

## 📚 Document Purpose

This is a **comprehensive, code-heavy guide** to mastering YAML anchors through **real Kafka infrastructure examples**. Every concept includes **full, runnable Docker Compose files** that you can copy, test, and deploy.

**Save this as:** `docs/yaml-anchors-kafka-guide.md`

---

## 🎯 Learning Path

```
Level 1: Problem Recognition     → See duplication, understand cost
Level 2: Basic Anchors          → Extract common properties
Level 3: Environment Merging    → Handle the shallow merge trap
Level 4: Multi-Anchor Patterns  → Combine multiple concerns
Level 5: Production Architecture → Full stack with monitoring
Level 6: Advanced Patterns      → Scaling, multi-environment
```

**Time Investment:** 2-3 hours for complete mastery

---

## ✅ Prerequisites

Before starting, ensure you have:

- [ ] Docker 20.10+ installed
- [ ] Docker Compose 2.0+ installed  
- [ ] Basic understanding of Kafka brokers
- [ ] Familiarity with YAML syntax
- [ ] Text editor with YAML support

**Validation:**
```bash
docker --version
docker compose version
docker compose config --help
```

---

## 📖 Quick Reference

| Operator | Name | Example | Purpose |
|----------|------|---------|---------|
| `&anchor_name` | Anchor | `&kafka_base` | Define reusable block |
| `*anchor_name` | Alias | `*kafka_base` | Reference entire block |
| `<<: *anchor` | Merge Key | `<<: *kafka_base` | Merge map contents |
| `x-*` | Extension Field | `x-kafka-common:` | Non-deployed config |

**Critical Rule:** YAML uses **shallow merge** for maps. Nested maps are replaced, not merged.

---

## Level 1: The Problem — Duplicated Configuration

### 1.1 Realistic Kafka Cluster (Anti-Pattern)

**File:** `docker-compose-duplicated.yml`

```yaml
version: '3.8'

networks:
  kafka-network:
    driver: bridge

services:
  kafka-node1:
    image: confluentinc/cp-kafka:7.8.0
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - '9192:9092'
      - '9193:9093'
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_COMPRESSION_TYPE: 'producer'
      KAFKA_MIN_INSYNC_REPLICAS: 2
    networks:
      - kafka-network
    volumes:
      - kafka-node1-data:/var/lib/kafka/data

  kafka-node2:
    image: confluentinc/cp-kafka:7.8.0
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - '9194:9092'
      - '9195:9093'
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    environment:
      KAFKA_NODE_ID: 2
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_COMPRESSION_TYPE: 'producer'
      KAFKA_MIN_INSYNC_REPLICAS: 2
    networks:
      - kafka-network
    volumes:
      - kafka-node2-data:/var/lib/kafka/data

  kafka-node3:
    image: confluentinc/cp-kafka:7.8.0
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - '9196:9092'
      - '9197:9093'
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    environment:
      KAFKA_NODE_ID: 3
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_COMPRESSION_TYPE: 'producer'
      KAFKA_MIN_INSYNC_REPLICAS: 2
    networks:
      - kafka-network
    volumes:
      - kafka-node3-data:/var/lib/kafka/data

volumes:
  kafka-node1-data:
  kafka-node2-data:
  kafka-node3-data:
```

### 1.2 Duplication Analysis

**Duplicated Items:**
- `image: confluentinc/cp-kafka:7.8.0` — **3 times**
- `restart: unless-stopped` — **3 times**
- `healthcheck` block — **3 times** (120 lines)
- `KAFKA_HEAP_OPTS` — **3 times**
- `KAFKA_NUM_IO_THREADS` — **3 times**
- `CLUSTER_ID` — **3 times**
- Network configuration — **3 times**

**Metrics:**
- Total lines: **~120 lines**
- Unique configuration: **~40%**
- Duplicated configuration: **~60%**
- Maintenance burden: **HIGH**

**Real Costs:**
1. **Update heap size** → Edit 3 places
2. **Upgrade Kafka version** → Edit 3 places
3. **Add new config parameter** → Edit 3 places
4. **Risk of drift** → One broker gets different config

---

## Level 2: First Refactor — Basic Anchors

### 2.1 Extract Service Properties

**File:** `docker-compose-level2.yml`

```yaml
version: '3.8'

# ============================================================
# ANCHOR DEFINITIONS
# ============================================================
x-kafka-common: &kafka-common
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network

# ============================================================
# SERVICES
# ============================================================
services:
  kafka-node1:
    <<: *kafka-common
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - '9192:9092'
      - '9193:9093'
    environment:
      KAFKA_NODE_ID: 1
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
    volumes:
      - kafka-node1-data:/var/lib/kafka/data

  kafka-node2:
    <<: *kafka-common
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - '9194:9092'
      - '9195:9093'
    environment:
      KAFKA_NODE_ID: 2
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
    volumes:
      - kafka-node2-data:/var/lib/kafka/data

  kafka-node3:
    <<: *kafka-common
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - '9196:9092'
      - '9197:9093'
    environment:
      KAFKA_NODE_ID: 3
      KAFKA_PROCESS_ROLES: 'broker,controller'
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093'
      CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
      KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
      KAFKA_NUM_IO_THREADS: 8
      KAFKA_LOG_RETENTION_HOURS: 168
    volumes:
      - kafka-node3-data:/var/lib/kafka/data

networks:
  kafka-network:
    driver: bridge

volumes:
  kafka-node1-data:
  kafka-node2-data:
  kafka-node3-data:
```

### 2.2 Test the Refactor

```bash
# Validate YAML syntax
docker compose -f docker-compose-level2.yml config > /dev/null
echo "✓ YAML is valid"

# View expanded configuration
docker compose -f docker-compose-level2.yml config | grep -A 5 "kafka-node1:"

# Start the cluster
docker compose -f docker-compose-level2.yml up -d

# Verify all nodes are running
docker compose -f docker-compose-level2.yml ps
```

### 2.3 Improvement Metrics

- Lines reduced: **~15 lines**
- Image defined: **1 time** (was 3)
- Restart policy defined: **1 time** (was 3)
- Network config defined: **1 time** (was 3)

**Still problematic:**
- Environment variables still duplicated
- Health checks not extracted
- Volume pattern still repetitive

---

## Level 3: The Shallow Merge Trap

### 3.1 Broken Attempt (Warning!)

**File:** `docker-compose-broken.yml`

```yaml
version: '3.8'

# ⚠️ THIS WILL NOT WORK AS EXPECTED!
x-kafka-common: &kafka-common
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  environment:
    KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
    KAFKA_NUM_IO_THREADS: 8
    KAFKA_LOG_RETENTION_HOURS: 168
    CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'

services:
  kafka-node1:
    <<: *kafka-common
    hostname: kafka-node1
    environment:
      KAFKA_NODE_ID: 1  # ⚠️ This REPLACES the entire environment map!
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092'

networks:
  kafka-network:
```

### 3.2 What Actually Happens

```bash
# Check what the final config looks like
docker compose -f docker-compose-broken.yml config
```

**Expected environment:**
```yaml
environment:
  KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_LOG_RETENTION_HOURS: 168
  CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'
  KAFKA_NODE_ID: 1
  KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092'
```

**Actual environment:**
```yaml
environment:
  KAFKA_NODE_ID: 1
  KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092'
```

**All shared variables are LOST!** ❌

### 3.3 Why This Happens

YAML merge keys (`<<:`) perform **shallow merge**:
- Top-level keys are merged
- If you redefine a key (like `environment`), the **entire value is replaced**
- Nested maps do **not** deep-merge

**Visual explanation:**
```yaml
# Step 1: Anchor defines
environment:
  A: 1
  B: 2

# Step 2: Service redefines environment
environment:
  C: 3

# Step 3: Result (NOT a merge!)
environment:
  C: 3  # A and B are gone!
```

---

## Level 4: Correct Pattern — Nested Environment Anchors

### 4.1 Two-Tier Anchor Strategy

**File:** `docker-compose-level4.yml`

```yaml
version: '3.8'

# ============================================================
# TIER 1: ENVIRONMENT VARIABLES ANCHOR
# ============================================================
x-kafka-env: &kafka-env
  KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_LOG_RETENTION_HOURS: 168
  KAFKA_COMPRESSION_TYPE: 'producer'
  KAFKA_MIN_INSYNC_REPLICAS: 2
  KAFKA_PROCESS_ROLES: 'broker,controller'
  CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'

# ============================================================
# TIER 2: SERVICE-LEVEL ANCHOR (No environment here!)
# ============================================================
x-kafka-common: &kafka-common
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network
  healthcheck:
    test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s

# ============================================================
# SERVICES — Proper Nested Merge
# ============================================================
services:
  kafka-node1:
    <<: *kafka-common
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - '9192:9092'
      - '9193:9093'
    environment:
      <<: *kafka-env  # ✅ Merge environment anchor first
      KAFKA_NODE_ID: 1  # ✅ Then add node-specific values
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093'
    volumes:
      - kafka-node1-data:/var/lib/kafka/data

  kafka-node2:
    <<: *kafka-common
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - '9194:9092'
      - '9195:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 2
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093'
    volumes:
      - kafka-node2-data:/var/lib/kafka/data

  kafka-node3:
    <<: *kafka-common
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - '9196:9092'
      - '9197:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 3
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093'
    volumes:
      - kafka-node3-data:/var/lib/kafka/data

networks:
  kafka-network:
    driver: bridge

volumes:
  kafka-node1-data:
  kafka-node2-data:
  kafka-node3-data:
```

### 4.2 Verification

```bash
# Validate and check environment variables
docker compose -f docker-compose-level4.yml config | grep -A 20 "kafka-node1:"

# Should see ALL environment variables:
# - KAFKA_HEAP_OPTS
# - KAFKA_NUM_IO_THREADS
# - KAFKA_NODE_ID
# - etc.

# Start and verify
docker compose -f docker-compose-level4.yml up -d
docker compose -f docker-compose-level4.yml exec kafka-node1 env | grep KAFKA_
```

### 4.3 Why This Works

**Merge flow:**
```yaml
# Step 1: Apply service anchor
image: confluentinc/cp-kafka:7.8.0
restart: unless-stopped
healthcheck: { ... }

# Step 2: Add node-specific properties
hostname: kafka-node1
ports: [ ... ]

# Step 3: Create NEW environment map with nested merge
environment:
  <<: *kafka-env      # Bring in all shared vars
  KAFKA_NODE_ID: 1    # Add node-specific vars
```

**Result:** Both shared AND node-specific variables exist! ✅

---

## Level 5: Multiple Anchor Patterns

### 5.1 Combining Multiple Concerns

**File:** `docker-compose-level5.yml`

```yaml
version: '3.8'

# ============================================================
# UNIVERSAL SERVICE DEFAULTS
# ============================================================
x-service-defaults: &service-defaults
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

# ============================================================
# KAFKA ENVIRONMENT VARIABLES
# ============================================================
x-kafka-env: &kafka-env
  KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_NUM_NETWORK_THREADS: 3
  KAFKA_SOCKET_SEND_BUFFER_BYTES: 102400
  KAFKA_SOCKET_RECEIVE_BUFFER_BYTES: 102400
  KAFKA_LOG_RETENTION_HOURS: 168
  KAFKA_LOG_SEGMENT_BYTES: 1073741824
  KAFKA_COMPRESSION_TYPE: 'producer'
  KAFKA_MIN_INSYNC_REPLICAS: 2
  KAFKA_PROCESS_ROLES: 'broker,controller'
  CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'

# ============================================================
# KAFKA-SPECIFIC SERVICE CONFIG
# ============================================================
x-kafka-service: &kafka-service
  image: confluentinc/cp-kafka:7.8.0
  networks:
    - kafka-network
  healthcheck:
    test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s

# ============================================================
# SERVICES
# ============================================================
services:
  kafka-node1:
    <<: *service-defaults  # Universal defaults (restart, logging)
    <<: *kafka-service     # Kafka-specific config (image, healthcheck)
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - '9192:9092'
      - '9193:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 1
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093'
    volumes:
      - kafka-node1-data:/var/lib/kafka/data

  kafka-node2:
    <<: *service-defaults
    <<: *kafka-service
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - '9194:9092'
      - '9195:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 2
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093'
    volumes:
      - kafka-node2-data:/var/lib/kafka/data

  kafka-node3:
    <<: *service-defaults
    <<: *kafka-service
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - '9196:9092'
      - '9197:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 3
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093'
    volumes:
      - kafka-node3-data:/var/lib/kafka/data

networks:
  kafka-network:
    driver: bridge

volumes:
  kafka-node1-data:
  kafka-node2-data:
  kafka-node3-data:
```

### 5.2 Anchor Merge Precedence

**Order matters!**

```yaml
service:
  <<: *first-anchor   # Applied first
  <<: *second-anchor  # Can override first
  explicit: value     # Overrides both anchors
```

**Test precedence:**
```yaml
x-a: &a
  color: red
  size: large

x-b: &b
  color: blue
  weight: heavy

test:
  <<: *a        # color: red, size: large
  <<: *b        # color: blue (overrides!), weight: heavy
  color: green  # color: green (final override)
```

---

## Level 6: Production Stack with Monitoring

### 6.1 Complete Infrastructure

**File:** `docker-compose-production.yml`

```yaml
version: '3.8'

# ============================================================
# GLOBAL DEFAULTS
# ============================================================
x-restart-policy: &restart-policy
  restart: unless-stopped

x-logging-config: &logging-config
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

# ============================================================
# KAFKA CONFIGURATION
# ============================================================
x-kafka-env: &kafka-env
  # JVM Settings
  KAFKA_HEAP_OPTS: "-Xmx1G -Xms1G"
  
  # Performance Tuning
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_NUM_NETWORK_THREADS: 3
  KAFKA_SOCKET_SEND_BUFFER_BYTES: 102400
  KAFKA_SOCKET_RECEIVE_BUFFER_BYTES: 102400
  
  # Storage Settings
  KAFKA_LOG_RETENTION_HOURS: 168
  KAFKA_LOG_SEGMENT_BYTES: 1073741824
  KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS: 300000
  
  # Reliability
  KAFKA_COMPRESSION_TYPE: 'producer'
  KAFKA_MIN_INSYNC_REPLICAS: 2
  KAFKA_DEFAULT_REPLICATION_FACTOR: 3
  KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
  
  # KRaft Mode
  KAFKA_PROCESS_ROLES: 'broker,controller'
  CLUSTER_ID: 'MkU3OEVBNTcwNTJENDM2Qk'

x-kafka-service: &kafka-service
  image: confluentinc/cp-kafka:7.8.0
  networks:
    - kafka-network
  healthcheck:
    test: ["CMD-SHELL", "kafka-broker-api-versions --bootstrap-server localhost:9092"]
    interval: 30s
    timeout: 10s
    retries: 5
    start_period: 60s

# ============================================================
# MONITORING CONFIGURATION
# ============================================================
x-monitoring-healthcheck: &monitoring-healthcheck
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 20s

# ============================================================
# SERVICES
# ============================================================
services:
  # ----------------------------------------------------------
  # KAFKA CLUSTER
  # ----------------------------------------------------------
  kafka-node1:
    <<: *restart-policy
    <<: *logging-config
    <<: *kafka-service
    hostname: kafka-node1
    container_name: kafka-node1
    ports:
      - '9192:9092'
      - '9193:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 1
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node1:9092,CONTROLLER://kafka-node1:9093'
      KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka-node1:9092'
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node1-data:/var/lib/kafka/data

  kafka-node2:
    <<: *restart-policy
    <<: *logging-config
    <<: *kafka-service
    hostname: kafka-node2
    container_name: kafka-node2
    ports:
      - '9194:9092'
      - '9195:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 2
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node2:9092,CONTROLLER://kafka-node2:9093'
      KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka-node2:9092'
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node2-data:/var/lib/kafka/data

  kafka-node3:
    <<: *restart-policy
    <<: *logging-config
    <<: *kafka-service
    hostname: kafka-node3
    container_name: kafka-node3
    ports:
      - '9196:9092'
      - '9197:9093'
    environment:
      <<: *kafka-env
      KAFKA_NODE_ID: 3
      KAFKA_LISTENERS: 'PLAINTEXT://kafka-node3:9092,CONTROLLER://kafka-node3:9093'
      KAFKA_ADVERTISED_LISTENERS: 'PLAINTEXT://kafka-node3:9092'
      KAFKA_CONTROLLER_QUORUM_VOTERS: '1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093'
    volumes:
      - kafka-node3-data:/var/lib/kafka/data

  # ----------------------------------------------------------
  # KAFKA UI
  # ----------------------------------------------------------
  kafka-ui:
    <<: *restart-policy
    <<: *logging-config
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    ports:
      - "8080:8080"
    healthcheck:
      <<: *monitoring-healthcheck
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
    environment:
      KAFKA_CLUSTERS_0_NAME: homelab-cluster
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

  # ----------------------------------------------------------
  # PROMETHEUS
  # ----------------------------------------------------------
  prometheus:
    <<: *restart-policy
    <<: *logging-config
    image: prom/prometheus:v2.53.0
    container_name: prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    healthcheck:
      <<: *monitoring-healthcheck
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
    volumes:
      - ./configs/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    networks:
      - kafka-network

  # ----------------------------------------------------------
  # GRAFANA
  # ----------------------------------------------------------
  grafana:
    <<: *restart-policy
    <<: *logging-config
    image: grafana/grafana:11.0.0
    container_name: grafana
    ports:
      - "3000:3000"
    healthcheck:
      <<: *monitoring-healthcheck
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3000/api/health"]
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_ANALYTICS_REPORTING_ENABLED: 'false'
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      prometheus:
        condition: service_healthy
    networks:
      - kafka-network

# ============================================================
# NETWORKS
# ============================================================
networks:
  kafka-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16

# ============================================================
# VOLUMES
# ============================================================
volumes:
  kafka-node1-data:
    driver: local
  kafka-node2-data:
    driver: local
  kafka-node3-data:
    driver: local
  prometheus-data:
    driver: local
  grafana-data:
    driver: local
```

### 6.2 Deploy and Validate

```bash
# Validate configuration
docker compose -f docker-compose-production.yml config

# Start infrastructure