<div align="center">

# 🧠 Kafka Homelab Learning Path  

A **hands-on journey** to mastering **Apache Kafka** — from fundamentals to real-world, production-grade systems.  
Deploy, automate, monitor, and scale your own **Kafka cluster** using open-source tools.

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Kafka](https://img.shields.io/badge/Kafka-3.x-black?logo=apache-kafka&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Dashboard-Grafana-orange?logo=grafana)
![Kubernetes](https://img.shields.io/badge/Kubernetes-blue?logo=kubernetes)
![Ansible](https://img.shields.io/badge/Automation-Ansible-black?logo=ansible)
![Python](https://img.shields.io/badge/Client-Python-blue?logo=python)

---

</div>

## 📘 Overview

This repository is a **comprehensive, hands-on guide** to learning **Apache Kafka** by building your own **Kafka Homelab**.  
It’s designed for engineers who want to go from **beginner → advanced**, using Kafka in **real-world streaming systems**.

---

## 🎯 Goals

- 🔍 Understand **Kafka architecture and internals**
- 🧩 Deploy Kafka on **bare metal, Docker, Kubernetes, or via Ansible**
- 🛠️ Build, **secure, monitor**, and **scale** Kafka clusters
- 🔗 Work with **Kafka Connect**, **Streams**, and **ksqlDB**
- ⚡ Implement **real-time data projects** (fraud detection, observability, pipelines)
- 🧠 Deep-dive into **Kafka performance tuning** and **troubleshooting**

---

## 🧱 Structure

| Section | Focus |
|----------|--------|
| `00` | Introduction & Homelab Setup |
| `01` | Installation and Configuration |
| `02` | Core Kafka Concepts |
| `03` | Kafka Operations & Administration |
| `04` | Kafka Streams & Connect |
| `05` | Advanced Topics |
| `06` | Real-world Projects |
| `07` | Books & Learning Resources |

---

## 🧰 Tech Stack

| Category | Tools |
|-----------|-------|
| **Core Messaging** | Apache Kafka (latest) |
| **Coordination** | Zookeeper / KRaft |
| **Monitoring** | Prometheus + Grafana |
| **Automation** | Ansible |
| **Deployment** | Docker Compose / Kubernetes |
| **Client Development** | Python |
| **Visualization** | Grafana Dashboards |

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/kafka-homelab-learning-path.git
cd kafka-homelab-learning-path
---
````

### 2️⃣ Set Up Your Homelab

Start with:
📄 `00-introduction/environment-architecture.md`

Choose your preferred setup path:

* ⚙️ Bare Metal Installation
* 🐳 Docker Compose Cluster
* ☸️ Kubernetes (Strimzi Operator)
* 🤖 Automated with Ansible

### 3️⃣ Learn Sequentially

Each section builds progressively toward **production-grade Kafka mastery**.

---

## 💡 Example Use Cases

| Project                | Description                                                     |
| ---------------------- | --------------------------------------------------------------- |
| 🕵️‍♂️ Fraud Detection | Build a Kafka + Python pipeline for real-time anomaly detection |
| 🎮 Gaming Analytics    | Stream and process casino bet events in real-time               |
| 📊 Observability       | Monitor Kafka metrics with Prometheus & Grafana                 |
| 🚦 IoT Sensor Data     | Process and visualize IoT streams with Kafka Streams            |
| 🧾 ETL Pipelines       | Ingest CSV or database changes into BigQuery / PostgreSQL       |

---

## 🌍 Contributing

Contributions are **highly encouraged**!
If you find issues, want to improve docs, or add exercises — open a **PR** or start a **discussion**.

> Let’s make this an open, community-driven learning resource for data engineers and DevOps practitioners.

---

## 📚 Kafka Learning Resources & Reading Path

> A curated list of **essential books, blogs, and courses** for mastering Apache Kafka, data streaming, and distributed system design.  
> Perfect for your **Kafka Homelab** learning journey 🧠⚡.

---

### 🧩 Core Kafka & Streaming Fundamentals

| 📘 Book | ✍️ Author(s) | 🧭 Focus |
|---------|--------------|----------|
| **[Kafka: The Definitive Guide](https://www.confluent.io/resources/kafka-the-definitive-guide/)** | Neha Narkhede, Gwen Shapira, Todd Palino | Complete guide to Kafka’s internals, APIs, and operations. |
| **[Designing Data-Intensive Applications](https://dataintensive.net/)** | Martin Kleppmann | Deep dive into distributed data systems and consistency models. |
| **[Streaming Systems](https://streamingsystems.net/)** | Tyler Akidau, Slava Chernyak | Theoretical and practical foundations of stream processing. |
| **Kafka Security** | Raúl Estrada | Encryption, ACLs, and authentication for Kafka clusters. |
| **Mastering Kafka Streams & ksqlDB** | Mitch Seymour | Real-time analytics and stream processing patterns. |

---

### ⚡ Advanced Kafka & Internals

| 📘 Resource | 🧭 Description |
|-------------|----------------|
| **[Kafka in Action](https://www.manning.com/books/kafka-in-action)** | Practical guide for building resilient Kafka pipelines. |
| **[Effective Kafka](https://www.manning.com/books/effective-kafka)** — Emil Koutanov | Operational tuning and architecture best practices. |
| **[I ♥ Logs](https://queue.acm.org/detail.cfm?id=3220266)** — Jay Kreps | A classic essay on log-based data architectures. |
| **[Confluent Blog: Kafka Internals Explained](https://www.confluent.io/blog/)** | Learn replication, partitioning, and leader election in detail. |

---

### ☸️ DevOps, Automation & Observability

| 🔧 Topic | 📗 Recommended Book / Resource |
|----------|--------------------------------|
| **Automation & Infrastructure** | [*Ansible for DevOps*](https://www.ansiblefordevops.com/) — Jeff Geerling |
| **Observability & Metrics** | [*Prometheus: Up & Running*](https://www.oreilly.com/library/view/prometheus-up/9781492034131/) — Brian Brazil |
| **Reliability Engineering** | [*Site Reliability Engineering (SRE)*](https://sre.google/books/) — Google SRE Team |
| **Orchestration** | [*Kubernetes in Action*](https://www.manning.com/books/kubernetes-in-action) — Marko Lukša |

---

### 🧮 Data Engineering & Real-Time Systems

| 📗 Title | ✍️ Author | 💡 Focus |
|----------|------------|----------|
| **[Fundamentals of Data Engineering](https://www.oreilly.com/library/view/fundamentals-of-data/9781098108304/)** | Joe Reis, Matt Housley | Modern data engineering foundations for pipelines and systems. |
| **[Designing Event-Driven Systems](https://www.confluent.io/resources/designing-event-driven-systems/)** | Ben Stopford | Event-driven microservices and stream-first design. |
| **[Streaming Data](https://www.oreilly.com/library/view/streaming-data/9781491974315/)** | Andrew Psaltis | Integration of Kafka with Spark, Flink, and Beam. |
| **[Data Mesh: Delivering Data-Driven Value at Scale](https://www.oreilly.com/library/view/data-mesh/9781492092384/)** | Zhamak Dehghani | Principles of decentralized data ownership and streaming. |

---

### 🎓 Hands-On Labs & Online Courses

| 🧰 Platform | 📘 Course | 🔗 Link |
|-------------|------------|--------|
| 🧡 **Confluent Academy** | Developer, Admin, and Streaming Courses | [developer.confluent.io/learn](https://developer.confluent.io/learn) |
| 🎥 **YouTube (Confluent)** | Kafka Streams, ksqlDB, Connect tutorials | [Confluent YouTube Channel](https://www.youtube.com/c/Confluent) |
| 🎓 **Udemy** | *Kafka for Beginners* — Stéphane Maarek | [Udemy Course](https://www.udemy.com/course/apache-kafka/) |
| ⚙️ **Aiven & Redpanda Labs** | Kafka playgrounds for experimentation | [Aiven.io](https://aiven.io/) / [Redpanda.com](https://redpanda.com/) |

---

### 📰 Blogs, Talks & Engineering Articles

| 🌐 Source | 🧠 Highlight |
|------------|-------------|
| **[The Log: Jay Kreps (LinkedIn Engineering)](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying)** | Classic essay on log-based architecture. |
| **[Confluent Blog](https://www.confluent.io/blog/)** | Kafka best practices, real-world use cases, and internal design. |
| **[Uber Engineering Blog](https://eng.uber.com/)** | Scaling Kafka for billions of messages per second. |
| **[Netflix Tech Blog](https://netflixtechblog.com/)** | Kafka usage patterns at scale and resilience lessons. |
| **[LinkedIn Engineering Blog](https://engineering.linkedin.com/blog)** | Home of Kafka’s origin stories and production challenges. |

---

### 🧠 Practice Ideas for Your Kafka Homelab

🔥 Try these projects to solidify your knowledge:

- 🧾 Build a **Kafka Producer-Consumer** system using Python or Go.  
- 📈 Set up **Prometheus + Grafana** dashboards to visualize Kafka metrics.  
- ☸️ Deploy a **Strimzi Operator**-based cluster in Minikube or K3s.  
- 💾 Create a **Kafka → BigQuery** streaming pipeline with Kafka Connect.  
- 🧱 Simulate **broker failover, partition rebalancing, ISR shrinkage**.  
- 🧮 Integrate **Kafka Streams + ksqlDB** for real-time analytics.  
- 🔍 Implement a **real-time fraud detection pipeline** using Prefect or Flink. 

---

## 📖 License

This project is licensed under the **[MIT License](LICENSE)**.

---

<div align="center">
Made with ❤️ for learners building streaming systems from scratch.  
<br/>
<a href="https://github.com/<your-username>/kafka-homelab-learning-path">⭐ Star this repo</a> if you find it helpful!
</div>
```

---

