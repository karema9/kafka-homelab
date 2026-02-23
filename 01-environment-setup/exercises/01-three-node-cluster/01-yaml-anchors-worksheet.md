

---

# YAML Anchors — Enhanced Practical Worksheet

## Overview

**Estimated Time:** 90–120 minutes
**Difficulty:** Intermediate
**Prerequisites:**

* Basic YAML syntax
* Working knowledge of Docker Compose
* Familiarity with containerized services (Kafka preferred but not required)

This worksheet is designed as a **hands-on, production-oriented guide** to YAML anchors. It emphasizes correctness, maintainability, and real-world usage patterns—particularly in Docker Compose–based infrastructure.

---

## Learning Objectives

By completing this worksheet, you will be able to:

* Explain YAML anchors, aliases, and merge keys, and why they exist
* Use anchors to eliminate duplication in Docker Compose configurations
* Safely combine anchors with overrides using nested merge patterns
* Debug anchor-related issues using Compose tooling
* Apply design judgment to determine when anchors improve or harm maintainability
* Refactor a production-grade Kafka cluster configuration using best practices

---

## Quick Reference

### YAML Anchor Operators

| Operator | Name      | Purpose                               | Example             |
| -------- | --------- | ------------------------------------- | ------------------- |
| `&`      | Anchor    | Define a reusable configuration block | `&service_defaults` |
| `*`      | Alias     | Reference an anchor                   | `*service_defaults` |
| `<<`     | Merge Key | Merge anchor contents into a mapping  | `<<: *defaults`     |

**Important Rule:**
YAML merge keys perform **shallow merges only**. Nested mappings are replaced, not merged.

---

## Section 1: Conceptual Understanding

### 1.1 Problem Identification

**Scenario:**
You are running a three-node Kafka cluster. Each broker shares identical configuration.

```yaml
kafka-node1:
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network
  environment:
    KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
    KAFKA_NUM_IO_THREADS: 8
    KAFKA_LOG_RETENTION_HOURS: 168

kafka-node2:
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network
  environment:
    KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
    KAFKA_NUM_IO_THREADS: 8
    KAFKA_LOG_RETENTION_HOURS: 168

kafka-node3:
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network
  environment:
    KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
    KAFKA_NUM_IO_THREADS: 8
    KAFKA_LOG_RETENTION_HOURS: 168
```

**Questions**

1. What specific problems does this duplication create?

   ```
   1.
   2.
   3.
   ```

2. If `KAFKA_HEAP_OPTS` must change to 2G, how many places require editing?

   ```
   Answer:
   ```

3. What risks arise if one node is not updated correctly?

   ```
   ```

---

### 1.2 Core Definitions

Define each term in your own words and include a real-world analogy.

**Anchor (`&anchor-name`)**

```
Definition:

Analogy:
```

**Alias (`*anchor-name`)**

```
Definition:

Analogy:
```

**Merge Key (`<<: *anchor-name`)**

```
Definition:

Analogy:
```

---

### 1.3 Knowledge Check (True / False)

Mark T or F and explain your reasoning.

**1.3.1** YAML anchors are evaluated at runtime by Docker Compose

```
Answer:
Reasoning:
```

**1.3.2** Anchors can only be defined at the top level of a YAML file

```
Answer:
Reasoning:
```

**1.3.3** Merged anchor values can be overridden

```
Answer:
Reasoning:
```

**1.3.4** Anchors improve runtime performance

```
Answer:
Reasoning:
```

---

## Section 2: Basic Anchor Mechanics

### 2.1 Simple Anchor Usage

```yaml
x-logging-defaults: &logging_config
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

services:
  web:
    image: nginx
    logging: *logging_config

  api:
    image: api:latest
    logging: *logging_config
```

**Questions**

1. What is the fully expanded configuration for `web`?

   ```yaml
   ```

2. How many logging configurations exist after parsing?

   ```
   Answer:
   Explanation:
   ```

3. What happens if you add `compress: "true"` to the anchor?

   ```
   ```

---

### 2.2 Exercise: Create a Reusable Health Check

**Requirements**

* Anchor name: `x-healthcheck-defaults`
* Interval: `30s`
* Timeout: `10s`
* Retries: `3`
* Start period: `40s`

```yaml
# Define the anchor:


services:
  database:
    image: postgres:16
    # Apply the health check

  cache:
    image: redis:7
    # Apply the health check
```

**Validation Command**

```bash
```

---

## Section 3: Merge Key Deep Dive

### 3.1 Shallow Merge Behavior

```yaml
x-base: &base
  image: kafka:latest
  environment:
    KAFKA_HEAP_OPTS: "-Xms512M -Xmx512M"
    KAFKA_LOG_DIRS: /data

kafka-node1:
  <<: *base
  environment:
    KAFKA_BROKER_ID: 1
```

**Questions**

1. Final `environment` map:

   ```yaml
   ```

2. Did `KAFKA_HEAP_OPTS` survive? Why?

   ```
   ```

3. Is this behavior a bug or a feature?

   ```
   ```

---

### 3.2 Exercise: Fix the Shallow Merge

```yaml
x-kafka-common: &kafka_base
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  environment:
    KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
    KAFKA_NUM_IO_THREADS: 8

kafka-node1:
  <<: *kafka_base
  environment:
    KAFKA_NODE_ID: 1
```

**Solution 1: Nested Anchors**

```yaml
```

**Solution 2: Explicit Merge**

```yaml
```

**Preferred Solution and Rationale**

```
```

---

## Section 4: Nested Anchors (Production Pattern)

### 4.1 Two-Level Anchor Pattern

```yaml
x-kafka-env: &kafka_env
  KAFKA_HEAP_OPTS: "-Xms1G -Xmx1G"
  KAFKA_NUM_IO_THREADS: 8
  KAFKA_LOG_RETENTION_HOURS: 168

x-kafka-common: &kafka_common
  image: confluentinc/cp-kafka:7.8.0
  restart: unless-stopped
  networks:
    - kafka-network

kafka-node1:
  <<: *kafka_common
  environment:
    <<: *kafka_env
    KAFKA_NODE_ID: 1
```

**Questions**

1. Why separate environment variables from service defaults?
2. What advantage does this pattern provide?
3. Describe the merge flow step-by-step.

---

## Section 5: Docker Compose Patterns

### 5.1 Merging Multiple Anchors

```yaml
x-service-defaults: &service_defaults
  restart: unless-stopped
  deploy:
    resources:
      limits:
        memory: 1g

x-logging: &logging
  logging:
    driver: json-file
    options:
      max-size: "10m"

web:
  <<: *service_defaults
  <<: *logging
  image: nginx
```

**Questions**

* Merge precedence rules
* Conflict resolution behavior
* Hands-on test with overlapping keys

---

## Section 6: Debugging and Validation

### 6.1 Predict vs Actual Output

```yaml
x-base: &base
  a: 1
  b: 2
  c:
    nested: true

test:
  <<: *base
  b: 99
  d: 4
```

**Predicted Output**

```yaml
```

**Actual Output (`docker compose config`)**

```yaml
```

**Comparison**

```
Matched? Yes / No
Explanation:
```

---

## Section 7: Design Judgment

### 7.1 When to Use Anchors

| Scenario                            | Assessment | Reason |
| ----------------------------------- | ---------- | ------ |
| Identical services                  |            |        |
| Single shared property              |            |        |
| Shared logging across many services |            |        |
| Deep nesting used once              |            |        |

---

## Section 8: Real-World Kafka Refactoring

### Objective

Refactor a real Kafka cluster configuration by:

* Identifying duplication
* Designing a clean anchor hierarchy
* Preserving clarity and debuggability

(Original configuration omitted here for brevity — use your provided example.)

**Metrics**

```
Original lines:
Refactored lines:
Reduction (%):
```

---

## Additional Resources

### Official Documentation

* YAML 1.2 Specification — Anchors and Aliases
  [https://yaml.org/spec/1.2/spec.html#id2765878](https://yaml.org/spec/1.2/spec.html#id2765878)

* Docker Compose Extension Fields
  [https://docs.docker.com/compose/compose-file/11-extension/](https://docs.docker.com/compose/compose-file/11-extension/)

### Practice

* Refactor an existing `docker-compose.yml`
* Study anchor usage in open-source Compose files
* Maintain a personal anchor pattern library

---

## Completion Checklist

* Completed conceptual sections
* Implemented all exercises
* Validated with `docker compose config`
* Refactored a real configuration
* Can explain anchors clearly to others

---


