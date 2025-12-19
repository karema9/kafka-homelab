<div align="center">

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║   ██╗  ██╗ █████╗ ███████╗██╗  ██╗ █████╗     ██╗  ██╗ ██████╗ ███╗   ███╗███████╗██╗      █████╗ ██████╗    ║
║   ██║ ██╔╝██╔══██╗██╔════╝██║ ██╔╝██╔══██╗    ██║  ██║██╔═══██╗████╗ ████║██╔════╝██║     ██╔══██╗██╔══██╗   ║
║   █████╔╝ ███████║█████╗  █████╔╝ ███████║    ███████║██║   ██║██╔████╔██║█████╗  ██║     ███████║██████╔╝   ║
║   ██╔═██╗ ██╔══██║██╔══╝  ██╔═██╗ ██╔══██║    ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██║     ██╔══██║██╔══██╗   ║
║   ██║  ██╗██║  ██║██║     ██║  ██╗██║  ██║    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗███████╗██║  ██║██████╔╝   ║
║   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝    ║
║                                                                           ║
║                        LEARNING PATH                                      ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### A comprehensive, hands-on guide to mastering Apache Kafka
**From fundamentals to production-grade distributed systems**

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Kafka](https://img.shields.io/badge/Kafka-3.x-black?logo=apache-kafka&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Dashboard-Grafana-orange?logo=grafana)
![Kubernetes](https://img.shields.io/badge/Kubernetes-blue?logo=kubernetes)
![Ansible](https://img.shields.io/badge/Automation-Ansible-black?logo=ansible)
![Python](https://img.shields.io/badge/Client-Python-blue?logo=python)

</div>

---

## Overview

This repository provides a structured, hands-on curriculum for learning Apache Kafka by building a complete Kafka Homelab environment. The content is designed for engineers seeking to progress from beginner to advanced proficiency in real-world streaming systems architecture and operations.

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

| Section | Focus Area |
|----------|--------|
| `00` | Introduction and Homelab Setup |
| `01` | Installation and Configuration |
| `02` | Core Kafka Concepts |
| `03` | Kafka Operations and Administration |
| `04` | Kafka Streams and Connect |
| `05` | Advanced Topics |
| `06` | Real-world Projects |
| `07` | Books and Learning Resources |

---

## Technology Stack

| Category | Tools |
|-----------|-------|
| **Core Messaging** | Apache Kafka (latest stable release) |
| **Coordination** | Zookeeper / KRaft |
| **Monitoring** | Prometheus, Grafana |
| **Automation** | Ansible |
| **Deployment** | Docker Compose, Kubernetes |
| **Client Development** | Python |
| **Visualization** | Grafana Dashboards |

---

## Getting Started

### Step 1: Clone the Repository

```bash
git clone https://github.com/<your-username>/kafka-homelab-learning-path.git
cd kafka-homelab-learning-path
```

### Step 2: Configure Your Homelab Environment

Begin with the environment setup documentation:
`00-introduction/environment-architecture.md`

Select your preferred deployment method:

- Bare Metal Installation
- Docker Compose Cluster
- Kubernetes (Strimzi Operator)
- Automated Deployment with Ansible

### Step 3: Follow the Sequential Learning Path

Each section builds progressively toward production-grade Kafka expertise and operational proficiency.

---

## Example Use Cases

| Project | Description |
| ---------------------- | --------------------------------------------------------------- |
| Fraud Detection System | Build a Kafka and Python pipeline for real-time anomaly detection |
| Gaming Analytics Platform | Stream and process casino bet events in real-time |
| Infrastructure Observability | Monitor Kafka metrics with Prometheus and Grafana |
| IoT Sensor Data Processing | Process and visualize IoT streams with Kafka Streams |
| ETL Data Pipelines | Ingest CSV or database changes into BigQuery or PostgreSQL |

---

## Contributing

Contributions are welcome and encouraged. If you identify issues, wish to improve documentation, or add exercises, please submit a pull request or open a discussion.

This repository aims to be a community-driven learning resource for data engineers and DevOps practitioners.

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

[Star this repository](https://github.com/<your-username>/kafka-homelab-learning-path) to support the project.
