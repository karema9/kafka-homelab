<div align="center">

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   ██╗  ██╗ █████╗ ███████╗██╗  ██╗ █████╗                         │
│   ██║ ██╔╝██╔══██╗██╔════╝██║ ██╔╝██╔══██╗                        │
│   █████╔╝ ███████║█████╗  █████╔╝ ███████║                        │
│   ██╔═██╗ ██╔══██║██╔══╝  ██╔═██╗ ██╔══██║                        │
│   ██║  ██╗██║  ██║██║     ██║  ██╗██║  ██║                        │
│   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝                        │
│                                                                     │
│              🏠  H O M E L A B   L E A R N I N G   P A T H          │
│                                                                     │
│        Master Apache Kafka through hands-on practice               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

<h1>Kafka Homelab Learning Path</h1>

### 🎯 A comprehensive, hands-on guide to mastering Apache Kafka
**From fundamentals to production-grade distributed systems**

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Kafka](https://img.shields.io/badge/Kafka-3.x-black?logo=apache-kafka&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Dashboard-Grafana-orange?logo=grafana)
![Kubernetes](https://img.shields.io/badge/Kubernetes-blue?logo=kubernetes)
![Ansible](https://img.shields.io/badge/Automation-Ansible-black?logo=ansible)
![Python](https://img.shields.io/badge/Client-Python-blue?logo=python)
![Last Commit](https://img.shields.io/github/last-commit/<your-username>/kafka-homelab-learning-path)
![Stars](https://img.shields.io/github/stars/<your-username>/kafka-homelab-learning-path)
![Forks](https://img.shields.io/github/forks/<your-username>/kafka-homelab-learning-path)
![Issues](https://img.shields.io/github/issues/<your-username>/kafka-homelab-learning-path)
![Contributors](https://img.shields.io/github/contributors/<your-username>/kafka-homelab-learning-path)

[![Discord](https://img.shields.io/badge/Discord-Join%20Community-7289da?logo=discord&logoColor=white)](https://discord.gg/your-invite-link)
[![Twitter Follow](https://img.shields.io/twitter/follow/your_handle?style=social)](https://twitter.com/your_handle)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/your-profile)

</div>

---

## Overview

This repository provides a structured, hands-on curriculum for learning Apache Kafka by building a complete Kafka Homelab environment. The content is designed for engineers seeking to progress from beginner to advanced proficiency in real-world streaming systems architecture and operations.

---

## Prerequisites

### Required Knowledge

Before starting this learning path, you should have:

- **Linux/Unix fundamentals**: Command line navigation, file permissions, process management
- **Basic networking concepts**: TCP/IP, ports, DNS, firewalls
- **Programming fundamentals**: Variables, loops, functions (preferably in Python or Java)
- **Distributed systems basics**: Understanding of client-server architecture, APIs, and REST
- **Version control**: Basic Git operations (clone, commit, push, pull)

### Recommended Background

While not strictly required, the following will accelerate your learning:

- Experience with Docker and containerization concepts
- Familiarity with YAML and configuration file formats
- Understanding of pub/sub messaging patterns
- Basic SQL and database concepts
- Cloud computing fundamentals (AWS, GCP, or Azure)

### Hardware Requirements

Your homelab environment should meet these minimum specifications:

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 16GB | 32GB+ |
| **CPU** | 4 cores | 8+ cores |
| **Storage** | 50GB free | 100GB+ SSD |
| **Network** | 100 Mbps | 1 Gbps |
| **OS** | Ubuntu 20.04+ / CentOS 8+ / macOS | Ubuntu 22.04 LTS |

**Note:** For Kubernetes deployments, add 8GB RAM per worker node.

### Software Prerequisites

Install these tools before beginning:

#### Essential Tools

```bash
# Docker & Docker Compose
docker --version          # 20.10.x or higher
docker-compose --version  # 2.x or higher

# Python
python3 --version         # 3.8 or higher
pip3 --version

# Git
git --version             # 2.x or higher

# Text editor
vim / nano / VS Code
```

#### Optional but Recommended

```bash
# For Kubernetes deployments
kubectl --version         # 1.24.x or higher
helm --version            # 3.x or higher

# For automation
ansible --version         # 2.10.x or higher

# For Java-based clients
java --version            # OpenJDK 11 or 17

# Monitoring tools
prometheus --version
grafana-cli --version
```

#### Quick Setup Verification

Run this verification script to check your environment:

```bash
#!/bin/bash
echo "Checking prerequisites..."

command -v docker >/dev/null 2>&1 && echo "✓ Docker installed" || echo "✗ Docker missing"
command -v docker-compose >/dev/null 2>&1 && echo "✓ Docker Compose installed" || echo "✗ Docker Compose missing"
command -v python3 >/dev/null 2>&1 && echo "✓ Python 3 installed" || echo "✗ Python 3 missing"
command -v git >/dev/null 2>&1 && echo "✓ Git installed" || echo "✗ Git missing"

# Check RAM
total_ram=$(free -g | awk '/^Mem:/{print $2}')
if [ "$total_ram" -ge 16 ]; then
    echo "✓ RAM: ${total_ram}GB (sufficient)"
else
    echo "✗ RAM: ${total_ram}GB (minimum 16GB recommended)"
fi

# Check disk space
free_space=$(df -h . | awk 'NR==2 {print $4}')
echo "✓ Free disk space: $free_space"
```

### System Configuration

Before deploying Kafka, optimize your system:

```bash
# Increase file descriptor limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Optimize swappiness for Kafka
echo "vm.swappiness=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Enable IP forwarding (for Docker networking)
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Installation Guides

If you're missing any prerequisites, refer to these installation guides:

- **Docker**: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)
- **Python**: [python.org/downloads](https://www.python.org/downloads/)
- **Kubernetes (Minikube)**: [minikube.sigs.k8s.io/docs/start](https://minikube.sigs.k8s.io/docs/start/)
- **Ansible**: [docs.ansible.com/ansible/latest/installation_guide](https://docs.ansible.com/ansible/latest/installation_guide/)

---

## Learning Objectives

- Understand Kafka architecture, internals, and core components
- Deploy Kafka on bare metal, Docker, Kubernetes, or via Ansible automation
- Build, secure, monitor, and scale production-ready Kafka clusters
- Work with Kafka Connect, Kafka Streams, and ksqlDB
- Implement real-time data processing systems for fraud detection, observability, and ETL pipelines
- Master Kafka performance tuning and operational troubleshooting

---

## Repository Structure

Your comprehensive learning journey is organized into 12 progressive modules, each with hands-on exercises and checkpoints:

### 📚 Learning Modules Overview

| Module | Focus Area | Duration | Key Skills |
|--------|------------|----------|------------|
| [`00-prerequisites`](./00-prerequisites) | Distributed Systems, JVM, Linux & Networking | 1-2 weeks | Foundation concepts, system tuning |
| [`01-environment-setup`](./01-environment-setup) | Homelab Deployment (Bare Metal, Docker, K8s, Ansible) | 1-2 weeks | Cluster installation, architecture |
| [`02-kafka-fundamentals`](./02-kafka-fundamentals) | Architecture, Producers, Consumers, Delivery Semantics | 2-3 weeks | Core Kafka concepts, client development |
| [`03-operations`](./03-operations) | Monitoring, Configuration, Troubleshooting | 2 weeks | Operations, Prometheus/Grafana, cluster management |
| [`04-performance`](./04-performance) | Producer/Consumer/Broker Tuning, Benchmarking | 1-2 weeks | Performance optimization, load testing |
| [`05-kafka-streams`](./05-kafka-streams) | Stream Processing, State Stores, Windowing | 2 weeks | Real-time processing, stateful applications |
| [`06-kafka-connect`](./06-kafka-connect) | Connectors, Source/Sink, Custom Development | 1 week | Data integration, CDC pipelines |
| [`07-schema-management`](./07-schema-management) | Schema Registry, Evolution, Compatibility | 3-4 days | Schema governance, Avro |
| [`08-security`](./08-security) | Authentication, Authorization, Encryption | 1 week | TLS/SSL, SASL, ACLs |
| [`09-advanced-topics`](./09-advanced-topics) | Multi-DC, KRaft, Tiered Storage, Quotas | 1-2 weeks | Advanced architectures, KRaft migration |
| [`10-failure-scenarios`](./10-failure-scenarios) | Broker Failures, Network Partitions, Chaos Engineering | 1 week | Disaster recovery, resilience testing |
| [`11-production-scenarios`](./11-production-scenarios) | Cost Optimization, Incident Response, Runbooks | 1 week | Production operations, on-call procedures |
| [`12-real-world-projects`](./12-real-world-projects) | Microservices, Analytics, CDC, Fraud Detection | 2-4 weeks | End-to-end implementations |

**Total Learning Time:** 12-16 weeks of focused study

---

### 🗂️ Detailed Structure

<details>
<summary><b>00-prerequisites</b> - System Fundamentals</summary>

```
00-prerequisites/
├── distributed-systems-primer.md    # CAP theorem, consistency models
├── jvm-essentials.md                 # Garbage collection, heap tuning
├── linux-fundamentals.md             # File systems, process management
├── networking-basics.md              # TCP/IP, DNS, load balancing
├── exercises/
│   ├── jvm-tuning-basics.md
│   └── networking-lab.md
└── checkpoint/
    ├── exit-criteria.json
    └── quiz.json
```
</details>

<details>
<summary><b>01-environment-setup</b> - Deployment Options</summary>

```
01-environment-setup/
├── bare-metal/
│   ├── kafka-install.sh              # Single-node installation
│   ├── multinode-kafka-installation.sh
│   ├── single-node-kraft-setup.sh
│   └── zookeeper-install.sh
├── docker-compose/
│   ├── single-broker/
│   │   └── docker-compose.yml
│   ├── three-broker-cluster/
│   │   ├── docker-compose.yml
│   │   └── configs/                  # JMX, Prometheus configs
│   └── with-monitoring/
│       └── docker-compose.yml        # Full observability stack
├── kubernetes/
│   ├── kafka-cluster.yml             # Strimzi operator deployment
│   ├── kafka-topics.yml
│   └── README.md
├── ansible/
│   ├── inventory.ini
│   └── playbook.yml                  # Automated multi-node setup
├── homelab-architecture.md
├── hardware-requirements.md
└── exercises/
    ├── setup-single-node.md
    ├── setup-cluster.md
    └── verify-installation.sh
```
</details>

<details>
<summary><b>02-kafka-fundamentals</b> - Core Concepts</summary>

```
02-kafka-fundamentals/
├── 01-architecture/
│   ├── broker-internals.md
│   ├── topics-and-partitions.md
│   ├── replication-model.md
│   ├── log-structure.md
│   └── exercises/
│       ├── create-topics-cli.sh
│       ├── inspect-partitions.md
│       └── replication-hands-on.md
├── 02-producers/
│   ├── producer-internals.md
│   ├── partitioning-strategies.md
│   ├── batching-compression.md
│   ├── serialization.md
│   ├── code-examples/
│   │   ├── basic-producer.py
│   │   ├── async-producer.py
│   │   ├── custom-partitioner.py
│   │   └── transactional-producer.py
│   └── exercises/
│       ├── build-producer.md
│       ├── test-partitioning.md
│       └── performance-tuning.md
├── 03-consumers/
│   ├── consumer-internals.md
│   ├── consumer-groups.md
│   ├── offset-management.md
│   ├── rebalancing-protocols.md
│   ├── code-examples/
│   │   ├── basic-consumer.py
│   │   ├── consumer-group-demo.py
│   │   ├── manual-offset-commit.py
│   │   └── parallel-consumers.py
│   └── exercises/
│       ├── consumer-lag-analysis.md
│       ├── offset-reset-strategies.md
│       └── rebalancing-simulation.md
├── 04-message-delivery/
│   ├── delivery-semantics.md         # At-least-once, exactly-once
│   ├── acks-and-reliability.md
│   ├── idempotence.md
│   ├── transactions.md
│   └── exercises/
│       ├── test-at-least-once.md
│       ├── test-exactly-once.md
│       └── failure-scenarios.md
└── 05-kafka-internals-deep-dive/
    ├── log-segments.md
    ├── log-compaction.md
    ├── index-files.md
    ├── zero-copy.md
    └── exercises/
        ├── inspect-logs-segment.sh
        └── log-compaction-lab.md
```
</details>

<details>
<summary><b>03-operations</b> - Running Kafka in Production</summary>

```
03-operations/
├── 01-configuration/
│   ├── broker-configs.md
│   ├── producer-configs.md
│   ├── consumer-configs.md
│   ├── topic-configs.md
│   └── templates/
│       ├── server.properties
│       └── client.properties
├── 02-monitoring/
│   ├── metrics-overview.md
│   ├── jmx-metrics.md
│   ├── prometheus-setup/
│   │   ├── prometheus.yml
│   │   └── jmx-exporter-config.yml
│   ├── grafana-dashboards/
│   │   ├── cluster-overview.json
│   │   ├── consumer-lag.json
│   │   └── topics-metrics.json
│   ├── alerting-rules/
│   │   └── kafka-alerts.yml
│   └── exercises/
│       ├── setup-monitoring-stack.md
│       ├── create-custom-dashboard.md
│       └── alert-tuning.md
├── 03-cluster-management/
│   ├── rolling-restarts.md
│   ├── partition-reassignment.md
│   ├── broker-decommission.md
│   ├── cluster-autoscaling.md
│   └── tools/
│       ├── reassign-partitions.sh
│       └── preferred-replica-election.sh
├── 04-troubleshooting/
│   ├── common-issues.md
│   ├── debugging-guide.md
│   ├── under-replicated-partitions.md
│   ├── slow-consumers.md
│   ├── rebalancing-storms.md
│   └── exercises/
│       ├── diagnose-consumer-lag.md
│       ├── fix-replication-issues.md
│       └── performance-debugging.md
├── 05-backup-recovery/
│   ├── backup-strategies.md
│   ├── disaster-recovery.md
│   └── mirror-maker-2.md
└── 06-capacity-planning/
    ├── storage-planning.md
    ├── retention-policies.md
    └── size-guide.md
```
</details>

<details>
<summary><b>04-performance</b> - Optimization & Benchmarking</summary>

```
04-performance/
├── 01-producer-tuning/
│   ├── throughput-optimization.md
│   ├── latency-optimization.md
│   ├── batch-size-tuning.md
│   └── exercises/
│       ├── benchmark-producer.sh
│       └── tuning-lab.md
├── 02-consumer-tuning/
│   ├── fetch-size-optimization.md
│   ├── parallelism-strategies.md
│   └── exercises/
│       ├── consumer-benchmarks.sh
│       └── optimize-throughput.md
├── 03-broker-tuning/
│   ├── jvm-tuning.md
│   ├── os-tuning.md
│   ├── disk-io-optimization.md
│   └── network-tuning.md
└── 04-benchmarking/
    ├── kafka-perf-test.md
    ├── load-testing.md
    ├── stress-testing.md
    ├── scripts/
    │   ├── producer-perf.sh
    │   └── consumer-perf.sh
    └── checkpoint/
        └── performance-assessment.md
```
</details>

<details>
<summary><b>05-kafka-streams</b> - Stream Processing</summary>

```
05-kafka-streams/
├── 01-fundamentals/
│   ├── stream-concepts.md
│   ├── topology.md
│   ├── stateless-operations.md
│   ├── stateful-operations.md
│   └── exercises/
│       ├── word-count.py
│       ├── filtering-transformations.py
│       └── joins-example.py
├── 02-state-stores/
│   ├── state-management.md
│   ├── ktable-globalktable.md
│   ├── windowing.md
│   └── exercises/
│       ├── aggregations-lab.md
│       └── windowed-operations.py
└── 03-advanced/
    ├── exactly-once-streams.md
    ├── interactive-queries.md
    └── custom-processors.md
```
</details>

<details>
<summary><b>06-kafka-connect</b> - Data Integration</summary>

```
06-kafka-connect/
├── 01-fundamentals/
│   ├── connect-concepts.md
│   ├── connectors-overview.md
│   ├── distributed-mode.md
│   └── exercises/
│       ├── setup-connect-cluster.md
│       └── deploy-connector.md
├── 02-source-connectors/
│   ├── jdbc-source.json            # Database CDC
│   ├── debezium-postgres.json      # PostgreSQL CDC
│   └── file-source.json
├── 03-sink-connectors/
│   ├── jdbc-sink.json              # Database writes
│   ├── s3-sink.json                # Object storage
│   └── elasticsearch-sink.json     # Search indexing
└── 04-custom-connectors/
    └── connector-development.md
```
</details>

<details>
<summary><b>07-schema-management</b> - Schema Registry</summary>

```
07-schema-management/
├── schema-registry/
│   └── setup.md
└── schema-evolution/
    ├── compatibility-types.md
    └── migration-strategies.md
```
</details>

<details>
<summary><b>08-security</b> - Authentication & Authorization</summary>

```
08-security/
├── 01-authentication/
│   ├── ssl-tls-setup.md
│   ├── sasl-setup.md
│   └── kerberos-setup.md
├── 02-authorization/
│   ├── acls-overview.md
│   └── acl-management.sh
└── 03-encryption/
    ├── encryption-in-transit.md
    └── encryption-at-rest.md
```
</details>

<details>
<summary><b>09-advanced-topics</b> - Enterprise Features</summary>

```
09-advanced-topics/
├── 01-multi-datacenter/
│   ├── replication-strategies.md
│   ├── active-passive.md
│   └── active-active.md
├── 02-kraft-mode/
│   ├── kraft-architecture.md
│   └── migration-from-zk.md
├── 03-tiered-storage/
│   └── tiered-storage-overview.md
└── 04-quotas-throttling/
    └── quota-management.md
```
</details>

<details>
<summary><b>10-failure-scenarios</b> - Resilience Testing</summary>

```
10-failure-scenarios/
├── 01-broker-failures/
│   ├── single-broker-failure.md
│   ├── multiple-broker-failure.md
│   └── exercises/
│       ├── simulate-broker-crash.md
│       └── recovery-procedures.md
├── 02-network-partition/
│   ├── split-brain.md
│   └── exercises/
│       └── partition-simulation.md
├── 03-data-corruption/
│   ├── detection.md
│   └── recovery.md
├── 04-chaos-engineering/
│   ├── chaos-monkey-kafka.sh
│   └── failure-injection.py
└── disaster-recovery-drills/
    └── full-cluster-recovery.md
```
</details>

<details>
<summary><b>11-production-scenarios</b> - Operations at Scale</summary>

```
11-production-scenarios/
├── 03-cost-optimization/
│   ├── compression-strategies.md
│   └── retention-optimization.md
└── 04-operation-runbooks/
    ├── incident-response.md
    └── oncall-playbook.md
```
</details>

<details>
<summary><b>12-real-world-projects</b> - Portfolio Projects</summary>

```
12-real-world-projects/
├── 01-event-driven-microservices/
│   ├── README.md
│   └── architecture.md
├── 02-real-time-analytics-pipeline/
│   └── README.md
├── 03-cdc-data-lake/
│   └── README.md
└── 04-fraud-detection-system/
    └── README.md
```
</details>

---

### 📋 Learning Checkpoints

Throughout the curriculum, you'll find **checkpoint directories** with:
- **Exit criteria** (JSON-based skill validation)
- **Quizzes** (Self-assessment tests)
- **Verification scripts** (Automated environment checks)
- **Performance assessments** (Benchmarking exercises)

These ensure you've mastered each section before moving forward

---

## Technology Stack

| Category | Tools |
|-----------|-------|
| **Core Messaging** | Apache Kafka (latest stable release) |
| **Coordination** | Zookeeper / KRaft |
| **Monitoring** | Prometheus, Grafana |
| **Automation** | Ansible |
| **Deployment** | Bare metal, Docker Compose, Kubernetes |
| **Client Development** | Python |
| **Visualization** | Grafana Dashboards |

---

## Getting Started

### 🚀 Quick Start (5 Minutes)

Get a Kafka cluster running immediately:

```bash
# Clone the repository
git clone https://github.com/<your-username>/kafka-homelab-learning-path.git
cd kafka-homelab-learning-path

# Start a single-broker cluster with Docker Compose
cd 01-environment-setup/docker-compose/single-broker
docker-compose up -d

# Verify cluster is running
docker-compose ps

# Create a test topic
docker exec kafka-broker kafka-topics --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1

# Produce a message
echo "Hello Kafka!" | docker exec -i kafka-broker \
  kafka-console-producer --topic test-topic \
  --bootstrap-server localhost:9092

# Consume the message
docker exec kafka-broker kafka-console-consumer \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --from-beginning \
  --max-messages 1
```

**🎉 Congratulations!** You just produced and consumed your first Kafka message.

---

### 📖 Full Learning Path

#### Phase 1: Foundation (Weeks 1-2)

**Module 00: Prerequisites**
- Review [`00-prerequisites/distributed-systems-primer.md`](./00-prerequisites/distributed-systems-primer.md)
- Complete Linux and networking fundamentals
- Practice JVM tuning basics
- ✅ **Checkpoint:** Pass the prerequisites quiz

**Module 01: Environment Setup**
1. Read [`01-environment-setup/homelab-architecture.md`](./01-environment-setup/homelab-architecture.md)
2. Choose your deployment method:
   - **Beginners:** Start with [`docker-compose/single-broker`](./01-environment-setup/docker-compose/single-broker)
   - **Intermediate:** Deploy [`docker-compose/three-broker-cluster`](./01-environment-setup/docker-compose/three-broker-cluster)
   - **Advanced:** Try [`kubernetes`](./01-environment-setup/kubernetes) or [`ansible`](./01-environment-setup/ansible) deployments
3. Complete exercises in `01-environment-setup/exercises/`
4. ✅ **Checkpoint:** Run `environment-verification.sh`

#### Phase 2: Core Concepts (Weeks 3-5)

**Module 02: Kafka Fundamentals**
- Work through sections sequentially:
  1. [`01-architecture`](./02-kafka-fundamentals/01-architecture) - Understanding brokers, topics, partitions
  2. [`02-producers`](./02-kafka-fundamentals/02-producers) - Build your first producer (Python examples included)
  3. [`03-consumers`](./02-kafka-fundamentals/03-consumers) - Consumer groups and offset management
  4. [`04-message-delivery`](./02-kafka-fundamentals/04-message-delivery) - Exactly-once semantics
  5. [`05-kafka-internals-deep-dive`](./02-kafka-fundamentals/05-kafka-internals-deep-dive) - Log segments and compaction
- Run all code examples in `code-examples/` directories
- Complete hands-on exercises in each section

#### Phase 3: Operations (Weeks 6-8)

**Module 03: Operations**
- [`01-configuration`](./03-operations/01-configuration) - Optimize broker and client configs
- [`02-monitoring`](./03-operations/02-monitoring) - Set up Prometheus + Grafana
  - Deploy the monitoring stack: `docker-compose/with-monitoring`
  - Import Grafana dashboards from `grafana-dashboards/`
- [`03-cluster-management`](./03-operations/03-cluster-management) - Practice rolling restarts
- [`04-troubleshooting`](./03-operations/04-troubleshooting) - Debug common issues
- [`05-backup-recovery`](./03-operations/05-backup-recovery) - Disaster recovery
- [`06-capacity-planning`](./03-operations/06-capacity-planning) - Plan for growth

**Module 04: Performance**
- Tune producers, consumers, and brokers ([`04-performance`](./04-performance))
- Run benchmarks using `04-performance/04-benchmarking/scripts/`
- ✅ **Checkpoint:** Complete performance assessment

#### Phase 4: Advanced Features (Weeks 9-11)

**Module 05: Kafka Streams**
- Build streaming applications ([`05-kafka-streams`](./05-kafka-streams))
- Implement stateful processing with windowing
- Practice with examples: word count, joins, aggregations

**Module 06: Kafka Connect**
- Deploy source and sink connectors ([`06-kafka-connect`](./06-kafka-connect))
- Set up CDC with Debezium
- Stream data to Elasticsearch or S3

**Module 07-09: Enterprise Features**
- [`07-schema-management`](./07-schema-management) - Schema Registry and Avro
- [`08-security`](./08-security) - TLS, SASL, ACLs
- [`09-advanced-topics`](./09-advanced-topics) - KRaft, Multi-DC, Tiered Storage

#### Phase 5: Resilience & Production (Weeks 12-14)

**Module 10: Failure Scenarios**
- Simulate broker failures ([`10-failure-scenarios`](./10-failure-scenarios))
- Practice chaos engineering
- Run disaster recovery drills

**Module 11: Production Scenarios**
- Study incident response playbooks ([`11-production-scenarios`](./11-production-scenarios))
- Optimize costs and retention

#### Phase 6: Capstone Projects (Weeks 15-16)

**Module 12: Real-World Projects**
Choose 1-2 projects to build end-to-end:
- [`01-event-driven-microservices`](./12-real-world-projects/01-event-driven-microservices)
- [`02-real-time-analytics-pipeline`](./12-real-world-projects/02-real-time-analytics-pipeline)
- [`03-cdc-data-lake`](./12-real-world-projects/03-cdc-data-lake)
- [`04-fraud-detection-system`](./12-real-world-projects/04-fraud-detection-system)

---

### 🎯 Learning Tips

**For Self-Paced Learners:**
- Follow the modules sequentially - each builds on previous knowledge
- Complete all exercises before moving to the next module
- Use checkpoints to validate your understanding
- Join our [Discord](#community-and-support) to discuss challenges

**For Hands-On Practice:**
- Always run code examples yourself - don't just read them
- Break things intentionally to understand failure modes
- Modify examples to explore different configurations
- Document your learnings in a personal wiki or blog

**For Career Development:**
- Build a portfolio project from Module 12
- Prepare for certifications (see [Certification Preparation](#certification-preparation))
- Share your homelab setup and learnings on LinkedIn
- Contribute improvements back to this repository

---

## Deployment Options

Choose the deployment method that matches your learning goals and infrastructure:

### 🐳 Docker Compose (Recommended for Beginners)

**Best for:** Quick setup, local development, learning fundamentals

**Available Configurations:**
- **Single Broker** ([`docker-compose/single-broker`](./01-environment-setup/docker-compose/single-broker))
  - Minimal setup for learning basics
  - Low resource requirements (4GB RAM)
  - Quick start/stop cycles
  
- **Three-Broker Cluster** ([`docker-compose/three-broker-cluster`](./01-environment-setup/docker-compose/three-broker-cluster))
  - Production-like setup with replication
  - Includes JMX monitoring
  - Test partition distribution and failover
  - Requires 8-12GB RAM
  
- **Full Monitoring Stack** ([`docker-compose/with-monitoring`](./01-environment-setup/docker-compose/with-monitoring))
  - Complete observability with Prometheus & Grafana
  - Pre-configured dashboards
  - Alert rules included
  - Requires 12-16GB RAM

**Quick Start:**
```bash
cd 01-environment-setup/docker-compose/three-broker-cluster
docker-compose up -d
# Access Prometheus: http://localhost:9090
# Access Grafana: http://localhost:3000
```

---

### 🖥️ Bare Metal (Best for Production-Like Learning)

**Best for:** Understanding real infrastructure, performance tuning, operational challenges

**Available Scripts:**
- [`kafka-install.sh`](./01-environment-setup/bare-metal/kafka-install.sh) - Single-node Kafka
- [`single-node-kraft-setup.sh`](./01-environment-setup/bare-metal/single-node-kraft-setup.sh) - KRaft mode (no Zookeeper)
- [`multinode-kafka-installation.sh`](./01-environment-setup/bare-metal/multinode-kafka-installation.sh) - Multi-broker cluster
- [`zookeeper-install.sh`](./01-environment-setup/bare-metal/zookeeper-install.sh) - Standalone Zookeeper

**Advantages:**
- True performance characteristics
- Real disk I/O and network behavior
- Practice OS-level tuning
- Deeper understanding of Kafka operations

**Use when:** You have 3+ physical/virtual machines or want to learn production deployment

---

### ☸️ Kubernetes (Cloud-Native Deployment)

**Best for:** Container orchestration, cloud deployments, auto-scaling

**Deployment Method:** Strimzi Operator

**Available Resources:**
- [`kafka-cluster.yml`](./01-environment-setup/kubernetes/kafka-cluster.yml) - Cluster definition
- [`kafka-topics.yml`](./01-environment-setup/kubernetes/kafka-topics.yml) - Declarative topic management

**Features:**
- Automated deployment and scaling
- Rolling updates without downtime
- Cloud-agnostic (works on EKS, GKE, AKS, K3s)
- GitOps-ready configurations

**Quick Start:**
```bash
# Install Strimzi operator
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# Deploy Kafka cluster
kubectl apply -f 01-environment-setup/kubernetes/kafka-cluster.yml -n kafka

# Deploy topics
kubectl apply -f 01-environment-setup/kubernetes/kafka-topics.yml -n kafka
```

**Use when:** Learning Kubernetes, preparing for cloud deployments, need auto-scaling

---

### 🤖 Ansible (Infrastructure as Code)

**Best for:** Automated multi-node deployments, repeatable configurations, team environments

**Available Playbooks:**
- [`playbook.yml`](./01-environment-setup/ansible/playbook.yml) - Complete cluster setup
- [`inventory.ini`](./01-environment-setup/ansible/inventory.ini) - Infrastructure definition

**What it automates:**
- OS configuration and tuning
- Java/JVM installation
- Kafka broker installation across nodes
- Configuration management
- Service orchestration

**Quick Start:**
```bash
# Edit inventory with your server IPs
vim 01-environment-setup/ansible/inventory.ini

# Run playbook
ansible-playbook -i inventory.ini playbook.yml
```

**Use when:** Managing multiple environments, practicing DevOps workflows, need reproducible deployments

---

### 📊 Deployment Comparison

| Factor | Docker Compose | Bare Metal | Kubernetes | Ansible |
|--------|----------------|------------|------------|---------|
| **Setup Time** | < 5 minutes | 30-60 minutes | 15-30 minutes | 20-40 minutes |
| **Learning Curve** | Low | Medium | High | Medium |
| **Resource Usage** | Moderate | High | High | High |
| **Production Similarity** | Medium | Very High | High | Very High |
| **Portability** | High | Low | Very High | Medium |
| **Best For** | Learning, Testing | Performance, Ops | Cloud, Scale | Automation, Teams |
| **Prerequisites** | Docker only | Multiple VMs | K8s cluster | Ansible + VMs |

---

## Real-World Projects

Build production-ready systems with these comprehensive projects:

### 🏛️ Event-Driven Microservices
**Location:** [`12-real-world-projects/01-event-driven-microservices`](./12-real-world-projects/01-event-driven-microservices)

Build a complete microservices architecture using Kafka as the event backbone. Implement:
- Event sourcing and CQRS patterns
- Saga orchestration for distributed transactions
- Service-to-service communication via Kafka
- Event schema evolution

**Skills:** Architecture design, microservices patterns, distributed transactions

---

### 📊 Real-Time Analytics Pipeline
**Location:** [`12-real-world-projects/02-real-time-analytics-pipeline`](./12-real-world-projects/02-real-time-analytics-pipeline)

Stream and process data in real-time for business intelligence:
- Ingest clickstream data into Kafka
- Process with Kafka Streams for aggregations
- Sink to data warehouse (BigQuery/Redshift)
- Visualize with Grafana/Tableau

**Skills:** Stream processing, analytics, data warehousing, BI

---

### 🗄️ CDC Data Lake Pipeline
**Location:** [`12-real-world-projects/03-cdc-data-lake`](./12-real-world-projects/03-cdc-data-lake)

Capture database changes and build a data lake:
- Deploy Debezium for PostgreSQL CDC
- Stream changes to Kafka
- Transform and enrich data
- Sink to S3/GCS with partitioning
- Query with Athena/BigQuery

**Skills:** Change Data Capture, data lakes, ETL/ELT, Debezium

---

### 🔍 Fraud Detection System
**Location:** [`12-real-world-projects/04-fraud-detection-system`](./12-real-world-projects/04-fraud-detection-system)

Build a real-time fraud detection pipeline:
- Ingest transaction events at high throughput
- Stateful stream processing for pattern detection
- Machine learning model integration
- Real-time alerting and blocking
- Dashboard for fraud analysts

**Skills:** Real-time ML, stateful processing, windowing, alerting

---

Each project includes:
- ✅ Detailed architecture diagrams
- ✅ Step-by-step implementation guide
- ✅ Production-grade code examples
- ✅ Testing and validation procedures
- ✅ Performance benchmarks
- ✅ Troubleshooting guides

---

## Contributing

We welcome and encourage contributions from the community! Whether you're fixing typos, adding new content, or suggesting improvements, your help makes this resource better for everyone.

### Ways to Contribute

#### 🐛 Report Issues
Found a bug, broken link, or outdated information?
- Open an [issue](https://github.com/<your-username>/kafka-homelab-learning-path/issues)
- Use descriptive titles and provide context
- Include steps to reproduce (if applicable)

#### 💡 Suggest Improvements
Have ideas for new content or better explanations?
- Open a [discussion](https://github.com/<your-username>/kafka-homelab-learning-path/discussions)
- Share your use case or learning challenge
- Suggest new projects or exercises

#### 🔧 Submit Pull Requests
Ready to contribute code or documentation?

1. **Fork the repository**
   ```bash
   git clone https://github.com/<your-username>/kafka-homelab-learning-path.git
   cd kafka-homelab-learning-path
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow existing formatting and structure
   - Test all code examples and commands
   - Update relevant documentation

3. **Commit with clear messages**
   ```bash
   git add .
   git commit -m "Add: detailed description of your changes"
   ```

4. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then open a Pull Request on GitHub

### Contribution Guidelines

#### Code Standards
- **Scripts**: Include comments and error handling
- **Documentation**: Use clear, concise language
- **Examples**: Provide working, tested code snippets
- **Formatting**: Follow Markdown best practices

#### Content Standards
- **Accuracy**: Verify all technical information
- **Completeness**: Include prerequisites and expected outcomes
- **Clarity**: Write for beginners while respecting advanced users
- **Attribution**: Credit sources and original authors

#### What We're Looking For

**High Priority:**
- ✅ Additional real-world project examples
- ✅ Terraform and Pulumi deployment scripts
- ✅ Advanced security configurations (mTLS, RBAC)
- ✅ Performance benchmarking guides and scripts
- ✅ Troubleshooting guides for common issues
- ✅ Integration examples (Flink, Spark, Airflow)

**Always Welcome:**
- 📝 Typo fixes and grammar improvements
- 🔗 Updated links and version numbers
- 📊 Diagrams and visual aids
- 🧪 Test cases and validation scripts
- 🌍 Translations to other languages

### Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to:

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the community
- Show empathy towards other contributors

### Recognition

Contributors will be:
- Listed in [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Mentioned in release notes for significant contributions
- Credited in relevant documentation sections

### Getting Help

**Questions about contributing?**
- Join our [Discord community](https://discord.gg/your-invite-link)
- Ask in [GitHub Discussions](https://github.com/<your-username>/kafka-homelab-learning-path/discussions)
- Tag maintainers in your PR for review

**First-time contributor?**
- Look for issues labeled `good-first-issue`
- Check our [Contributing Guide](CONTRIBUTING.md) for detailed instructions
- Don't hesitate to ask questions!

### Review Process

1. **Automated checks**: CI/CD runs linting and validation
2. **Maintainer review**: Usually within 3-5 business days
3. **Feedback cycle**: Address comments and suggestions
4. **Merge**: Once approved, we'll merge your contribution

Thank you for helping make Kafka learning accessible to everyone! 🚀

---

## Community and Support

### Join Our Community

Connect with fellow learners, share your progress, and get help:

#### 💬 Discord Server
Join our active community for:
- Real-time discussions and Q&A
- Homelab setup troubleshooting
- Project collaboration
- Weekly office hours with maintainers

[![Join Discord](https://img.shields.io/badge/Discord-Join%20Server-7289da?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/your-invite-link)

**Channels:**
- `#introductions` - Introduce yourself
- `#general-kafka` - General Kafka discussions
- `#homelab-setup` - Environment and infrastructure help
- `#show-and-tell` - Share your projects
- `#job-opportunities` - Career discussions

#### 🐦 Twitter/X
Follow for updates, tips, and Kafka news:
- [@your_handle](https://twitter.com/your_handle)
- Tweet with `#KafkaHomelab` to share your progress

#### 💼 LinkedIn
Professional networking and career content:
- [LinkedIn Profile](https://linkedin.com/in/your-profile)
- Join the **Kafka Engineers** LinkedIn group

#### 📺 YouTube
Video tutorials and walkthroughs:
- [Your Channel](https://youtube.com/your-channel)
- Subscribe for new content notifications

#### 📧 Newsletter
Monthly updates on:
- New sections and projects
- Kafka ecosystem updates
- Community highlights
- Learning resources

[Subscribe to Newsletter](https://your-newsletter-link.com)

### Get Support

#### GitHub Discussions
For in-depth questions and community knowledge sharing:
- [Ask a Question](https://github.com/<your-username>/kafka-homelab-learning-path/discussions/categories/q-a)
- [Share Ideas](https://github.com/<your-username>/kafka-homelab-learning-path/discussions/categories/ideas)
- [Show Your Work](https://github.com/<your-username>/kafka-homelab-learning-path/discussions/categories/show-and-tell)

#### Office Hours
Live Q&A sessions with maintainers:
- **When**: Every other Friday, 3-4 PM UTC
- **Where**: Discord voice channel
- **Format**: Open discussion, screen sharing, troubleshooting

#### Issue Tracker
For bugs and technical problems:
- [Report a Bug](https://github.com/<your-username>/kafka-homelab-learning-path/issues/new?template=bug_report.md)
- [Request a Feature](https://github.com/<your-username>/kafka-homelab-learning-path/issues/new?template=feature_request.md)

### Contributing to Community

Help others learn:
- Answer questions in Discord
- Review pull requests
- Share your homelab setup
- Write blog posts about your experience
- Create video tutorials

**Active contributors get:**
- Special Discord role and recognition
- Featured in monthly community highlights
- Early access to new content
- Direct mentorship opportunities

---

## Certification Preparation

This learning path aligns with major Kafka certifications and prepares you for professional validation of your skills.

### Confluent Certifications

#### 1. Confluent Certified Developer for Apache Kafka (CCDAK)

**What it covers:**
- Application design with Kafka
- Developing Producers and Consumers
- Kafka Streams and ksqlDB
- Kafka Connect configuration
- Schema Registry and Avro

**How this repo helps:**
- **Section 02**: Core concepts (topics, partitions, offsets)
- **Section 04**: Kafka Streams and Connect projects
- **Section 06**: Real-world application development

**Exam details:**
- **Duration**: 90 minutes
- **Questions**: ~60 multiple choice
- **Passing score**: 70%
- **Cost**: $150 USD
- **Validity**: 2 years

**Preparation roadmap:**
```
Week 1-2:  Complete Sections 00-02 (Fundamentals)
Week 3-4:  Complete Section 04 (Streams & Connect)
Week 5-6:  Build 2-3 projects from Section 06
Week 7:    Review Confluent documentation and practice exams
Week 8:    Take certification exam
```

**Official resources:**
- [CCDAK Exam Guide](https://training.confluent.io/examguide/ccdak)
- [Practice Questions](https://training.confluent.io/page/exam-practice)

#### 2. Confluent Certified Administrator for Apache Kafka (CCAAK)

**What it covers:**
- Kafka cluster deployment
- Managing and monitoring Kafka
- Security configuration (ACLs, encryption)
- Performance tuning
- Troubleshooting and maintenance

**How this repo helps:**
- **Section 01**: Multi-node cluster deployment
- **Section 03**: Operations, monitoring, and admin tasks
- **Section 05**: Security, performance tuning, disaster recovery

**Exam details:**
- **Duration**: 90 minutes
- **Questions**: ~60 multiple choice
- **Passing score**: 70%
- **Cost**: $150 USD
- **Validity**: 2 years

**Preparation roadmap:**
```
Week 1-3:  Complete Sections 01-03 (Installation & Operations)
Week 4-5:  Complete Section 05 (Advanced topics)
Week 6:    Practice cluster failures and recovery scenarios
Week 7:    Set up monitoring with Prometheus/Grafana
Week 8:    Review and take certification exam
```

**Official resources:**
- [CCAAK Exam Guide](https://training.confluent.io/examguide/ccaak)
- [Admin Training Course](https://training.confluent.io/instructor-led-training/apache-kafka-administration-by-confluent)

### Additional Certifications

#### AWS Certified Data Analytics – Specialty

**Kafka-relevant topics:**
- Amazon MSK (Managed Streaming for Kafka)
- Real-time analytics and streaming
- Data lake integration

**How this repo helps:**
- Sections 04 & 06 cover streaming analytics patterns
- ETL project examples applicable to AWS ecosystem

**Study plan add-ons:**
- Complete this homelab, then study AWS MSK specifics
- Practice integrating Kafka with S3, Kinesis, and Redshift

#### Google Cloud Professional Data Engineer

**Kafka-relevant topics:**
- Pub/Sub and streaming architectures
- Dataflow (Apache Beam) integration
- Real-time data pipelines

**How this repo helps:**
- Stream processing fundamentals transfer to Dataflow
- Project 06 includes BigQuery integration examples

### Self-Assessment Checklist

Before taking certifications, ensure you can:

**Developer Track (CCDAK):**
- [ ] Write producers with proper error handling and retries
- [ ] Implement consumers with offset management strategies
- [ ] Design topics considering partitioning and retention
- [ ] Build Kafka Streams applications with stateful processing
- [ ] Configure and deploy Kafka Connect connectors
- [ ] Work with Avro schemas and Schema Registry
- [ ] Implement idempotent producers and exactly-once semantics

**Administrator Track (CCAAK):**
- [ ] Deploy multi-broker clusters across different platforms
- [ ] Configure replication factors and ISR settings
- [ ] Implement SASL/SSL authentication and encryption
- [ ] Set up ACLs for topic and consumer group authorization
- [ ] Monitor cluster health with JMX metrics
- [ ] Troubleshoot under-replicated partitions and lag
- [ ] Perform rolling upgrades without downtime
- [ ] Optimize broker and client configurations for throughput

### Practice Exams and Study Materials

**Free resources:**
- Confluent Developer Skills Assessment (free online)
- Sample questions in Confluent documentation
- Kafka community forums and study groups

**Paid resources:**
- Confluent training courses ($500-1500)
- Udemy practice exams ($20-50)
- O'Reilly learning platform (books + videos)

**Study groups:**
- Join `#certification-prep` in our Discord
- Weekly study sessions announced in community

### Certification Value and ROI

**Career impact:**
- Average salary increase: 10-15% post-certification
- Opens roles: Kafka Developer, Streaming Engineer, Data Platform Engineer
- Demonstrates commitment to prospective employers

**When to certify:**
- After completing this learning path (8-12 weeks)
- With 3-6 months of hands-on Kafka experience
- Before job hunting or promotion discussions

**Cost-benefit analysis:**
- Certification cost: ~$150
- Study time: 60-80 hours
- Typical ROI: Positive within first year through salary gains

---

## Kafka Learning Resources and Reading Path

A curated collection of essential books, blogs, and courses for mastering Apache Kafka, data streaming, and distributed system design.

---

### Core Kafka and Streaming Fundamentals

| Book | Author(s) | Focus |
|---------|--------------|----------|
| **[Kafka: The Definitive Guide](https://www.confluent.io/resources/kafka-the-definitive-guide/)** | Neha Narkhede, Gwen Shapira, Todd Palino | Comprehensive guide to Kafka internals, APIs, and operations |
| **[Designing Data-Intensive Applications](https://dataintensive.net/)** | Martin Kleppmann | Deep dive into distributed data systems and consistency models |
| **[Streaming Systems](https://streamingsystems.net/)** | Tyler Akidau, Slava Chernyak | Theoretical and practical foundations of stream processing |
| **Kafka Security** | Raúl Estrada | Encryption, ACLs, and authentication for Kafka clusters |
| **Mastering Kafka Streams and ksqlDB** | Mitch Seymour | Real-time analytics and stream processing patterns |

---

### Advanced Kafka and Internals

| Resource | Description |
|-------------|----------------|
| **[Kafka in Action](https://www.manning.com/books/kafka-in-action)** | Practical guide for building resilient Kafka pipelines |
| **[Effective Kafka](https://www.manning.com/books/effective-kafka)** — Emil Koutanov | Operational tuning and architecture best practices |
| **[I ♥ Logs](https://queue.acm.org/detail.cfm?id=3220266)** — Jay Kreps | Classic essay on log-based data architectures |
| **[Confluent Blog: Kafka Internals Explained](https://www.confluent.io/blog/)** | Detailed coverage of replication, partitioning, and leader election |

---

### DevOps, Automation, and Observability

| Topic | Recommended Resource |
|----------|--------------------------------|
| **Automation and Infrastructure** | [*Ansible for DevOps*](https://www.ansiblefordevops.com/) — Jeff Geerling |
| **Observability and Metrics** | [*Prometheus: Up & Running*](https://www.oreilly.com/library/view/prometheus-up/9781492034131/) — Brian Brazil |
| **Reliability Engineering** | [*Site Reliability Engineering (SRE)*](https://sre.google/books/) — Google SRE Team |
| **Orchestration** | [*Kubernetes in Action*](https://www.manning.com/books/kubernetes-in-action) — Marko Lukša |

---

### Data Engineering and Real-Time Systems

| Title | Author | Focus |
|----------|------------|----------|
| **[Fundamentals of Data Engineering](https://www.oreilly.com/library/view/fundamentals-of-data/9781098108304/)** | Joe Reis, Matt Housley | Modern data engineering foundations for pipelines and systems |
| **[Designing Event-Driven Systems](https://www.confluent.io/resources/designing-event-driven-systems/)** | Ben Stopford | Event-driven microservices and stream-first design |
| **[Streaming Data](https://www.oreilly.com/library/view/streaming-data/9781491974315/)** | Andrew Psaltis | Integration of Kafka with Spark, Flink, and Beam |
| **[Data Mesh: Delivering Data-Driven Value at Scale](https://www.oreilly.com/library/view/data-mesh/9781492092384/)** | Zhamak Dehghani | Principles of decentralized data ownership and streaming |

---

### Hands-On Labs and Online Courses

| Platform | Course | Link |
|-------------|------------|--------|
| **Confluent Academy** | Developer, Admin, and Streaming Courses | [developer.confluent.io/learn](https://developer.confluent.io/learn) |
| **YouTube (Confluent)** | Kafka Streams, ksqlDB, Connect tutorials | [Confluent YouTube Channel](https://www.youtube.com/c/Confluent) |
| **Udemy** | *Kafka for Beginners* — Stéphane Maarek | [Udemy Course](https://www.udemy.com/course/apache-kafka/) |
| **Aiven and Redpanda Labs** | Kafka playgrounds for experimentation | [Aiven.io](https://aiven.io/) / [Redpanda.com](https://redpanda.com/) |

---

### Blogs, Talks, and Engineering Articles

| Source | Highlight |
|------------|-------------|
| **[The Log: Jay Kreps (LinkedIn Engineering)](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying)** | Classic essay on log-based architecture |
| **[Confluent Blog](https://www.confluent.io/blog/)** | Kafka best practices, real-world use cases, and internal design |
| **[Uber Engineering Blog](https://eng.uber.com/)** | Scaling Kafka for billions of messages per second |
| **[Netflix Tech Blog](https://netflixtechblog.com/)** | Kafka usage patterns at scale and resilience lessons |
| **[LinkedIn Engineering Blog](https://engineering.linkedin.com/blog)** | Origin stories and production challenges |

---

### Practice Projects for Your Kafka Homelab

The following projects are recommended to solidify understanding:

- Build a Kafka Producer-Consumer system using Python or Go
- Set up Prometheus and Grafana dashboards to visualize Kafka metrics
- Deploy a Strimzi Operator-based cluster in Minikube or K3s
- Create a Kafka to BigQuery streaming pipeline with Kafka Connect
- Simulate broker failover, partition rebalancing, and ISR shrinkage
- Integrate Kafka Streams and ksqlDB for real-time analytics
- Implement a real-time fraud detection pipeline using Prefect or Flink

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Kafka Homelab Learning Path** — A structured approach to building streaming systems expertise.

[⭐ Star this repository](https://github.com/<your-username>/kafka-homelab-learning-path) to support the project and stay updated!

---

<div align="center">

**Made with ❤️ by the Kafka learning community**

[Report Bug](https://github.com/<your-username>/kafka-homelab-learning-path/issues) · 
[Request Feature](https://github.com/<your-username>/kafka-homelab-learning-path/issues) · 
[Join Discord](https://discord.gg/your-invite-link)

</div>