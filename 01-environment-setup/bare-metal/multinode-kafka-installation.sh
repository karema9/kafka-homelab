#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Multi-node Kafka (KRaft) installation script
# - Robust defaults
# - Safer filesystem operations
# - Clear, colored & boxed output
# - Idempotent where practical
# -----------------------------------------------------------------------------

# ---------------------------
# ASCII header
# ---------------------------
cat <<'EOF'
 🎼♩♫♬♩🎵♬♫♩🎼
    _    ___      __
   | |  / (_)____/ /___  ______  _________
   | | / / / ___/ __/ / / / __ \/ ___/ __ \
   | |/ / / /  / /_/ /_/ / /_/ (__  ) /_/ /
   |___/_/_/   \__/\__,_/\____/____/\____/ 
 🎵♬♫♩🎼♩♫♬♩🎵
EOF

# ---------------------------
# Basic settings / defaults
# ---------------------------
KAFKA_VERSION="${KAFKA_VERSION:-3.9.0}"
SCALA_VERSION="${SCALA_VERSION:-2.13}"
KAFKA_DIR="${KAFKA_DIR:-/opt/kafka}"
KAFKA_DATA_DIR="${KAFKA_DATA_DIR:-/var/lib/kafka}"
KAFKA_LOGS_DIR="${KAFKA_LOGS_DIR:-/var/log/kafka}"
DOWNLOAD_URL="${DOWNLOAD_URL:-https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz}"

CLUSTER_UUID_FILE="${CLUSTER_UUID_FILE:-${KAFKA_DIR}/cluster.uuid}"

# Environment-configurable node settings (can be exported before calling script)
NODE_ID="${NODE_ID:-}"
NODE_HOSTNAME="${NODE_HOSTNAME:-$(hostname -f 2>/dev/null || hostname)}"
CLUSTER_NODES="${CLUSTER_NODES:-1@${NODE_HOSTNAME}:9093}"
PROCESS_ROLES="${PROCESS_ROLES:-broker,controller}"
BROKER_PORT="${BROKER_PORT:-9092}"
CONTROLLER_PORT="${CONTROLLER_PORT:-9093}"

# Replication internals defaults
DEFAULT_REPLICATION_FACTOR="${DEFAULT_REPLICATION_FACTOR:-3}"
MIN_INSYNC_REPLICAS="${MIN_INSYNC_REPLICAS:-2}"
OFFSETS_TOPIC_REPLICATION="${OFFSETS_TOPIC_REPLICATION:-3}"
TRANSACTION_STATE_LOG_REPLICATION="${TRANSACTION_STATE_LOG_REPLICATION:-3}"
TRANSACTION_STATE_LOG_MIN_ISR="${TRANSACTION_STATE_LOG_MIN_ISR:-2}"

# color palette
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"
NC="${RESET}"

# Temporary workspace
TMPDIR=""

# ---------------------------
# Output helper functions
# ---------------------------
print_info()  { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
print_warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
print_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }
print_cluster(){ printf "${BLUE}[CLUSTER]${NC} %s\n" "$1"; }
print_config(){ printf "${CYAN}[CONFIG]${NC} %s\n" "$1"; }

# ---------------------------
# Utility functions
# ---------------------------
_require_root() {
    # Don't forcibly exit; warn so scripts can be run in CI where sudo may be available.
    if [ "$EUID" -ne 0 ]; then
        print_warn "This script performs privileged operations. You will be prompted for sudo when needed."
    fi
}

_safe_rmdir() {
    # Safely remove a directory if it exists.
    # Refuse dangerous inputs.
    local target="${1:-}"
    if [ -z "${target}" ] || [ "${target}" = "/" ] || [ "${target}" = "." ]; then
        print_error "Refusing to remove unsafe path: '${target}'"
        return 1
    fi
    if [ -e "${target}" ]; then
        sudo rm -rf -- "${target}"
    fi
}

_create_tmpdir() {
    TMPDIR="$(mktemp -d -t kafka-install.XXXXXX)"
    # Ensure TMPDIR is cleaned on exit/interrupt
    trap 'if [ -n "${TMPDIR:-}" ] && [ -d "${TMPDIR}" ]; then rm -rf -- "${TMPDIR}"; fi' EXIT INT TERM
}

_check_java() {
    if ! command -v java >/dev/null 2>&1; then
        print_error "Java not found. Install Java 11+ (OpenJDK) and re-run."
        exit 1
    fi
    print_info "Java: $(java -version 2>&1 | head -n1)"
}

check_existing_kafka_installation() {
    # Return 0 if a usable kafka installation appears present
    if [ -d "${KAFKA_DIR}" ] && [ -x "${KAFKA_DIR}/bin/kafka-server-start.sh" ]; then
        return 0
    fi
    return 1
}

get_or_generate_cluster_uuid() {
    # Returns the UUID to use (prints it)
    if [ -n "${CLUSTER_UUID:-}" ]; then
        printf "%s\n" "${CLUSTER_UUID}"
        return 0
    fi

    if [ -f "${CLUSTER_UUID_FILE}" ]; then
        cat "${CLUSTER_UUID_FILE}"
        return 0
    fi

    # generate via kafka-storage.sh if available; otherwise fallback to uuidgen
    if [ -x "${KAFKA_DIR}/bin/kafka-storage.sh" ]; then
        "${KAFKA_DIR}/bin/kafka-storage.sh" random-uuid
    else
        if command -v uuidgen >/dev/null 2>&1; then
            uuidgen
        else
            # best-effort fallback
            cat /proc/sys/kernel/random/uuid 2>/dev/null || (date +%s%N; echo) | sha1sum | cut -c1-36
        fi
    fi
}

save_cluster_uuid() {
    local uuid="$1"
    sudo mkdir -p "$(dirname "${CLUSTER_UUID_FILE}")"
    echo "${uuid}" | sudo tee "${CLUSTER_UUID_FILE}" >/dev/null
}

# ---------------------------
# Configuration validation & display
# ---------------------------
validate_cluster_config() {
    print_info "Validating cluster configuration..."

    if [ -z "${NODE_ID:-}" ]; then
        print_error "NODE_ID is required. Export NODE_ID (e.g. export NODE_ID=1) and rerun."
        exit 1
    fi

    if [ -z "${NODE_HOSTNAME:-}" ] && [ -z "${BROKER_HOSTNAME:-}" ]; then
        print_error "NODE_HOSTNAME/BROKER_HOSTNAME not determined. Set NODE_HOSTNAME or BROKER_HOSTNAME."
        exit 1
    fi

    if [ -z "${CLUSTER_NODES:-}" ]; then
        print_error "CLUSTER_NODES is required. Export CLUSTER_NODES like '1@host1:9093,2@host2:9093,...'"
        exit 1
    fi

    if [ -z "${PROCESS_ROLES:-}" ]; then
        print_error "PROCESS_ROLES is required (broker,controller | broker | controller)."
        exit 1
    fi

    # display
    echo -e "${YELLOW}===== Node Configuration =====${NC}"
    echo -e "${GREEN}Node ID        :${NC} ${NODE_ID}"
    echo -e "${GREEN}Node Hostname  :${NC} ${NODE_HOSTNAME:-$BROKER_HOSTNAME}"
    echo -e "${GREEN}Process Roles  :${NC} ${PROCESS_ROLES}"
    echo -e "${GREEN}Broker Port    :${NC} ${BROKER_PORT}"
    echo -e "${GREEN}Controller Port:${NC} ${CONTROLLER_PORT}"
    echo -e "${GREEN}Cluster Nodes  :${NC} ${CLUSTER_NODES}"
    echo -e "${YELLOW}==============================${NC}"
}

# ---------------------------
# Write KRaft server.properties
# ---------------------------
write_kraft_config() {
    local cfg_path="${KAFKA_DIR}/config/kraft/server.properties"
    sudo mkdir -p "$(dirname "${cfg_path}")"

    print_info "Writing KRaft configuration: ${cfg_path}"

    # build listeners
    local listeners=""
    local advertised_listeners=""

    if [[ "${PROCESS_ROLES}" == *"broker"* ]] && [[ "${PROCESS_ROLES}" == *"controller"* ]]; then
        listeners="PLAINTEXT://${NODE_HOSTNAME}:${BROKER_PORT},CONTROLLER://${NODE_HOSTNAME}:${CONTROLLER_PORT}"
        advertised_listeners="PLAINTEXT://${NODE_HOSTNAME}:${BROKER_PORT}"
    elif [[ "${PROCESS_ROLES}" == "broker" ]]; then
        listeners="PLAINTEXT://${NODE_HOSTNAME}:${BROKER_PORT}"
        advertised_listeners="${listeners}"
    else
        listeners="CONTROLLER://${NODE_HOSTNAME}:${CONTROLLER_PORT}"
        advertised_listeners=""
    fi

    # core config
    sudo tee "${cfg_path}" >/dev/null <<EOF
# ============================================================================
# Multi-Node KRaft Cluster Configuration
# Node ID: ${NODE_ID}
# Hostname: ${NODE_HOSTNAME:-$BROKER_HOSTNAME}
# Roles: ${PROCESS_ROLES}
# ============================================================================
process.roles=${PROCESS_ROLES}
node.id=${NODE_ID}
controller.quorum.voters=${CLUSTER_NODES}
listeners=${listeners}
EOF

    if [ -n "${advertised_listeners}" ]; then
        echo "advertised.listeners=${advertised_listeners}" | sudo tee -a "${cfg_path}" >/dev/null
    fi

    sudo tee -a "${cfg_path}" >/dev/null <<'EOF'

# Listener protocol mapping
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL
controller.listener.names=CONTROLLER
EOF

    if [[ "${PROCESS_ROLES}" == *"broker"* ]]; then
        echo "inter.broker.listener.name=PLAINTEXT" | sudo tee -a "${cfg_path}" >/dev/null
    fi

    sudo tee -a "${cfg_path}" >/dev/null <<EOF

# Storage & logs
log.dirs=${KAFKA_DATA_DIR}

# Retention / segments
log.retention.hours=168
log.retention.bytes=1073741824
log.segment.bytes=1073741824
log.retention.check.interval=300000

# Performance tuning (tune to your hardware)
num.network.threads=8
num.io.threads=16
num.replica.fetchers=4
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

# Topic defaults
num.partitions=3
default.replication.factor=${DEFAULT_REPLICATION_FACTOR}
min.insync.replicas=${MIN_INSYNC_REPLICAS}

# Internal topic replication
offsets.topic.replication.factor=${OFFSETS_TOPIC_REPLICATION}
transaction.state.log.replication.factor=${TRANSACTION_STATE_LOG_REPLICATION}
transaction.state.log.min.isr=${TRANSACTION_STATE_LOG_MIN_ISR}

# Group coordinator
group.coordinator.rebalance.protocols=classic, consumer

# Controller timeouts
controller.quorum.election.timeout.ms=1000
controller.quorum.fetch.timeout.ms=2000

# Replication tuning
replica.lag.time.max.ms=300000
replica.socket.timeout.ms=30000
replica.socket.receive.buffer.bytes=65536

# Log cleaner
log.cleaner.enable=true
log.cleaner.threads=2
EOF
}

# ---------------------------
# systemd unit
# ---------------------------
write_systemd_unit() {
    print_info "Writing systemd unit to /etc/systemd/system/kafka.service"

    sudo tee /etc/systemd/system/kafka.service >/dev/null <<EOF
[Unit]
Description=Apache Kafka Server (KRaft mode) - Node ${NODE_ID}
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target

[Service]
Type=simple
User=root
Environment="KAFKA_HEAP_OPTS=-Xmx2G -Xms2G"
Environment="KAFKA_JVM_PERFORMANCE_OPTS=-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent"
ExecStart=${KAFKA_DIR}/bin/kafka-server-start.sh ${KAFKA_DIR}/config/kraft/server.properties
Restart=on-failure
RestartSec=10
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable kafka.service >/dev/null 2>&1 || true
}

# ---------------------------
# cleanup
# ---------------------------
cleanup() {
    print_info "Starting cleanup on node ${NODE_ID}..."

    if pgrep -f "kafka" >/dev/null 2>&1; then
        print_info "Stopping Kafka processes..."
        sudo pkill -f "kafka" || true
        sleep 2
    fi

    print_info "Removing Kafka directories (if present)..."
    _safe_rmdir "${KAFKA_DIR}" || true
    _safe_rmdir "${KAFKA_DATA_DIR}" || true
    _safe_rmdir "${KAFKA_LOGS_DIR}" || true

    if [ -f /etc/systemd/system/kafka.service ]; then
        print_info "Removing systemd service..."
        sudo systemctl stop kafka.service >/dev/null 2>&1 || true
        sudo systemctl disable kafka.service >/dev/null 2>&1 || true
        sudo rm -f /etc/systemd/system/kafka.service
        sudo systemctl daemon-reload
    fi

    print_info "Cleanup complete."
}

# ---------------------------
# installer
# ---------------------------
install() {
    print_info "Begin Kafka KRaft installation on node ${NODE_ID}..."

    validate_cluster_config
    _require_root
    _check_java
    _create_tmpdir

    if check_existing_kafka_installation; then
        print_warn "Kafka appears installed at ${KAFKA_DIR}"
        if sudo systemctl is-active --quiet kafka.service 2>/dev/null; then
            print_info "Kafka already running - exiting."
            return 0
        fi
        print_info "Existing install found; continuing to configure/start."
    fi

    print_info "Downloading Kafka ${KAFKA_VERSION} ..."
    cd "${TMPDIR}"
    if ! command -v wget >/dev/null 2>&1; then
        print_error "wget is required to download Kafka. Install wget and re-run."
        exit 1
    fi
    if ! wget -q -O kafka.tgz "${DOWNLOAD_URL}"; then
        print_error "Failed to download Kafka from ${DOWNLOAD_URL}"
        exit 1
    fi

    print_info "Extracting Kafka to ${KAFKA_DIR} ..."
    sudo mkdir -p "${KAFKA_DIR}"
    sudo tar -xzf kafka.tgz -C "${KAFKA_DIR}" --strip-components=1
    rm -f kafka.tgz

    print_info "Preparing cluster UUID..."
    CLUSTER_UUID_VALUE="$(get_or_generate_cluster_uuid)"
    save_cluster_uuid "${CLUSTER_UUID_VALUE}"

    if [ "${NODE_ID}" = "1" ] && [ -z "${CLUSTER_UUID:-}" ]; then
        print_warn "PRIMARY NODE: share this UUID with other nodes:"
        print_warn "UUID: ${CLUSTER_UUID_VALUE}"
    fi

    write_kraft_config

    print_info "Formatting storage for KRaft (idempotent)..."
    if [ -x "${KAFKA_DIR}/bin/kafka-storage.sh" ]; then
        sudo "${KAFKA_DIR}/bin/kafka-storage.sh" format -t "${CLUSTER_UUID_VALUE}" -c "${KAFKA_DIR}/config/kraft/server.properties" --ignore-formatted || true
    else
        print_warn "kafka-storage.sh not found - skipping storage format step"
    fi

    write_systemd_unit

    print_info "Starting kafka.service..."
    sudo systemctl start kafka.service

    print_info "Waiting for kafka service..."
    sleep 6

    if sudo systemctl is-active --quiet kafka.service; then
        echo -e "\n${GREEN}✔ Kafka node ${NODE_ID} is running!${RESET}\n"

        # Pretty cluster info
        local FMT="  ${BLUE}%-3s${WHITE} %-16s ${BLUE}:${RESET} %s\n"
        echo -e "${BLUE}█${BOLD}${WHITE} Cluster Info ${RESET}${BLUE}█${RESET}"
        printf "${FMT}" "" "Node ID"         "${NODE_ID}"
        printf "${FMT}" "󰒋" "Hostname"        "${NODE_HOSTNAME:-$NODE_HOSTNAME}"
        printf "${FMT}" "" "Process Roles"   "${PROCESS_ROLES}"
        printf "${FMT}" "󰢻" "Cluster UUID"    "${CLUSTER_UUID_VALUE}"
        printf "${FMT}" "󰦪" "Broker Port"     "${BROKER_PORT}"
        printf "${FMT}" "󰯎" "Controller Port" "${CONTROLLER_PORT}"
        printf "${FMT}" "󰓦" "All Nodes"       "${CLUSTER_NODES}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        # Useful commands
        CMD_FMT="  ${YELLOW}%s${RESET}  %-8s ${CYAN}%s${RESET}\n"
        echo -e "\n${BOLD}Useful Commands${RESET}"
        printf "${CMD_FMT}" "▶" "Start"   "sudo systemctl start kafka.service"
        printf "${CMD_FMT}" "■" "Stop"    "sudo systemctl stop kafka.service"
        printf "${CMD_FMT}" "ℹ" "Status"  "sudo systemctl status kafka.service"
        printf "${CMD_FMT}" "📜" "Logs"    "sudo journalctl -u kafka.service -f"
        echo ""

        if [[ "${PROCESS_ROLES}" == *"broker"* ]]; then
            print_info "Test broker connectivity (example):"
            echo "  ${KAFKA_DIR}/bin/kafka-topics.sh --bootstrap-server ${NODE_HOSTNAME}:${BROKER_PORT} --list"
            echo "  ${KAFKA_DIR}/bin/kafka-broker-api-versions.sh --bootstrap-server ${NODE_HOSTNAME}:${BROKER_PORT}"
            echo ""
        fi

        print_info "Check cluster metadata:"
        echo "  ${KAFKA_DIR}/bin/kafka-metadata.sh --snapshot ${KAFKA_DATA_DIR}/__cluster_metadata-0/*.checkpoint --print"
        echo ""
    else
        print_error "Kafka failed to start. Check logs: sudo journalctl -u kafka.service -xe"
        exit 1
    fi
}

# ---------------------------
# status
# ---------------------------
status() {
    print_info "Checking Kafka status on node ${NODE_ID:-unknown}..."
    if sudo systemctl is-active --quiet kafka.service 2>/dev/null; then
        print_info "Kafka service is active"
        sudo systemctl status kafka.service --no-pager
    else
        print_warn "Kafka service is not active"
        sudo systemctl status kafka.service --no-pager || true
    fi
}

# ---------------------------
# show examples (short)
# ---------------------------
show_examples() {
    cat <<'EOF'
(Examples omitted for brevity - same content as in your repository's README.)
EOF
}

# ---------------------------
# CLI
# ---------------------------
case "${1:-}" in
    install)   install ;;
    cleanup)   cleanup ;;
    reinstall) cleanup && install ;;
    status)    status ;;
    examples)  show_examples ;;
    *) 
        cat <<USAGE
Usage: $0 {install|cleanup|reinstall|status|examples}

Examples:
  export NODE_ID=1
  export NODE_HOSTNAME=kafka-node1
  export CLUSTER_NODES="1@kafka-node1:9093,2@kafka-node2:9093,3@kafka-node3:9093"
  sudo $0 install

USAGE
        exit 1
        ;;
esac
