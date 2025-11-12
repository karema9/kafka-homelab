#!/bin/bash
# ==========================================================
# Kafka Multi-Broker - ADD BROKER INSTANCE
# ==========================================================
# Run this script for EACH broker you want on this node.
#
# Usage: ./kafka-add-broker.sh <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>
# ==========================================================

set -e

# ----------------------------
# Color/Formatting Variables
# ----------------------------
if [ -t 1 ]; then
    BOLD="\033[1m"
    YELLOW="\033[1;33m"
    GREEN="\033[1;32m"
    BLUE="\033[1;34m"
    RED="\033[1;31m"
    NC="\033[0m" # No Color
else
    BOLD=""
    YELLOW=""
    GREEN=""
    BLUE=""
    RED=""
    NC=""
fi

# ----------------------------
# Variables
# ----------------------------
BROKER_ID=$1
PORT=$2
BROKER_HOSTNAME=$3
ZOOKEEPER_CONNECT=$4

# Base directories from kafka-install-base.sh
INSTALL_DIR="/opt/kafka-test"
USER="kafka-test"
GROUP="kafka-test"

# Instance-specific paths
DATA_DIR="/var/lib/kafka-test-$BROKER_ID"
LOG_DIR="/var/log/kafka-test-$BROKER_ID"
CONFIG_FILE="$INSTALL_DIR/config/server-$BROKER_ID.properties"

# ----------------------------
# Helper Functions
# ----------------------------
usage() {
    echo -e "${RED}❌ ${BOLD}Error: Missing arguments.${NC}"
    echo -e "${RED}Usage: $0 <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>${NC}"
    echo -e "${RED}Example: $0 1 9092 kafka-node1 \"zk1:2181,zk2:2181\"${NC}"
    exit 1
}

if [ -z "$BROKER_ID" ] || [ -z "$PORT" ] || [ -z "$BROKER_HOSTNAME" ] || [ -z "$ZOOKEEPER_CONNECT" ]; then
    usage
fi

echo -e "${BLUE}--- Adding Kafka Broker Instance: ${BOLD}$BROKER_ID${NC}${BLUE} ---${NC}"

# ----------------------------
# 1. Create instance directories
# ----------------------------
echo -e "${YELLOW}[1/3] 📂 Creating directories ${BOLD}$DATA_DIR${NC}${YELLOW} and ${BOLD}$LOG_DIR${NC}...${NC}"
sudo mkdir -p $DATA_DIR $LOG_DIR
sudo chown -R $USER:$GROUP $DATA_DIR $LOG_DIR

# ----------------------------
# 2. Configure instance properties
# ----------------------------
echo -e "${YELLOW}[2/3] 📝 Configuring ${BOLD}$CONFIG_FILE${NC}${YELLOW}...${NC}"
sudo tee $CONFIG_FILE > /dev/null <<EOF
# ==================================
# Config for Broker ID: $BROKER_ID
# Port: $PORT
# Data Dir: $DATA_DIR
# ==================================

broker.id=$BROKER_ID
listeners=PLAINTEXT://$BROKER_HOSTNAME:$PORT
advertised.listeners=PLAINTEXT://$BROKER_HOSTNAME:$PORT
log.dirs=$DATA_DIR

# --- Cluster Settings ---
zookeeper.connect=$ZOOKEEPER_CONNECT
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2
num.partitions=3 # Default partition count for auto-created topics

# --- Performance Tunings ---
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.recovery.threads.per.data.dir=1

# --- Log Retention ---
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
EOF

sudo chown $USER:$GROUP $CONFIG_FILE

# ----------------------------
# 3. Enable and start instance service
# ----------------------------
SERVICE_NAME="kafka@$BROKER_ID.service"
echo -e "${YELLOW}[3/3] 🚀 Enabling and starting ${BOLD}$SERVICE_NAME${NC}${YELLOW}...${NC}"
sudo systemctl enable "kafka@$BROKER_ID" &> /dev/null
sudo systemctl start "kafka@$BROKER_ID"

# ----------------------------
# 4. Final Summary
# ----------------------------
printf "${GREEN}===========================================================\n"
printf "✅ Kafka broker ${BOLD}%s${NC}${GREEN} started successfully!\n" "$BROKER_ID"
printf "-----------------------------------------------------------\n"
printf "  %-14s %s\n" "Port:" "${BOLD}$PORT${NC}"
printf "  %-14s %s\n" "Data dir:" "${BOLD}$DATA_DIR${NC}"
printf "  %-14s %s\n" "Config file:" "${BOLD}$CONFIG_FILE${NC}"
printf "  %-14s %s\n" "Service:" "${BOLD}$SERVICE_NAME${NC}"
printf "===========================================================${NC}\n"#!/bin/bash
# ==========================================================
# Kafka Multi-Broker - ADD BROKER INSTANCE
# ==========================================================
# Run this script for EACH broker you want on this node.
#
# Usage: ./kafka-add-broker.sh <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>
# ==========================================================

set -e

# ----------------------------
# Color/Formatting Variables
# ----------------------------
if [ -t 1 ]; then
    BOLD="\033[1m"
    YELLOW="\033[1;33m"
    GREEN="\033[1;32m"
    BLUE="\033[1;34m"
    RED="\033[1;31m"
    NC="\033[0m" # No Color
else
    BOLD=""
    YELLOW=""
    GREEN=""
    BLUE=""
    RED=""
    NC=""
fi

# ----------------------------
# Variables
# ----------------------------
BROKER_ID=$1
PORT=$2
BROKER_HOSTNAME=$3
ZOOKEEPER_CONNECT=$4

# Base directories from kafka-install-base.sh
INSTALL_DIR="/opt/kafka"
USER="kafka"
GROUP="kafka"

# Instance-specific paths
DATA_DIR="/var/lib/kafka-$BROKER_ID"
LOG_DIR="/var/log/kafka-$BROKER_ID"
CONFIG_FILE="$INSTALL_DIR/config/server-$BROKER_ID.properties"

# ----------------------------
# Helper Functions
# ----------------------------
usage() {
    echo -e "${RED}❌ ${BOLD}Error: Missing arguments.${NC}"
    echo -e "${RED}Usage: $0 <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>${NC}"
    echo -e "${RED}Example: $0 1 9092 kafka-node1 \"zk1:2181,zk2:2181\"${NC}"
    exit 1
}

if [ -z "$BROKER_ID" ] || [ -z "$PORT" ] || [ -z "$BROKER_HOSTNAME" ] || [ -z "$ZOOKEEPER_CONNECT" ]; then
    usage
fi

echo -e "${BLUE}--- Adding Kafka Broker Instance: ${BOLD}$BROKER_ID${NC}${BLUE} ---${NC}"

# ----------------------------
# 1. Create instance directories
# ----------------------------
echo -e "${YELLOW}[1/3] 📂 Creating directories ${BOLD}$DATA_DIR${NC}${YELLOW} and ${BOLD}$LOG_DIR${NC}...${NC}"
sudo mkdir -p $DATA_DIR $LOG_DIR
sudo chown -R $USER:$GROUP $DATA_DIR $LOG_DIR

# ----------------------------
# 2. Configure instance properties
# ----------------------------
echo -e "${YELLOW}[2/3] 📝 Configuring ${BOLD}$CONFIG_FILE${NC}${YELLOW}...${NC}"
sudo tee $CONFIG_FILE > /dev/null <<EOF
# ==================================
# Config for Broker ID: $BROKER_ID
# Port: $PORT
# Data Dir: $DATA_DIR
# ==================================

broker.id=$BROKER_ID
listeners=PLAINTEXT://$BROKER_HOSTNAME:$PORT
advertised.listeners=PLAINTEXT://$BROKER_HOSTNAME:$PORT
log.dirs=$DATA_DIR

# --- Cluster Settings ---
zookeeper.connect=$ZOOKEEPER_CONNECT
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2
num.partitions=3 # Default partition count for auto-created topics

# --- Performance Tunings ---
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.recovery.threads.per.data.dir=1

# --- Log Retention ---
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connection.timeout.ms=18000
group.initial.rebalance.delay.ms=0
EOF

sudo chown $USER:$GROUP $CONFIG_FILE

# ----------------------------
# 3. Enable and start instance service
# ----------------------------
SERVICE_NAME="kafka@$BROKER_ID.service"
echo -e "${YELLOW}[3/3] 🚀 Enabling and starting ${BOLD}$SERVICE_NAME${NC}${YELLOW}...${NC}"
sudo systemctl enable "kafka@$BROKER_ID" &> /dev/null
sudo systemctl start "kafka@$BROKER_ID"

# ----------------------------
# 4. Final Summary
# ----------------------------
printf "${GREEN}===========================================================\n"
printf "✅ Kafka broker ${BOLD}%s${NC}${GREEN} started successfully!\n" "$BROKER_ID"
printf "-----------------------------------------------------------\n"
printf "  %-14s %s\n" "Port:" "${BOLD}$PORT${NC}"
printf "  %-14s %s\n" "Data dir:" "${BOLD}$DATA_DIR${NC}"
printf "  %-14s %s\n" "Config file:" "${BOLD}$CONFIG_FILE${NC}"
printf "  %-14s %s\n" "Service:" "${BOLD}$SERVICE_NAME${NC}"
printf "===========================================================${NC}\n"c