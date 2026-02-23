# Docker Compose Improvement Worksheet

## 📋 Instructions

This worksheet identifies areas for improvement in your `docker-compose.yml` file. Work through each section, implementing the changes and checking off items as you complete them. Some sections require you to research and implement solutions independently.

---

## 🎯 Category 1: Configuration Management

### Issues Identified:
- [ ] **Duplicated environment variables** across all three Kafka nodes
- [ ] **No YAML anchors** used to reduce repetition
- [ ] **Hardcoded values** (cluster ID, replication factors) that should be variables
- [ ] **Missing environment variable file** (.env) for easy customization

### Your Implementation:

**What to research:**
- How to use YAML anchors (`x-*` and `<<:`) in Docker Compose
- How to extract common configurations
- How to use `.env` files with Docker Compose

**Space for your solution:**
```yaml
# Write your YAML anchor solution here:








```

**Verification command:**
```bash
# How will you verify your changes work?

```

---

## 🎯 Category 2: Data Persistence & Volumes

### Issues Identified:
- [ ] **Bind mounts** used instead of named volumes for Kafka data
- [ ] **No named volume** for Prometheus data (data will be lost on container removal)
- [ ] **Missing volume** for Grafana plugins/provisioning

### Your Implementation:

**Questions to answer:**
1. What's the difference between bind mounts and named volumes?
   ```
   
   
   ```

2. When should you use bind mounts vs named volumes?
   ```
   
   
   ```

**Create volume definitions:**
```yaml
volumes:
  # Define your named volumes here:




```

---

## 🎯 Category 3: Network Configuration - [OPTIONAL]

### Issues Identified:
- [ ] **No custom subnet** defined for the network
- [ ] **No static IP addresses** assigned to brokers
- [ ] **Missing network aliases** for easier service discovery
- [ ] **No network isolation** between services

### Your Implementation:

**Research topics:**
- Docker Compose network subnets and IPAM
- When to use static IPs vs service discovery
- Network isolation best practices

**Design your network:**
```yaml
networks:
  kafka-network:
    # Complete the network configuration:




```

**Document your IP addressing scheme:**
```
Service          | IP Address    | Purpose
-----------------|---------------|------------------
kafka-node1      |               |
kafka-node2      |               |
kafka-node3      |               |
prometheus       |               |
grafana          |               |
kafka-ui         |               |
```

---

## 🎯 Category 4: External Client Access

### Issues Identified:
- [ ] **No PLAINTEXT_HOST listener** for external clients
- [ ] **Listener configuration** doesn't support both internal and external access
- [ ] **Advertised listeners** only configured for internal Docker network
- [ ] **Missing documentation** on how to connect from host machine

### Your Implementation:

**Problem to solve:**
How can a producer/consumer running on your host machine (not in Docker) connect to the Kafka cluster?

**Research:**
- Kafka listener configuration (PLAINTEXT vs PLAINTEXT_HOST)
- How advertised.listeners work
- Port mapping strategies

**Your listener configuration:**
```yaml
# For kafka-node1:
KAFKA_LISTENERS: 
KAFKA_ADVERTISED_LISTENERS: 
```

**Connection test plan:**
```bash
# How will you test connection from host?





```

---

## 🎯 Category 5: Health Checks & Reliability

### Issues Identified:
- [ ] **Insufficient start_period** (40s may not be enough for slower systems)
- [ ] **Low retry count** (3 retries might be insufficient)
- [ ] **No restart policy** defined (containers won't auto-restart on failure)
- [ ] **Missing dependency health checks** (services start without waiting for dependencies)

### Your Implementation:

**Tune health check parameters:**

| Parameter | Current | Recommended | Your Choice | Reasoning |
|-----------|---------|-------------|-------------|-----------|
| interval  | 30s     | ?           |             |           |
| timeout   | 10s     | ?           |             |           |
| retries   | 3       | ?           |             |           |
| start_period | 40s  | ?           |             |           |

**Define restart policies:**
```yaml
# What restart policy will you use and why?
restart: 




```

**Implement dependency health checks:**
```yaml
# Example for Grafana depending on Prometheus:
depends_on:
  prometheus:
    # What condition should you use?
```

---

## 🎯 Category 6: Performance Tuning

### Issues Identified:
- [ ] **Missing JVM heap size configuration** (using defaults)
- [ ] **No network thread configuration**
- [ ] **No I/O thread tuning**
- [ ] **Missing socket buffer size settings**
- [ ] **No log segment or retention configuration**

### Your Implementation:

**Research questions:**
1. What factors determine appropriate heap size for Kafka brokers?
   ```
   
   
   ```

2. How many network threads should you configure?
   ```
   
   
   ```

**Your performance configuration:**
```yaml
environment:
  # JVM Settings
  KAFKA_HEAP_OPTS: 
  
  # Network Threading
  KAFKA_NUM_NETWORK_THREADS: 
  KAFKA_NUM_IO_THREADS: 
  
  # Buffer Sizes
  KAFKA_SOCKET_SEND_BUFFER_BYTES: 
  KAFKA_SOCKET_RECEIVE_BUFFER_BYTES: 
  
  # Log Configuration
  KAFKA_LOG_RETENTION_HOURS: 
  KAFKA_LOG_SEGMENT_BYTES: 
```

**Justification for your choices:**
```
Heap Size: 


Network Threads: 


I/O Threads: 


```

---

## 🎯 Category 7: Monitoring & Observability

### Issues Identified:
- [ ] **JMX ports not exposed** to host for direct access
- [ ] **No Prometheus data retention** configured
- [ ] **Missing Grafana provisioning** for datasources/dashboards
- [ ] **No alerting configuration**
- [ ] **Kafka UI missing JMX metrics integration**

### Your Implementation:

**Expose JMX metrics:**
```yaml
# How will you expose JMX exporter ports?
ports:



```

**Configure Prometheus retention:**
```yaml
# Add Prometheus retention settings:
command:



```

**Set up Grafana auto-provisioning:**
```
Directory structure needed:
configs/grafana/
├── provisioning/
│   ├── datasources/
│   │   └── ________________  (what file?)
│   └── dashboards/
│       └── ________________  (what file?)
```

**Create datasource provisioning file:**
```yaml
# configs/grafana/provisioning/datasources/prometheus.yml
# Write the configuration:






```

---

## 🎯 Category 8: Security Hardening

### Issues Identified:
- [ ] **Default Grafana password** (admin/admin) is insecure
- [ ] **No authentication** on Kafka brokers
- [ ] **No TLS/SSL encryption** configured
- [ ] **Containers running as root**
- [ ] **No secrets management**

### Your Implementation:

**Implement Grafana security:**
```yaml
environment:
  GF_SECURITY_ADMIN_PASSWORD: 
  # What other security settings should you add?



```

**Plan for Kafka security:**
```
Authentication mechanism to implement:


Encryption approach:


Timeline for implementation:
```

**Non-root user configuration:**
```yaml
# How will you run containers as non-root?
user: 
```

---

## 🎯 Category 9: Resource Limits

### Issues Identified:
- [ ] **No CPU limits** defined
- [ ] **No memory limits** set
- [ ] **No disk I/O limits** configured
- [ ] **Risk of resource contention** between containers

### Your Implementation:

**Define resource limits:**
```yaml
# For kafka-node1:
deploy:
  resources:
    limits:
      cpus: 
      memory: 
    reservations:
      cpus: 
      memory: 
```

**Calculate total resources needed:**
```
Component       | CPU (cores) | Memory (GB) | Total
----------------|-------------|-------------|-------
kafka-node1     |             |             |
kafka-node2     |             |             |
kafka-node3     |             |             |
prometheus      |             |             |
grafana         |             |             |
kafka-ui        |             |             |
----------------|-------------|-------------|-------
TOTAL REQUIRED  |             |             |

Your available resources:
Total CPU: _______
Total Memory: _______

Are resources sufficient? [ ] Yes [ ] No
```

---

## 🎯 Category 10: Service Dependencies & Startup Order

### Issues Identified:
- [ ] **Simple depends_on** doesn't wait for service readiness
- [ ] **No startup orchestration** for optimal cluster formation
- [ ] **Missing init containers** or startup scripts
- [ ] **Kafka UI starts before brokers are fully ready**

### Your Implementation:

**Implement proper dependency management:**
```yaml
# For kafka-ui:
depends_on:
  kafka-node1:
    condition: 
  kafka-node2:
    condition: 
  kafka-node3:
    condition: 
```

**Design startup sequence:**
```
1. ________________ (which services start first?)
2. ________________
3. ________________
4. ________________
5. ________________
6. ________________

Reasoning:



```

---

## 🎯 Category 11: Logging Configuration

### Issues Identified:
- [ ] **No logging driver** specified
- [ ] **No log rotation** configured
- [ ] **Unlimited log storage** (can fill disk)
- [ ] **No centralized logging** strategy

### Your Implementation:

**Configure logging:**
```yaml
logging:
  driver: 
  options:
    max-size: 
    max-file: 
```

**Research question:**
What are the different logging drivers available in Docker and when would you use each?
```




```

---

## 🎯 Category 12: Labels & Metadata

### Issues Identified:
- [ ] **No labels** for organization
- [ ] **Missing metadata** about cluster purpose/environment
- [ ] **No version tracking** in labels
- [ ] **Difficult to filter/query** containers

### Your Implementation:

**Design labeling strategy:**
```yaml
labels:
  com.kafka.cluster: 
  com.kafka.environment: 
  com.kafka.version: 
  com.kafka.component: 
  # What other labels would be useful?


```

**How will you use these labels?**
```bash
# Write commands to filter containers by label:




```

---

## 🎯 Category 13: Optional Services

### Issues Identified:
- [ ] **No Schema Registry** for schema management
- [ ] **No Kafka Connect** for data integration
- [ ] **No ksqlDB** for stream processing
- [ ] **No REST Proxy** for HTTP access

### Your Implementation:

**Priority ranking:**
Which optional services should you add first and why?

```
1. ________________
   Reason: 


2. ________________
   Reason: 


3. ________________
   Reason: 
```

**Schema Registry configuration template:**
```yaml
schema-registry:
  image: 
  ports:
  environment:
    SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: 
    # What other settings are required?



```

---

## 🎯 Category 14: Environment Variables & Secrets

### Issues Identified:
- [ ] **Hardcoded passwords** in docker-compose.yml
- [ ] **No .env file** for environment-specific values
- [ ] **No .env.example** for documentation
- [ ] **Secrets in version control** (security risk)

### Your Implementation:

**Create .env file structure:**
```bash
# .env
# What variables should be extracted?





```

**Create .env.example:**
```bash
# .env.example
# Document each variable:





```

**Update docker-compose.yml to use variables:**
```yaml
environment:
  KAFKA_HEAP_OPTS: ${KAFKA_HEAP_OPTS:-}
  # Convert other hardcoded values:



```

---

## 🎯 Category 15: Documentation & Maintenance

### Issues Identified:
- [ ] **No inline comments** explaining configuration choices
- [ ] **Missing version information** in compose file
- [ ] **No upgrade path** documented
- [ ] **No rollback procedure** defined

### Your Implementation:

**Add section comments:**
```yaml
# ==============================================================================
# SECTION NAME
# ==============================================================================
# Purpose: 
# Dependencies: 
# Configuration notes: 
# ==============================================================================
```

**Document upgrade procedure:**
```
Steps to upgrade Kafka version:
1. 
2. 
3. 
4. 
5. 
```

**Document rollback procedure:**
```
Steps to rollback if upgrade fails:
1. 
2. 
3. 
4. 
```

---

## ✅ Final Checklist

### Before considering complete:
- [ ] All environment variables extracted to .env file
- [ ] YAML anchors implemented to reduce duplication
- [ ] Named volumes created for all persistent data
- [ ] Health checks tuned and tested
- [ ] Resource limits defined based on available resources
- [ ] Network properly configured with subnet
- [ ] External client access tested and working
- [ ] Monitoring stack fully operational
- [ ] Grafana datasources auto-provisioned
- [ ] Security hardening implemented (at minimum: strong passwords)
- [ ] Logging configured with rotation
- [ ] Labels added for organization
- [ ] Documentation complete with inline comments
- [ ] .env.example created for team members
- [ ] Tested complete teardown and recreation
- [ ] Verified backup and restore procedures

### Validation Tests:
- [ ] `docker-compose config` validates without errors
- [ ] All services start and become healthy
- [ ] External client can produce/consume messages
- [ ] Grafana dashboards display metrics
- [ ] Broker failover tested successfully
- [ ] Performance meets baseline requirements

---

## 📊 Self-Assessment

Rate your understanding (1-5, where 5 is expert):

| Topic | Before | After | Notes |
|-------|--------|-------|-------|
| YAML anchors | __ | __ | |
| Docker volumes | __ | __ | |
| Network configuration | __ | __ | |
| Kafka listeners | __ | __ | |
| Health checks | __ | __ | |
| JVM tuning | __ | __ | |
| Monitoring setup | __ | __ | |
| Security basics | __ | __ | |
| Resource limits | __ | __ | |

---

## 🎓 Reflection Questions

**What was the most challenging improvement?**
```



```

**What would you do differently next time?**
```



```

**What additional improvements would you make given more time?**
```



```

**How will you maintain this configuration going forward?**
```



```

---

**Completion Date:** _______________

**Total Time Spent:** _______________

**Ready for Production?** [ ] Yes [ ] No [ ] Needs more work

**Next Steps:** _____________________________________