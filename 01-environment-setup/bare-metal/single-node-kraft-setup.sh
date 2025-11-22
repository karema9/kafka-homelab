#!/bin/bash
set -euo pipefail

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

# === Configurable variables =================================================
KAFKA_VERSION="3.9.0"
SCALA_VERSION="2.13"
KAFKA_DIR="/opt/kafka"
KAFKA_DATA_DIR="/var/lib/kafka"
KAFKA_LOGS_DIR="/var/log/kafka"
DOWNLOAD_URL="https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"

# colors for the output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TMPDIR=""
# =============================================================================

print_info() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
print_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
print_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

_require_root() {
    if [ "$EUID" -ne 0 ]; then
        print_warn "This script needs sudo privileges for some operations. You may be prompted for your password."
    fi
}

_safe_rmdir() {
    # Safe removal wrapper to prevent accidental deletion of root or empty var.
    local target="$1"
    if [ -z "${target}" ] || [ "${target}" = "/" ] || [ "${target}" = "." ]; then
        print_error "Refusing to remove unsafe path: '${target}'"
        return 1
    fi
    if [ -e "${target}" ]; then
        sudo rm -rf -- "${target}"
    fi
}

_create_tmpdir() {
    TMPDIR="$(mktemp -d)"
    trap 'rm -rf -- "${TMPDIR:-}"' EXIT INT TERM
}

_check_java() {
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed. Please install Java 11 or later and re-run."
        exit 1
    fi
    print_info "Java version: $(java -version 2>&1 | head -n 1)"
}

check_existing_kafka_installation() {
    if [ -d "${KAFKA_DIR}" ] && [ -f "${KAFKA_DIR}/bin/kafka-server-start.sh" ]; then
        return 0
    fi
    return 1
}

cleanup() {
    print_info "Starting Kafka cleanup..."

    if pgrep -f "kafka.Kafka" >/dev/null 2>&1; then
        print_info "Stopping Kafka server..."
        pkill -f "kafka.Kafka" || true
        sleep 3
    fi

    # Remove directories (safe guards)
    print_info "Removing Kafka directories (if present)..."
    _safe_rmdir "${KAFKA_DIR}"
    _safe_rmdir "${KAFKA_DATA_DIR}"
    _safe_rmdir "${KAFKA_LOGS_DIR}"

    if [ -f /etc/systemd/system/kafka.service ]; then
        print_info "Disabling and removing systemd service..."
        sudo systemctl stop kafka.service || true
        sudo systemctl disable kafka.service || true
        sudo rm -f /etc/systemd/system/kafka.service
        sudo systemctl daemon-reload
    fi

    print_info "Cleanup complete."
}

_install_system_dirs() {
    print_info "Creating data and log directories..."
    sudo mkdir -p "${KAFKA_DIR}"
    sudo mkdir -p "${KAFKA_DATA_DIR}"
    sudo mkdir -p "${KAFKA_LOGS_DIR}"
    sudo chown -R root:root "${KAFKA_DIR}"
    sudo chmod 0755 "${KAFKA_DIR}"
}

write_kraft_config() {
    local cfg_path="${KAFKA_DIR}/config/kraft/server.properties"
    sudo mkdir -p "$(dirname "${cfg_path}")"
    print_info "Writing KRaft server.properties to ${cfg_path} ..."
    sudo tee "${cfg_path}" > /dev/null <<EOF
# KRaft Controller and Broker Configuration
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9093

# Listeners
listeners=PLAINTEXT://localhost:9092,CONTROLLER://localhost:9093
advertised.listeners=PLAINTEXT://localhost:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
controller.listener.names=CONTROLLER
inter.broker.listener.name=PLAINTEXT

# Log directories
log.dirs=${KAFKA_DATA_DIR}

# Log retention
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

# Networking / Threads
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

# Topic defaults (dev-friendly; override for production)
num.partitions=1
default.replication.factor=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1

# Group coordinator
group.coordinator.rebalance.protocols=classic,consumer
EOF
}

write_systemd_unit() {
    print_info "Writing systemd unit /etc/systemd/system/kafka.service ..."
    sudo tee /etc/systemd/system/kafka.service > /dev/null <<'EOF'
[Unit]
Description=Apache Kafka Server (KRaft mode)
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target

[Service]
Type=simple
User=root
Environment="KAFKA_HEAP_OPTS=-Xmx1G -Xms1G"
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable kafka.service || true
}

install() {
    print_info "Starting Kafka KRaft installation..."

    if check_existing_kafka_installation; then
        print_warn "Kafka appears to already be installed at ${KAFKA_DIR}"
        if sudo systemctl is-active --quiet kafka.service 2>/dev/null; then
            print_info "Kafka service is already running. Use 'reinstall' or 'cleanup' if you want to replace it."
            exit 0
        else
            print_info "Kafka installation found but service is not running. Attempting to start..."
            sudo systemctl start kafka.service || true
            if sudo systemctl is-active --quiet kafka.service; then
                print_info "Kafka service started successfully."
                exit 0
            else
                print_warn "Failed to start existing Kafka. Use 'reinstall' to force a reinstall."
                exit 1
            fi
        fi
    fi

    _require_root
    _check_java
    _create_tmpdir
    _install_system_dirs

    print_info "Downloading Kafka ${KAFKA_VERSION} ..."
    cd "${TMPDIR}"
    wget -q -O kafka.tgz "${DOWNLOAD_URL}"

    print_info "Extracting Kafka..."
    sudo tar -xzf kafka.tgz -C "${KAFKA_DIR}" --strip-components=1
    rm -f kafka.tgz

    print_info "Generating cluster UUID..."
    CLUSTER_UUID="$("${KAFKA_DIR}/bin/kafka-storage.sh" random-uuid)"
    print_info "Cluster UUID: ${CLUSTER_UUID}"

    # Write KRaft config
    write_kraft_config

    # Format storage (idempotent: safe to run again only if not formatted)
    print_info "Formatting storage directory for KRaft (this is required once)..."
    sudo "${KAFKA_DIR}/bin/kafka-storage.sh" format -t "${CLUSTER_UUID}" -c "${KAFKA_DIR}/config/kraft/server.properties"

    # Create systemd unit and start service
    write_systemd_unit

    print_info "Starting Kafka service..."
    sudo systemctl start kafka.service

    print_info "Waiting for Kafka service to become active..."
    sleep 5

    if sudo systemctl is-active --quiet kafka.service; then
        print_info "Kafka is running successfully."
        print_info "Cluster UUID: ${CLUSTER_UUID}"
        print_info "Broker address: localhost:9092"
        print_info ""
        print_info "Useful commands:"
        print_info "  Start  : sudo systemctl start kafka.service"
        print_info "  Stop   : sudo systemctl stop kafka.service"
        print_info "  Status : sudo systemctl status kafka.service"
        print_info "  Logs   : sudo journalctl -u kafka.service -f"
        print_info "Test with: ${KAFKA_DIR}/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list"
    else
        print_error "Kafka failed to start. Check logs: sudo journalctl -u kafka.service -xe"
        exit 1
    fi
}

status() {
    if sudo systemctl is-active --quiet kafka.service 2>/dev/null; then
        print_info "Kafka service is active"
        sudo systemctl status kafka.service --no-pager
    else
        print_warn "Kafka service is not active"
        sudo systemctl status kafka.service --no-pager || true
    fi
}

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
    status)
        status
        ;;
    *)
        cat <<USAGE
Usage: $0 {install|cleanup|reinstall|status}

Commands:
  install    - Install Kafka in single-node KRaft mode
  cleanup    - Remove Kafka installation completely
  reinstall  - Cleanup then install fresh
  status     - Show systemd status for kafka service
USAGE
        exit 1
        ;;
esac
