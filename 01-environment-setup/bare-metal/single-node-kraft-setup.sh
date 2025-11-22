#!bin/bash

cat << "EOF"
 🎼♩♫♬♩🎵♬♫♩🎼
    _    ___      __
   | |  / (_)____/ /___  ______  _________
   | | / / / ___/ __/ / / / __ \/ ___/ __ \
   | |/ / / /  / /_/ /_/ / /_/ (__  ) /_/ /
   |___/_/_/   \__/\__,_/\____/____/\____/ 
 🎵♬♫♩🎼♩♫♬♩🎵
EOF

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║          KAFKA KRAFT MODE INSTALLATION SCRIPT                     ║"
echo "║                  Apache Kafka without ZooKeeper                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

set -e


KAFKA_VERSION="3.9.0"
SCALA_VERSION="2.13"
KAFKA_DIR="/opt/kafka"
KAFKA_DATA_DIR="var/lib/kafka"
KAFKA_LOGS_DIR="/var/log/kafka"
DOWNLOAD_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"


# colors for the output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup Kafka installation ....
cleanup() {
    print_info "Starting Kafka cleanup... "

    if pgrep -f "kafka.Kafka" > /dev/null; then
        print_info "Stopping Kafka server..."
        pkill -f "kafka.Kafka" || true
        sleep 3


# Remove directories
print_info "Remove directories ..."
sudo rm -rf ${KAFKA_DIR}
sudo rm -rf ${KAFKA_DATA_DIR}
sudo rm -rf ${KAFKA_LOGS_DIR}

if [ -f /etc/systemd/system/kafka.service ]; then
    print_info "Removing systemd service..."
    sudo systemctl stop kafka || true
    sudo systemctl disable kafka || true
    sudo rm -rf /etc/systemd/system/kafka.service
    sudo systemctl daemon-reload
fi

print_info "Cleanup complete ..."

}

# Function to check if Kafka is already installed
check_existing_kafka_installation() {
    if [ -d "${KAFKA_DIR}" ] && [ -f $"{KAFKA_DIR}/bin/kafka-server-start.sh" ]; then
        return 0
    fi
    return 1
 }

 # Function to install Kafka
install() {
    print_info "Starting Kafka KRaft installation ... "

    # Check for the existing installation
    if check_existing_kafka_installation; then
        print_warn "Kafka is already installed at ${KAFKA_DIR}"

        # Check if service is running
        if sudo systemctl is-active --quiet kafka > dev/null; then
            print_info "Kafka service is already running ..." 
            print_info "Use reinstall to replace the existing installation ..."
            print_info "Use cleanup to remove the existing installation ..."
            exit 0
        else
            print_warn "Kafka is installed but not running. Attempting to start ..."
            sudo systemctl start kafka
            if sudo systemctl is-active --quiet kafka; then
                print_info "Kafka service started successfully!"
                exit 0
            else
                print_warn "Failed to start existing installation consider using 'reinstall'"
                exit 1
            fi
        fi
    fi

    if ! command -v java &> /dev/null; then
        print_error "Java is not installed. Please install Java 11 or later."
        exit 1
    fi

    print_info "Java version: $(java -version 2>?&1 | head -n 1)"


    # Create directories
    sudo mkdir -p ${KAFKA_DIR} 
    sudo mkdir -p ${KAFKA_DATA_DIR}
    sudo mkdir -p ${KAFKA_LOGS_DIR }

    # Download Kafka
    print_info "Downloading Kafka ${KAFKA_VERSION}"
    cd /tmp
    wget -q ${DOWNLOAD_URL} -0 kafka.tgz


    # Extract Kafka
    print_info "Downloading Kafka ${KAFKA_VERSION}..."
    sudo tar -xzf kafka.tgz -C ${KAFKA_DIR} --strip-components=1
    rm kafka.tgz

    # Generate cluster UUID
    CLUSTER_UUID=$(${KAFKA_DIR}/bin/kafka-storage.sh random-uuid)
    print_info "Cluster UUID: ${CLUSTER_UUID}"
    print_info "Cluster UUID: ${CLUSTER_UUID}"

    # Configure KRaft mode
    print_info "Configuring KRaft mode ..."
    sudo cp ${KAFKA_DIR}/config/kraft/server.properties ${KAFKA_DIR}/config/kraft/server.properties.backup

    sudo tee ${KAFKA_DIR}/config/kraft/server.properties > /dev/null <<EOF
#KRaft Controller and Broker Configuration
process.roles=broker, controller
node.id=1
controller.quorum.voters=@localhost:9093

# Listeners
listeners=PLAINTEXT://localhost:9092, CONTROLLER://localhost:9093
advertised.listeners=PLAINTEXT://localhost:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT, PLAINTEXT:PLAINTEXT
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT

# Log directories
log.dirs=${KAFKA_DATA_DIR};

# Log retention
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

# Replication
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

# Topic defaults
num.partitions=1
default.replication.factor=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1


$ Group coordinator
group.coordinator.rebalance.protocols=classic, consumer
EOF


    # Format storage
    print_info "Formatting storage directory ..."
    ${KAFKA_DIR}/bin/kafka-storage.sh format -t ${CLUSTER_UUID} -c {KAFKA_DIR}/config/kraft/server.properties

    # Create a systemd service
    sudo tee /etc/systemd/system/kafka.service > /dev/null <<EOF

[Unit]
Description=Apache Kafka Server (KRaft mode)
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target


[Service]
Type=simple
User=root
Environment="KAFKA_HEAP_OPTS=-Xmx1G -Xms1G"
ExecStart=${KAFKA_DIR}/bin/kafka-server-start.sh ${KAFKA_DIR}/config/kraft/server.properties
ExecStop=${KAFKA_DIR}/bin/kafka-server-stop.sh
Restart=on-failure
RestartSec=10


[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable services
    sudo systemctl daemon-reload
    sudo systemctl enable kafka

    print_info "Starting Kafka Service ..."
    sudo systemctl start kafka

    print_info "Waiting for Kafka service to start ..."
    sleep 5

    # Check status
    if sudo systemctl is-active --quiet kafka; then
        print_info "Kafka is running successfully ..."
        print_info "Cluster UUID: ${CLUSTER_UUID} ..."
        print_info "Broker address: localhost:9092 ..."
        print_info " "
        print_info "Useful commands" 
        print_info " Start : sudo systemctl start kafka"
        print_info " Stop : sudo systemctl stop kafka"
        print_info " Status : sudo systemctl status kafka"
        print_info " Logs : sudo journalctl -u f  kafka"
        print_info " ===================================================================== "
        print_info "Test with: ${KAFKA_DIR}/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list"
    else
        print_error "Kafka failed to start. Check logs with journalctl -u kafka -xe"
        exit 1
    fi  
}

# Main script
case "${1:-}" in
    install)
        install
        ;;
    cleanup)
        cleanup
        ;;
    reinstall)
        cleanup
        install
        ;;
    *)
        echo "Usage: $0 {install|cleanup|reinstall}"
        echo ""
        echo "Commands:"
        echo "  install    - Install Kafka in KRaft mode"
        echo "  cleanup    - Remove Kafka installation completely"
        echo "  reinstall  - Cleanup and install fresh"
        exit 1
        ;;
esac






