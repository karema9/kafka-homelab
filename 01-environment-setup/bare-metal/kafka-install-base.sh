#!/bin/bash
# ==========================================================
# Kafka Multi-Broker - BASE INSTALLER
# ==========================================================
# Run this script ONCE per node.
# It installs the Kafka binaries and the systemd template.
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
# Spinner Function
# ----------------------------
# Usage: spinner "Message..." command_to_run
spinner() {
    local MSG="$1"
    shift
    local CMD="$@"
    local SPIN='-\|/'
    local PID

    echo -n -e "${YELLOW}⏳ $MSG ${NC}"

    # Run command in background and capture PID
    $CMD &> /dev/null &
    PID=$!

    # Show spinner
    while kill -0 $PID 2>/dev/null; do
        for i in $(seq 0 3); do
            echo -n -e "${YELLOW}${SPIN:$i:1}\033[D${NC}"
            sleep 0.1
        done
    done

    # Wait for the command to exit and check status
    wait $PID
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}\033[D${GREEN}✓ Done.${NC}"
    else
        echo -e "${YELLOW}\033[D${RED}✗ Failed.${NC}"
        echo -e "${RED}Error running: $CMD${NC}"
        exit 1
    fi
}

# ----------------------------
# Header
# ----------------------------
echo -e "${CYAN}"
cat << "EOF"
echo -e "
          __         __                                      
         /\_\       /\ \__                                   
 __  __ /\/_/   _ __\ \ ,_\  __  __    ___     ____    ___  
/\ \/\ \  /\ \ /\`'__\ \ \/ /\ \/\ \  / __\`\  /',__\  / __\`\\
\ \ \_/ | \ \ \\ \ \/ \ \ \_\ \ \_\ \/\ \L\ \/\__, \`\/\ \L\ \\
 \ \___/   \ \_\\ \_\  \ \__\\ \____/\ \____/\/\____/\ \____/
  \/__/     \/_/ \/_/   \/__/ \/___/  \/___/  \/___/  \/___/ 
"
EOF
echo -e "${BOLD}==================== V I R T U O S O   H O M E L A B ====================${NC}"
echo -e "${BLUE}--- Kafka Multi-Broker Base Installer (TEST Environment) ---${NC}"
echo

# ----------------------------
# Variables
# ----------------------------
KAFKA_VERSION="3.9.1"
SCALA_VERSION="2.13"
INSTALL_DIR="/opt/kafka-test"
USER="kafka-test"
GROUP="kafka-test"
SYSTEMD_TEMPLATE="/etc/systemd/system/kafka-test@.service"

# ----------------------------
# 1. Install Dependencies
# ----------------------------

echo -e "${YELLOW}[1/4] ⚙️  Installing dependencies...${NC}"
# We are running this in the foreground (no spinner) to see error messages.
(sudo apt-get update -y && sudo apt-get install -y openjdk-17-jre-headless wget tar)
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Dependency installation failed. Please check the 'apt' errors above.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dependencies installed successfully.${NC}"

# ----------------------------
# 2. Create a Kafka user
# ----------------------------
echo -e "${YELLOW}[2/4] 👤 Creating user ${BOLD}$USER${NC}${YELLOW} and group ${BOLD}$GROUP${NC}...${NC}"
sudo groupadd -r $GROUP || true
sudo useradd -r -g $GROUP -m -s /bin/bash $USER || true
sudo mkdir -p $INSTALL_DIR
echo -e "${GREEN}✓ User and directories created.${NC}"

# ----------------------------
# 3. Download and extract Kafka
# ----------------------------
cd /tmp
spinner "[3/4] 📥 Downloading Kafka $KAFKA_VERSION..." \
    "wget -q https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"

spinner "[3/4] 📦 Extracting binaries to ${BOLD}$INSTALL_DIR${NC}" \
    "sudo tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C $INSTALL_DIR --strip-components 1"

echo -e "${YELLOW}[3/4] 🧹 Cleaning up...${NC}"
sudo chown -R $USER:$GROUP $INSTALL_DIR
rm -f kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
echo -e "${GREEN}✓ Kafka binaries installed.${NC}"

# ----------------------------
# 4. Create systemd template service
# ----------------------------
echo -e "${YELLOW}[4/4] 📄 Creating systemd template at ${BOLD}$SYSTEMD_TEMPLATE${NC}${YELLOW}...${NC}"
sudo tee $SYSTEMD_TEMPLATE > /dev/null << EOF
[Unit]
Description=Apache Kafka Server (Instance @%i)
After=network.target

[Service]
Type=simple
User=$USER
Group=$GROUP
# The %i will be the broker ID, e.g., "1" or "2"
# It will load the config file $INSTALL_DIR/config/server-%i.properties
ExecStart=$INSTALL_DIR/bin/kafka-server-start.sh $INSTALL_DIR/config/server-%i.properties
ExecStop=$INSTALL_DIR/bin/kafka-server-stop.sh
Restart=on-abnormal
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
echo -e "${GREEN}✓ Systemd template created and reloaded.${NC}"

# ----------------------------
# 5. Final Summary
# ----------------------------
echo
echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}✅ ${BOLD}Kafka base TEST installation complete!${NC}"
printf "  %-20s %s\n" "Binaries are in:" "${BOLD}$INSTALL_DIR${NC}"
printf "  %-20s %s\n" "Systemd Template:" "${BOLD}$SYSTEMD_TEMPLATE${NC}"
echo -e "${GREEN}===========================================================${NC}"
echo -e "Next, run ${BOLD}'./kafka-add-broker-TEST.sh'${NC} to add broker instances."
echo