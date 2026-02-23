#!/bin/bash
# ==========================================================
# Kafka Multi-Broker - ADD BROKER INSTANCE (TEST)
# ==========================================================
# Run this script for EACH broker you want on this node.
#
# Usage: ./kafka-add-broker-TEST.sh <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>
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
    CYAN="\033[1;36m"
    RED="\033[1;31m"
    NC="\033[0m" # No Color
else
    BOLD=""
    YELLOW=""
    GREEN=""
    BLUE=""
    CYAN=""
    RED=""
    NC=""
fi

# ----------------------------
# Header
# ----------------------------
echo -e "${CYAN}"
cat << "EOF"
          __         __                                      
         /\_\       /\ \__                                   
 __  __ /\/_/   _ __\ \ ,_\  __  __    ___     ____    ___  
/\ \/\ \  /\ \ /\`'__\ \ \/ /\ \/\ \  / __\`\  /',__\  / __\`\\
\ \ \_/ | \ \ \\ \ \/ \ \ \_\ \ \_\ \/\ \L\ \/\__, \`\/\ \L\ \\
 \ \___/   \ \_\\ \_\  \ \__\\ \____/\ \____/\/\____/\ \____/
  \/__/     \/_/ \/_/   \/__/ \/___/  \/___/  \/___/  \/___/ 
EOF
echo -e "${BOLD}==================== V I R T U O S O   H O M E L A B ====================${NC}"
echo

# ----------------------------
# Variables
# ----------------------------
BROKER_ID=$1
PORT=$2
BROKER_HOSTNAME=$3
ZOOKEEPER_CONNECT=$4

# Base directories from kafka-install-base-TEST.sh
INSTALL_DIR="/opt/kafka-test"
USER="kafka-test"
GROUP="kafka-test"

# Instance-specific paths
DATA_DIR="/var/lib/kafka-test-$BROKER_ID"
LOG_DIR="/var/log/kafka-test-$BROKER_ID"
CONFIG_FILE="$INSTALL_DIR/config/server-$BROKER_ID.properties"
SERVICE_NAME="kafka-test@$BROKER_ID" # CRITICAL FIX: Must match the test template name

# ----------------------------
# Helper Functions
# ----------------------------
usage() {
    echo -e "${RED}✗ ${BOLD}Error: Missing arguments.${NC}"
    echo
    echo -e "${YELLOW}Usage: $0 <BROKER_ID> <PORT> <BROKER_HOSTNAME> <ZOOKEEPER_CONNECT>${NC}"
    echo -e "${CYAN}Example: $0 90 19092 kafka-node1 \"zk1:2181,zk2:2181\"${NC}"
    exit 1
}

if [ -z "$BROKER_ID" ] || [ -z "$PORT" ] || [ -z "$BROKER_HOSTNAME" ] || [ -z "$ZOOKEEPER_CONNECT" ]; then
    usage
fi

echo -e "${BLUE}--- Adding Kafka Broker Instance: ${BOLD}${BROKER_ID}${NC} (Port: ${BOLD}${PORT}${NC}${BLUE}) ---${NC}"
echo

# ----------------------------
# 1. Create instance directories
# ----------------------------
echo -e "${YELLOW}[1/4] 📂 Creating directories...${NC}"
sudo mkdir -p $DATA_DIR $LOG_DIR
sudo chown -R $USER:$GROUP $DATA_DIR $LOG_DIR
echo -e "${GREEN} ✓ Directories created and permissions set.${NC}"

# ----------------------------
# 2. Configure instance properties
# ----------------------------
echo -e "${YELLOW}[2/4] 📝 Configuring ${BOLD}$CONFIG_FILE${NC}${YELLOW}...${NC}"
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
echo -e "${GREEN} ✓ Broker configuration written.${NC}"

# ----------------------------
# 3. Enable and start instance service
# ----------------------------
echo -e "${YELLOW}[3/4] 🚀 Enabling and starting ${BOLD}$SERVICE_NAME.service${NC}${YELLOW}...${NC}"
sudo systemctl enable "${SERVICE_NAME}.service" &> /dev/null
sudo systemctl start "${SERVICE_NAME}.service"
echo -e "${GREEN} ✓ Service started via systemd.${NC}"

# ----------------------------
# 4. ✨ NEW: Verify service status
# ----------------------------
echo -e "${YELLOW}[4/4] 🩺 Verifying service status...${NC}"
sleep 1 # Give the service a moment to start
if systemctl is-active --quiet "$SERVICE_NAME.service"; then
    echo -e "${GREEN} ✓ Service is active and running.${NC}"
else
    echo -e "${RED}✗ ${BOLD}Service failed to start!${NC}"
    echo -e "${RED}   Please check logs for errors:${NC}"
    echo -e "${RED}   ${BOLD}journalctl -u $SERVICE_NAME.service -n 50${NC}"
    exit 1
fi

# ----------------------------
# 5. Final Summary
# ----------------------------
echo
printf "${CYAN}${BOLD}===========================================================\n"
printf "${GREEN} ✅ Kafka broker ${BOLD}%s${NC}${GREEN} is ready!${NC}\n" "$BROKER_ID"
printf "${CYAN}-----------------------------------------------------------\n${NC}"
printf "  %-14s %s\n" "Broker ID:" "${BOLD}$BROKER_ID${NC}"
printf "  %-14s %s\n" "Port:" "${BOLD}$PORT${NC}"
printf "  %-14s %s\n" "Data Dir:" "${BOLD}$DATA_DIR${NC}"
printf "  %-14s %s\n" "Config File:" "${BOLD}$CONFIG_FILE${NC}"
printf "  %-14s %s\n" "Service Name:" "${BOLD}$SERVICE_NAME.service${NC}"
printf "${CYAN}${BOLD}===========================================================${NC}\n"
echo