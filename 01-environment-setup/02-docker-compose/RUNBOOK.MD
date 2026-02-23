# Kafka Cluster Operator Handbook

### Three-Node KRaft Cluster (Docker-Based Lab)

> **This is not a tutorial.**
> This handbook exists to train operators. If you run these commands without understanding what they mean, you are practicing typing — not engineering.

---

## 0️⃣ Operating Model

This lab simulates:

- 3-node Kafka cluster
- KRaft (no ZooKeeper)
- Replication factor = 3
- Multi-partition topics
- Prometheus + Grafana monitoring
- Failure simulation via Docker

**Rules of Engagement.** All commands assume you are inside a broker container:

```bash
docker exec -it kafka-node1 bash
unset KAFKA_OPTS
```

Or executed from outside:

```bash
docker exec -it kafka-node1 bash -c "unset KAFKA_OPTS; <command>"
```

> **Always use container hostnames:** `kafka-node1:9092`, `kafka-node2:9092`, `kafka-node3:9092`. Never `localhost`. Kafka binds to its container hostname — `localhost` resolves to nothing inside the container.

---

## 1️⃣ Cluster Awareness First (Before Touching Anything)

### Broker Reachability

```bash
kafka-broker-api-versions \
  --bootstrap-server kafka-node1:9092,kafka-node2:9092,kafka-node3:9092
```

All brokers must respond before you proceed.

### KRaft Quorum Status

```bash
kafka-metadata-quorum \
  --bootstrap-server kafka-node1:9092 describe --status
```

Look for: **Leader**, **Voters**, **High Watermark**, and **Lag**.

> **Operator Action:** If the quorum is unstable, stop everything else. You cannot safely operate on a cluster with a split brain.

### Under-Replicated Partitions

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --describe --under-replicated-partitions
```

**Expectation:** Should return nothing in a healthy state. Any output here is a signal that action is required.

### Unavailable Partitions

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --describe --unavailable-partitions
```

**Expectation:** Empty. If partitions appear here, they have no leader and are offline for reads and writes.

---

## 2️⃣ Topic Operations (State Control Layer)

### List Topics

```bash
kafka-topics --bootstrap-server kafka-node1:9092 --list
```

### Create a Production-Grade Topic

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --create \
  --topic orders \
  --partitions 6 \
  --replication-factor 3
```

> **Design Rule:** Partitions = parallelism. Replication = durability. Plan partition count before producing — you cannot reduce it later.

### Inspect Partition State

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --describe --topic orders
```

**Interpret the output:**

| Field | Meaning |
|---|---|
| **Leader** | The broker handling reads/writes for this partition |
| **Replicas** | All brokers holding a copy of this partition |
| **ISR** | Brokers fully caught up to the leader (In-Sync Replicas) |

> **Operator Action:** If `ISR < Replicas`, you have replication lag or a dead node. Investigate immediately.

### Describe All Topics

```bash
kafka-topics --bootstrap-server kafka-node1:9092 --describe
```

### Increase Partitions

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --alter --topic orders --partitions 12
```

> **Warning:** You can only increase partitions, never decrease. Plan before producing.

### Delete a Topic

```bash
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --delete --topic orders
```

---

## 3️⃣ Producer Operations

### Interactive Producer

```bash
kafka-console-producer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders
```

Type messages and press Enter to send. `Ctrl+C` to exit.

### Producer with Keys

```bash
kafka-console-producer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --property "parse.key=true" \
  --property "key.separator=:"
```

Input format: `key:value`. Keys determine which partition a message lands on.

### Idempotent Producer (Mandatory in Production)

```bash
kafka-console-producer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --producer-property enable.idempotence=true
```

**Guarantees:**
- No duplicates on retries
- Partition ordering preserved

### Throughput Test — Controlled Rate

```bash
kafka-producer-perf-test \
  --topic orders \
  --num-records 100000 \
  --record-size 1000 \
  --throughput 1000 \
  --producer-props bootstrap.servers=kafka-node1:9092
```

### Throughput Test — Stress (Unlimited)

```bash
kafka-producer-perf-test \
  --topic orders \
  --num-records 500000 \
  --record-size 1000 \
  --throughput -1 \
  --producer-props bootstrap.servers=kafka-node1:9092
```

> **Observe in Grafana:** Watch Bytes In/sec, CPU spikes, and network saturation during this test.

---

## 4️⃣ Consumer Operations

### Consume from the Beginning

```bash
kafka-console-consumer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --from-beginning
```

### Consume with Keys and Timestamps

```bash
kafka-console-consumer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --from-beginning \
  --property print.key=true \
  --property key.separator=":" \
  --property print.timestamp=true
```

### Consume a Fixed Number of Messages

```bash
kafka-console-consumer \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --max-messages 20
```

### Consumer Performance Test

```bash
kafka-consumer-perf-test \
  --bootstrap-server kafka-node1:9092 \
  --topic orders \
  --messages 100000 \
  --group perf-consumer-group
```

### Inspect Consumer Group Lag

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 \
  --describe --group orders-consumer
```

> **Formula:** `Lag = log_end_offset − committed_offset`
> If lag is growing continuously, your consumers are not keeping up with producers. Scale consumers or investigate processing bottlenecks.

### List All Consumer Groups

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 --list
```

### Describe All Consumer Groups

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 --all-groups --describe
```

### Reset Offsets to Earliest (Re-consume Everything)

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 \
  --group orders-consumer \
  --topic orders \
  --reset-offsets --to-earliest --execute
```

> **Operator Action:** Never run without understanding the downstream replay impact. Every message will be re-processed.

### Reset Offsets to Latest (Skip Backlog)

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 \
  --group orders-consumer \
  --topic orders \
  --reset-offsets --to-latest --execute
```

### Delete a Consumer Group

```bash
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 \
  --delete --group orders-consumer
```

The group must be inactive (no running consumers) before deletion.

---

## 5️⃣ Configuration Management

### Inspect Topic Config Overrides

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --describe --entity-type topics --entity-name orders
```

### Inspect Broker Config

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --describe --entity-type brokers --entity-name 1
```

### Set Retention to 1 Hour

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --alter --entity-type topics --entity-name orders \
  --add-config retention.ms=3600000
```

### Set Max Message Size to 5MB

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --alter --entity-type topics --entity-name orders \
  --add-config max.message.bytes=5242880
```

### Enable Log Compaction

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --alter --entity-type topics --entity-name orders \
  --add-config cleanup.policy=compact
```

Use cases: CDC (Change Data Capture), state topics, idempotent pipelines.

### Delete a Config Override (Revert to Broker Default)

```bash
kafka-configs \
  --bootstrap-server kafka-node1:9092 \
  --alter --entity-type topics --entity-name orders \
  --delete-config retention.ms
```

---

## 6️⃣ Failure Simulation (Mandatory Training)

> If you don't break it, you don't understand it.

### Drill 1 — Kill a Broker

```bash
docker stop kafka-node2
```

1. Run the under-replicated partitions command — observe ISR shrink
2. Watch leader re-election happen across affected partitions
3. Recover: `docker start kafka-node2`
4. Watch ISR expand as the broker catches up

### Drill 2 — Kill the Active Controller

Check which broker is the active controller first:

```bash
kafka-metadata-quorum --bootstrap-server kafka-node1:9092 describe --status
```

Then stop that broker. Observe controller re-election and metadata stability during the handover. Confirm a new controller is elected before proceeding.

### Drill 3 — Network Partition (Split Brain Simulation)

Disconnect a broker from the Docker network without killing the container:

```bash
# Disconnect
docker network disconnect kafka-network kafka-node3

# Observe: node is running but isolated
# Watch the quorum adjust and clients route around the failure

# Reconnect
docker network connect kafka-network kafka-node3

# Watch the sync process and ISR recovery
```

> This is the most important drill. A process that is alive but unreachable is more dangerous than one that is dead.

---

## 7️⃣ Partition Reassignment (Scaling Exercise)

### Step 1 — Prepare Topics File

Create `topics.json`:

```json
{
  "topics": [{ "topic": "orders" }],
  "version": 1
}
```

### Step 2 — Generate Reassignment Plan

```bash
kafka-reassign-partitions \
  --bootstrap-server kafka-node1:9092 \
  --generate \
  --topics-to-move-json-file topics.json \
  --broker-list "1,2,3"
```

Save the generated output as `reassignment.json`.

### Step 3 — Execute

```bash
kafka-reassign-partitions \
  --bootstrap-server kafka-node1:9092 \
  --execute \
  --reassignment-json-file reassignment.json
```

### Step 4 — Verify

```bash
kafka-reassign-partitions \
  --bootstrap-server kafka-node1:9092 \
  --verify \
  --reassignment-json-file reassignment.json
```

---

## 8️⃣ Log & Offset Inspection (Storage Layer)

### Get Latest Offsets Per Partition

```bash
kafka-get-offsets \
  --bootstrap-server kafka-node1:9092 \
  --topic orders
```

### Get Earliest Offsets Per Partition

```bash
kafka-get-offsets \
  --bootstrap-server kafka-node1:9092 \
  --topic orders --time earliest
```

### Inspect Raw Log Segment

```bash
kafka-dump-log \
  --files /var/lib/kafka/data/orders-0/00000000000000000000.log \
  --print-data-log
```

### Inspect Offset Index

```bash
kafka-dump-log \
  --files /var/lib/kafka/data/orders-0/00000000000000000000.index
```

### Inspect Cluster Metadata Log (KRaft)

```bash
kafka-dump-log \
  --cluster-metadata-log \
  --files /var/lib/kafka/data/__cluster_metadata-0/00000000000000000000.log
```

> **Core Concept:** This is where Kafka ceases to be a black box and becomes what it truly is — distributed, append-only disk storage with index-based offset lookup.

---

## 9️⃣ Leader Election

### Trigger Preferred Leader Election (All Partitions)

```bash
kafka-leader-election \
  --bootstrap-server kafka-node1:9092 \
  --election-type preferred --all-topic-partitions
```

Run this after recovering a broker to restore the preferred (original) leader distribution and reduce load imbalance.

---

## 🔟 Security Layer (ACL Awareness)

Even in a lab, understand access control exists.

### List All ACLs

```bash
kafka-acls \
  --bootstrap-server kafka-node1:9092 \
  --list
```

### Grant Producer Permission

```bash
kafka-acls \
  --bootstrap-server kafka-node1:9092 \
  --add \
  --allow-principal User:app1 \
  --operation Write \
  --topic orders
```

### Grant Consumer Permission

```bash
kafka-acls \
  --bootstrap-server kafka-node1:9092 \
  --add \
  --allow-principal User:app1 \
  --operation Read \
  --topic orders \
  --group orders-consumer
```

---

## 1️⃣1️⃣ Observability Layer

### Minimum Metrics to Monitor at All Times

| Signal | Expectation | Implication if Wrong |
|---|---|---|
| **Active Controller** | Always = 1 | If 0 or 2+, quorum is broken |
| **Under-Replicated Partitions** | Always = 0 | Nodes are slow or dead |
| **ISR Shrinks** | Rare events | Network partition or extreme IOPS lag |
| **Bytes In/sec** | Varies with load | Correlates directly with disk write IO |
| **Consumer Lag** | Trending toward 0 | If climbing continuously, scale consumers |

### Key PromQL Queries for Grafana

```promql
# Messages in per second
rate(kafka_server_brokertopicmetrics_messagesinpersec_count[5m])

# Bytes in per second
rate(kafka_server_brokertopicmetrics_bytesinpersec_count[5m])

# Bytes out per second
rate(kafka_server_brokertopicmetrics_bytesoutpersec_count[5m])

# Active controller (must always equal 1)
kafka_controller_kafkacontroller_activecontrollercount

# Under-replicated partitions (must always equal 0)
kafka_server_replicamanager_underreplicatedpartitions

# Disk usage per topic
sum by (topic) (kafka_log_log_size)

# Consumer lag
kafka_consumer_consumer_fetch_manager_metrics_records_lag
```

---

## 1️⃣2️⃣ Operator Health Checklist

Run this diagnostic sequence in order to verify total cluster health:

```bash
# 1. All brokers reachable?
kafka-broker-api-versions \
  --bootstrap-server kafka-node1:9092,kafka-node2:9092,kafka-node3:9092

# 2. Quorum stable?
kafka-metadata-quorum \
  --bootstrap-server kafka-node1:9092 describe --status

# 3. Any under-replicated partitions?
kafka-topics \
  --bootstrap-server kafka-node1:9092 \
  --describe --under-replicated-partitions

# 4. Any consumer groups falling behind?
kafka-consumer-groups \
  --bootstrap-server kafka-node1:9092 --all-groups --describe
```

All commands returning clean output = healthy cluster.

---

## 1️⃣3️⃣ Engineering Drills (Required Competencies)

Every operator should be able to perform these without referring to documentation:

- [ ] Recover from sudden broker failure without data loss
- [ ] Explain ISR mechanics and why ISR < Replicas is dangerous
- [ ] Perform a live partition reassignment across brokers
- [ ] Diagnose the exact root cause of growing consumer lag
- [ ] Interpret KRaft quorum status output line by line
- [ ] Read and inspect raw segment files on disk
- [ ] Run a throughput stress test and identify the bottleneck in Grafana
- [ ] Tune retention policies safely without data loss
- [ ] Simulate a network partition and observe quorum behaviour
- [ ] Reset consumer offsets and explain the downstream impact

> **If you cannot do these under pressure, you are not operating Kafka — you are just using Kafka.**

---

## 🛑 Final Principle

Kafka is not a messaging queue.

It is a **distributed log** with leader election, quorum consensus, replication guarantees, and failure recovery semantics.

Treat it like infrastructure. Operate it like infrastructure. **Break it until you understand it.**

---

*Kafka Cluster Operator Handbook — Three-Node KRaft Lab*