# Kafka Deployment with Ansible

This repository contains Ansible playbooks for deploying Apache Kafka in both **ZooKeeper mode** (legacy) and **KRaft mode** (ZooKeeper-less).

## 📁 Available Playbooks

| Playbook | Mode | Description | Kafka Version |
|----------|------|-------------|---------------|
| `kafka-zookeeper-playbook.yml` | ZooKeeper | Traditional deployment with ZooKeeper cluster | 2.x - 3.x |
| `kafka-kraft-playbook.yml` | KRaft | Modern ZooKeeper-less deployment | 3.0+ |

## 🎯 Features

### Common Features (Both Modes)
- **Clean Install**: Automatically detects and removes existing installations
- **Production Ready**: Configurable replication, retention, and networking
- **Idempotent**: Can be run multiple times safely
- **Multi-Node Support**: High availability clustering

### KRaft Mode Specific
- **No ZooKeeper Required**: Simplified architecture with built-in Raft consensus
- **Flexible Deployment**: Supports combined, controller-only, or broker-only nodes
- **Faster Recovery**: Metadata stored directly in Kafka
- **Future-Proof**: Official replacement for ZooKeeper mode

### ZooKeeper Mode Specific
- **Battle-Tested**: Proven in production for years
- **Wide Compatibility**: Works with all Kafka 2.x and 3.x versions
- **Mature Tooling**: Extensive community tools and monitoring support

## ⚖️ ZooKeeper vs KRaft: Which Should You Choose?

| Criteria | ZooKeeper Mode | KRaft Mode | Recommendation |
|----------|----------------|------------|----------------|
| **Kafka Version** | 2.x - 3.x | 3.0+ | KRaft for new deployments |
| **Architecture** | Kafka + ZooKeeper cluster | Kafka only | KRaft (simpler) |
| **Services to Manage** | 2 (Kafka + ZooKeeper) | 1 (Kafka) | KRaft (easier ops) |
| **Metadata Storage** | External ZooKeeper | Built-in Raft | KRaft (faster) |
| **Recovery Time** | Slower | Faster | KRaft |
| **Production Ready** | ✅ Very mature | ⚠️ Mature (since Kafka 3.3) | ZooKeeper for conservative |
| **Community Support** | Extensive | Growing rapidly | Either (good support) |
| **Future Support** | Deprecated (will be removed) | Official future | KRaft (forward-compatible) |
| **Migration Path** | Can migrate to KRaft | N/A | Start with KRaft if possible |

**Quick Decision Guide**:
- **New deployment?** → Use KRaft (simpler, faster, future-proof)
- **Must use Kafka 2.x?** → Use ZooKeeper (no choice)
- **Risk-averse production?** → Use ZooKeeper (more battle-tested) but plan KRaft migration
- **Need simplest operations?** → Use KRaft (one less system to manage)

## 📋 Prerequisites

- Ansible 2.9+
- Ubuntu 20.04/22.04 or Debian-based systems (adaptable to RHEL/CentOS)
- SSH access to target nodes
- Sudo privileges on target nodes
- Java 11 or higher (installed automatically)
- Minimum 3 nodes for high availability

## 🚀 Quick Start

Choose your deployment mode:

### Option A: KRaft Mode (Recommended for New Deployments)

#### 1. Update Inventory File

Edit `kafka-inventory.ini`:

```ini
[kafka]
kafka-node-1 ansible_host=192.168.1.101 broker_id=1 kafka_ip=192.168.1.101 node_role=combined
kafka-node-2 ansible_host=192.168.1.102 broker_id=2 kafka_ip=192.168.1.102 node_role=combined
kafka-node-3 ansible_host=192.168.1.103 broker_id=3 kafka_ip=192.168.1.103 node_role=combined
```

**Important**: Replace the IP addresses with your actual server IPs. If using cloud VMs you can use the external IPs or assigned tunnel IPs if you are using a VPN such as Tailscale or OpenVPN.

#### 2. Update kafka_nodes Variable

In `kafka-kraft-playbook.yml`, update the `kafka_nodes` list:

```yaml
kafka_nodes:
  - { id: 1, host: 192.168.1.101 }
  - { id: 2, host: 192.168.1.102 }
  - { id: 3, host: 192.168.1.103 }
```

#### 3. Run the KRaft Playbook

```bash
# Deploy to all nodes
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml

# Deploy to specific node
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml --limit kafka-node-1

# Dry run (check mode)
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml --check

# Verbose output
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml -vvv
```

---

### Option B: ZooKeeper Mode (Legacy/Compatible)

#### 1. Update Inventory File

Edit `kafka-zookeeper-inventory.ini`:

```ini
[kafka]
kafka-node-1 ansible_host=192.168.1.101 broker_id=1 kafka_ip=192.168.1.101
kafka-node-2 ansible_host=192.168.1.102 broker_id=2 kafka_ip=192.168.1.102
kafka-node-3 ansible_host=192.168.1.103 broker_id=3 kafka_ip=192.168.1.103
```

#### 2. Update zookeeper_servers Variable

In `kafka-zookeeper-playbook.yml`, update the `zookeeper_servers` list:

```yaml
zookeeper_servers:
  - { id: 1, host: 192.168.1.101 }
  - { id: 2, host: 192.168.1.102 }
  - { id: 3, host: 192.168.1.103 }
```

#### 3. Run the ZooKeeper Playbook

```bash
# Deploy to all nodes (ZooKeeper + Kafka)
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml

# Deploy to specific node
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml --limit kafka-node-1

# Deploy only ZooKeeper
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml --tags zookeeper

# Deploy only Kafka
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml --tags kafka

# Dry run (check mode)
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml --check
```

---

## 🔄 Switching Between Modes

### Migrating from ZooKeeper to KRaft

```bash
# Step 1: Backup your data
# (Topic data, configurations, etc.)

# Step 2: Run KRaft playbook (it will automatically cleanup ZooKeeper)
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml

# Step 3: Verify cluster is healthy
# (See verification section below)

# Step 4: Restore your topics/data as needed
```

**Note**: The KRaft playbook automatically detects and removes ZooKeeper installations, so you can safely switch modes.

### Rolling Back to ZooKeeper

```bash
# Simply run the ZooKeeper playbook
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml

# It will cleanup the KRaft installation and deploy ZooKeeper mode
```

## 🏗️ Architecture Options

### KRaft Mode Architecture

#### Option 1: Combined Nodes (Recommended for Small-Medium Clusters)

Each node runs both controller and broker:

```yaml
node_role: combined
```

```
┌─────────────────────────────────────┐
│  Node 1 (Combined)                  │
│  ├── Controller (port 9093)         │
│  └── Broker (port 9092)             │
└─────────────────────────────────────┘
         ↕ Raft Consensus
┌─────────────────────────────────────┐
│  Node 2 (Combined)                  │
│  ├── Controller (port 9093)         │
│  └── Broker (port 9092)             │
└─────────────────────────────────────┘
         ↕ Raft Consensus
┌─────────────────────────────────────┐
│  Node 3 (Combined)                  │
│  ├── Controller (port 9093)         │
│  └── Broker (port 9092)             │
└─────────────────────────────────────┘
```

**Pros**: Simple, fewer nodes, good for < 10 brokers  
**Cons**: Less isolation, controller and broker share resources

#### Option 2: Dedicated Controllers (Recommended for Large Clusters)

Separate controller quorum from broker nodes:

```yaml
# Controllers
node_role: controller

# Brokers  
node_role: broker
```

```
┌─────────────────────────────────────┐
│  Controllers (3 nodes)              │
│  ├── Controller 1 (port 9093)       │
│  ├── Controller 2 (port 9093)       │
│  └── Controller 3 (port 9093)       │
│      (Raft Quorum)                  │
└─────────────────────────────────────┘
              ↓
    ┌─────────────────────┐
    │  Metadata Updates   │
    └─────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Brokers (N nodes)                  │
│  ├── Broker 1 (port 9092)           │
│  ├── Broker 2 (port 9092)           │
│  ├── Broker 3 (port 9092)           │
│  └── Broker N (port 9092)           │
└─────────────────────────────────────┘
```

**Pros**: Better isolation, controllers unaffected by broker load  
**Cons**: More nodes required (3 controllers + N brokers)

---

### ZooKeeper Mode Architecture

Traditional deployment with separate ZooKeeper ensemble:

```
┌─────────────────────────────────────┐
│  ZooKeeper Ensemble (3 nodes)       │
│  ├── ZooKeeper 1 (port 2181)        │
│  ├── ZooKeeper 2 (port 2181)        │
│  └── ZooKeeper 3 (port 2181)        │
│      (ZAB Consensus)                │
└─────────────────────────────────────┘
              ↓
    ┌─────────────────────┐
    │  Cluster Metadata   │
    └─────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Kafka Brokers (3 nodes)            │
│  ├── Broker 1 (port 9092)           │
│  │     + ZooKeeper 1                │
│  ├── Broker 2 (port 9092)           │
│  │     + ZooKeeper 2                │
│  └── Broker 3 (port 9092)           │
│        + ZooKeeper 3                │
└─────────────────────────────────────┘
```

**Services per node**: 2 (Kafka + ZooKeeper)  
**Ports**: 2181 (ZooKeeper), 9092 (Kafka)  
**Pros**: Proven, mature, works with all Kafka versions  
**Cons**: More complex, additional service to manage

## 📊 Deployment Flow

### KRaft Mode Deployment

The playbook executes in this order:

```
1. CLEANUP
   ├── Stop existing Kafka/ZooKeeper services
   ├── Remove systemd service files
   ├── Backup and delete installation directories
   └── Clean data/log directories

2. PREREQUISITES
   └── Install Java, wget, tar, uuid-runtime

3. DIRECTORY STRUCTURE
   ├── Create installation directory
   ├── Create log directory
   └── Create KRaft metadata directory

4. KAFKA INSTALLATION
   ├── Download Kafka tarball
   ├── Extract to installation directory
   ├── Create symlink to current version
   └── Set ownership and permissions

5. KRAFT CONFIGURATION
   ├── Generate cluster UUID (once)
   ├── Configure server.properties for KRaft
   └── Set up listeners and security

6. STORAGE FORMATTING
   └── Initialize KRaft metadata directory

7. SERVICE SETUP
   ├── Create systemd service file
   └── Enable and start Kafka service

8. VERIFICATION
   ├── Wait for ports to be ready (9092, 9093)
   └── Display cluster information
```

### ZooKeeper Mode Deployment

The playbook executes in this order:

```
1. CLEANUP (if applicable)
   ├── Stop existing services
   └── Remove old installations

2. PREREQUISITES
   └── Install Java, wget, tar

3. DIRECTORY STRUCTURE
   ├── Create installation directory
   ├── Create Kafka log directory
   └── Create ZooKeeper data directory

4. KAFKA INSTALLATION
   ├── Download Kafka tarball
   ├── Extract to installation directory
   └── Set ownership and permissions

5. ZOOKEEPER CONFIGURATION
   ├── Configure zookeeper.properties
   ├── Set up cluster members
   └── Create myid file (unique per node)

6. KAFKA CONFIGURATION
   ├── Configure server.properties
   ├── Set ZooKeeper connection string
   └── Configure broker settings

7. SERVICE SETUP
   ├── Create ZooKeeper systemd service
   ├── Create Kafka systemd service
   └── Set service dependencies

8. SERVICE STARTUP
   ├── Start ZooKeeper (wait for port 2181)
   └── Start Kafka (wait for port 9092)

9. VERIFICATION
   └── Verify both services are running
```

## ⚙️ Configuration Variables

### Required Variables (in inventory or playbook)

| Variable | Description | Example |
|----------|-------------|---------|
| `broker_id` | Unique node ID | `1`, `2`, `3` |
| `kafka_ip` | Node's IP address | `192.168.1.101` |
| `node_role` | Node role | `combined`, `controller`, `broker` |
| `kafka_install_dir` | Installation path | `/opt/kafka` |
| `kafka_log_dir` | Data directory | `/var/lib/kafka/logs` |
| `kraft_metadata_dir` | Metadata directory | `/var/lib/kafka/kraft-metadata` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `kraft_cluster_uuid` | Cluster UUID | Auto-generated |
| `kafka_download_url` | Download URL | Apache mirror |
| `kafka_artifact` | Kafka version | `kafka_2.13-3.6.1` |

## 🔍 Verification

### KRaft Mode Verification

#### Check Service Status

```bash
# On each node
systemctl status kafka

# View logs
journalctl -u kafka -f
```

#### Verify Cluster Metadata

```bash
# Connect to any node
ssh kafka-node-1

# View cluster metadata
/opt/kafka/current/bin/kafka-metadata.sh \
  --snapshot /var/lib/kafka/kraft-metadata/__cluster_metadata-0/00000000000000000000.log \
  --print-contents
```

#### List Cluster Nodes

```bash
# Describe cluster (requires topic creation first)
/opt/kafka/current/bin/kafka-metadata.sh \
  --snapshot /var/lib/kafka/kraft-metadata/__cluster_metadata-0/00000000000000000000.log \
  --print-contents | grep BrokerRegistration
```

---

### ZooKeeper Mode Verification

#### Check Service Status

```bash
# Check both services on each node
systemctl status zookeeper
systemctl status kafka

# View logs
journalctl -u zookeeper -f
journalctl -u kafka -f
```

#### Verify ZooKeeper Cluster

```bash
# Check ZooKeeper cluster status
echo stat | nc localhost 2181

# Check if node is leader or follower
echo srvr | nc localhost 2181

# List ZooKeeper nodes
/opt/kafka/current/bin/zookeeper-shell.sh localhost:2181 <<< "ls /brokers/ids"
```

#### Verify Kafka Brokers

```bash
# List brokers via ZooKeeper
/opt/kafka/current/bin/zookeeper-shell.sh localhost:2181 <<< "ls /brokers/ids"

# Get broker details
/opt/kafka/current/bin/zookeeper-shell.sh localhost:2181 <<< "get /brokers/ids/1"
```

---

### Common Verification (Both Modes)

#### Create Test Topic

```bash
# Create a topic
/opt/kafka/current/bin/kafka-topics.sh \
  --create \
  --topic test-topic \
  --bootstrap-server 192.168.1.101:9092 \
  --partitions 3 \
  --replication-factor 3

# List topics
/opt/kafka/current/bin/kafka-topics.sh \
  --list \
  --bootstrap-server 192.168.1.101:9092

# Describe topic
/opt/kafka/current/bin/kafka-topics.sh \
  --describe \
  --topic test-topic \
  --bootstrap-server 192.168.1.101:9092
```

#### Test Producer/Consumer

```bash
# Terminal 1: Producer
/opt/kafka/current/bin/kafka-console-producer.sh \
  --topic test-topic \
  --bootstrap-server 192.168.1.101:9092

# Terminal 2: Consumer
/opt/kafka/current/bin/kafka-console-consumer.sh \
  --topic test-topic \
  --from-beginning \
  --bootstrap-server 192.168.1.101:9092
```

#### Check Broker API Versions

```bash
# Works for both modes
/opt/kafka/current/bin/kafka-broker-api-versions.sh \
  --bootstrap-server 192.168.1.101:9092
```

## 🔧 Common Issues & Solutions

### KRaft Mode Issues

#### Issue 1: Cluster UUID Mismatch

**Symptom**: Nodes can't join cluster, logs show UUID mismatch

**Solution**: 
1. Stop all Kafka services
2. Delete metadata directories on all nodes
3. Ensure `kraft_cluster_uuid` is consistent (or empty for auto-generation)
4. Re-run playbook

```bash
# On each node
sudo systemctl stop kafka
sudo rm -rf /var/lib/kafka/kraft-metadata/*
```

#### Issue 2: Controller Quorum Issues

**Symptom**: Controllers can't form quorum

**Solution**: Verify `controller.quorum.voters` in config

```bash
# Check configuration
cat /opt/kafka/current/config/kraft/server.properties | grep controller.quorum.voters

# Should show all controller nodes:
# controller.quorum.voters=1@192.168.1.101:9093,2@192.168.1.102:9093,3@192.168.1.103:9093

# Verify network connectivity
nc -zv 192.168.1.101 9093
```

---

### ZooKeeper Mode Issues

#### Issue 1: ZooKeeper Cluster Not Forming

**Symptom**: ZooKeeper nodes can't connect to each other

**Solution**: Check firewall and network connectivity

```bash
# Verify ports are open
sudo ufw status
sudo ufw allow 2181/tcp
sudo ufw allow 2888/tcp
sudo ufw allow 3888/tcp

# Test connectivity between nodes
nc -zv 192.168.1.101 2181
nc -zv 192.168.1.101 2888
nc -zv 192.168.1.101 3888

# Check ZooKeeper status
echo stat | nc localhost 2181
```

#### Issue 2: Incorrect myid File

**Symptom**: ZooKeeper fails to start, logs show duplicate server ID

**Solution**: Verify myid matches broker_id

```bash
# Check myid file
cat /var/lib/zookeeper/myid
# Should match broker_id in inventory (1, 2, or 3)

# If incorrect, fix it
echo "1" | sudo tee /var/lib/zookeeper/myid
sudo systemctl restart zookeeper
```

#### Issue 3: Kafka Can't Connect to ZooKeeper

**Symptom**: Kafka fails to start, logs show ZooKeeper connection errors

**Solution**: Verify ZooKeeper connection string

```bash
# Check Kafka configuration
cat /opt/kafka/current/config/server.properties | grep zookeeper.connect

# Should show all ZooKeeper nodes:
# zookeeper.connect=192.168.1.101:2181,192.168.1.102:2181,192.168.1.103:2181

# Test ZooKeeper connectivity
/opt/kafka/current/bin/zookeeper-shell.sh localhost:2181 ls /
```

---

### Common Issues (Both Modes)

#### Issue 1: Port Already in Use

**Symptom**: Kafka fails to start, port 9092 or 9093 in use

**Solution**: Check for zombie processes

```bash
# Find process using port
sudo lsof -i :9092
sudo lsof -i :9093

# Kill if necessary
sudo kill -9 <PID>
```

#### Issue 2: Permission Denied

**Symptom**: Kafka can't write to log/metadata directories

**Solution**: Check ownership and permissions

```bash
# Fix ownership
sudo chown -R ubuntu:ubuntu /opt/kafka
sudo chown -R ubuntu:ubuntu /var/lib/kafka

# Fix permissions
sudo chmod -R 755 /var/lib/kafka
```

#### Issue 3: Out of Memory / JVM Issues

**Symptom**: Kafka crashes, OutOfMemoryError in logs

**Solution**: Tune JVM heap settings

```bash
# Edit systemd service file
sudo nano /etc/systemd/system/kafka.service

# Add environment variables:
Environment="KAFKA_HEAP_OPTS=-Xmx2G -Xms2G"

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart kafka
```

#### Issue 4: Disk Space Full

**Symptom**: Kafka stops accepting writes

**Solution**: Check disk usage and retention policies

```bash
# Check disk space
df -h /var/lib/kafka

# Reduce retention if needed
# Edit server.properties:
log.retention.hours=24  # Default is 168 (7 days)

# Force log cleanup
/opt/kafka/current/bin/kafka-log-dirs.sh \
  --bootstrap-server localhost:9092 \
  --describe
```

## 🔄 Upgrading Kafka

### Upgrading KRaft Mode

To upgrade to a new Kafka version:

1. Update `kafka_artifact` and `kafka_download_url` in inventory
2. Run playbook - it will automatically cleanup old version
3. Services will be restarted with new version

```yaml
# In kafka-inventory.ini [kafka:vars]
kafka_artifact=kafka_2.13-3.7.0
kafka_download_url=https://downloads.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz
```

```bash
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml
```

### Upgrading ZooKeeper Mode

Same process as KRaft:

```yaml
# In kafka-zookeeper-inventory.ini [kafka:vars]
kafka_artifact=kafka_2.13-3.6.2
kafka_download_url=https://downloads.apache.org/kafka/3.6.2/kafka_2.13-3.6.2.tgz
```

```bash
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml
```

### Rolling Upgrade (Production)

For zero-downtime upgrades:

```bash
# Upgrade one node at a time
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml --limit kafka-node-1
# Wait and verify cluster is healthy
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml --limit kafka-node-2
# Wait and verify cluster is healthy
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml --limit kafka-node-3
```

## 🧹 Complete Cleanup

### KRaft Mode Cleanup

The KRaft playbook does this automatically, but you can also run manually:

```bash
# Stop services
sudo systemctl stop kafka
sudo systemctl disable kafka

# Remove files
sudo rm -rf /opt/kafka
sudo rm -rf /var/lib/kafka
sudo rm /etc/systemd/system/kafka.service
sudo systemctl daemon-reload
```

### ZooKeeper Mode Cleanup

The ZooKeeper playbook cleanup, or run manually:

```bash
# Stop services
sudo systemctl stop kafka
sudo systemctl stop zookeeper
sudo systemctl disable kafka
sudo systemctl disable zookeeper

# Remove files
sudo rm -rf /opt/kafka
sudo rm -rf /var/lib/kafka
sudo rm -rf /var/lib/zookeeper
sudo rm /etc/systemd/system/kafka.service
sudo rm /etc/systemd/system/zookeeper.service
sudo systemctl daemon-reload
```

### Complete Cluster Reset

To reset entire cluster (all nodes):

```bash
# Stop all services on all nodes
ansible kafka -i kafka-inventory.ini -b -m systemd -a "name=kafka state=stopped"
ansible kafka -i kafka-inventory.ini -b -m systemd -a "name=zookeeper state=stopped"

# Remove all data directories
ansible kafka -i kafka-inventory.ini -b -m file -a "path=/opt/kafka state=absent"
ansible kafka -i kafka-inventory.ini -b -m file -a "path=/var/lib/kafka state=absent"
ansible kafka -i kafka-inventory.ini -b -m file -a "path=/var/lib/zookeeper state=absent"

# Re-run desired playbook
ansible-playbook -i kafka-inventory.ini kafka-kraft-playbook.yml
# OR
ansible-playbook -i kafka-zookeeper-inventory.ini kafka-zookeeper-playbook.yml
```

## 📊 Monitoring

### Key Metrics to Monitor

```bash
# Check broker registration
/opt/kafka/current/bin/kafka-broker-api-versions.sh \
  --bootstrap-server 192.168.1.101:9092

# Check controller status
curl -s http://192.168.1.101:9092/metrics | grep kafka_controller

# Monitor JVM memory
ps aux | grep kafka
```

### Integration with Monitoring Tools

- **Prometheus**: Use JMX Exporter
- **Grafana**: Import Kafka dashboards
- **ELK**: Ship Kafka logs to Elasticsearch

## 🔐 Security Considerations

This playbook uses PLAINTEXT for simplicity. For production:

### Enable SASL/SCRAM Authentication

```yaml
# Add to server.properties
sasl.enabled.mechanisms=SCRAM-SHA-256
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256
listeners=SASL_PLAINTEXT://{{ kafka_ip }}:9092
```

### Enable SSL/TLS

```yaml
# Add to server.properties  
listeners=SSL://{{ kafka_ip }}:9093
ssl.keystore.location=/path/to/keystore.jks
ssl.keystore.password=changeit
```

## 📝 Best Practices

### General Best Practices (Both Modes)

1. **Use odd number of nodes** (3, 5, 7) for quorum/consensus
2. **Separate data directories** from OS partition
3. **Monitor disk space** - Kafka logs can grow quickly
4. **Set retention policies** appropriate for your use case
5. **Backup metadata** regularly for disaster recovery
6. **Use dedicated networks** for inter-broker traffic
7. **Tune JVM heap** based on workload (default: system dependent)

### KRaft-Specific Best Practices

1. **Combined mode** for clusters < 10 brokers
2. **Dedicated controllers** for clusters > 10 brokers
3. **Store cluster UUID** securely - needed for disaster recovery
4. **Monitor controller quorum** health (requires majority)
5. **Fast storage for metadata** - SSDs recommended

### ZooKeeper-Specific Best Practices

1. **Dedicate ZooKeeper nodes** in large deployments
2. **Tune ZooKeeper JVM** separately from Kafka
3. **Monitor ZooKeeper ensemble** health separately
4. **Set up ZooKeeper snapshots** for backups
5. **Plan migration to KRaft** (ZooKeeper deprecated)

---

## 🎯 Quick Command Reference

### Useful Kafka Commands (Both Modes)

```bash
# Topic Management
kafka-topics.sh --bootstrap-server localhost:9092 --list
kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test --partitions 3 --replication-factor 3
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic test
kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic test

# Consumer Groups
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

# Performance Testing
kafka-producer-perf-test.sh --topic test --num-records 1000000 --record-size 1000 --throughput -1 --producer-props bootstrap.servers=localhost:9092
kafka-consumer-perf-test.sh --topic test --messages 1000000 --threads 1 --broker-list localhost:9092

# Configuration
kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name test --describe
kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-default --describe
```

### KRaft-Specific Commands

```bash
# Generate cluster UUID
kafka-storage.sh random-uuid

# Format storage
kafka-storage.sh format -t <UUID> -c config/kraft/server.properties

# View metadata
kafka-metadata.sh --snapshot /var/lib/kafka/kraft-metadata/__cluster_metadata-0/00000000000000000000.log --print-contents

# Check controller
kafka-metadata.sh --snapshot /var/lib/kafka/kraft-metadata/__cluster_metadata-0/00000000000000000000.log --print-contents | grep Controller
```

### ZooKeeper-Specific Commands

```bash
# ZooKeeper shell
zookeeper-shell.sh localhost:2181

# Inside ZooKeeper shell:
ls /
ls /brokers/ids
get /controller
get /brokers/ids/1

# ZooKeeper status
echo stat | nc localhost 2181
echo mntr | nc localhost 2181
echo ruok | nc localhost 2181
```

---

## 🆘 Support

- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [KRaft Mode Guide](https://kafka.apache.org/documentation/#kraft)
- [ZooKeeper Documentation](https://zookeeper.apache.org/doc/current/)
- [Ansible Documentation](https://docs.ansible.com/)

---

## 📊 Feature Comparison Summary

| Feature | ZooKeeper Mode | KRaft Mode |
|---------|----------------|------------|
| **Setup Complexity** | Medium (2 services) | Low (1 service) |
| **Operational Complexity** | High | Medium |
| **Recovery Speed** | Slower | Faster |
| **Scaling Limits** | 200k partitions | 1M+ partitions |
| **Metadata Latency** | Higher (external) | Lower (internal) |
| **Future Support** | Deprecated | Active development |
| **Community Tools** | Extensive | Growing |
| **Migration Path** | Can migrate to KRaft | N/A |
| **Recommended For** | Legacy/Conservative | New deployments |

---

## 📄 License

MIT License - feel free to use and modify

---

**Repository Structure**:
```
.
├── kafka-kraft-playbook.yml        # KRaft mode playbook
├── kafka-zookeeper-playbook.yml    # ZooKeeper mode playbook
├── kafka-inventory.ini             # KRaft inventory example
├── kafka-zookeeper-inventory.ini   # ZooKeeper inventory example
└── README.md                       # This file
```

**Author**: Kafka Deployment Automation  
**Last Updated**: February 2026  
**Kafka Version Support**: 2.x - 3.x (ZooKeeper), 3.0+ (KRaft)