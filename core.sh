#!/usr/bin/env bash

get_platform() {
    if [ -d "/data/data/com.termux" ] 2>/dev/null; then
        echo "TERMUX"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "MACOS"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL"
    elif [ -f "/etc/os-release" ]; then
        echo "LINUX"
    else
        echo "UNIX"
    fi
}

get_gateway() {
    local platform=$(get_platform)

    case $platform in
        TERMUX|LINUX|WSL)
            ip route | grep default | awk '{print $3}' | head -1
            ;;
        MACOS)
            netstat -rn | grep default | grep -v "::" | awk '{print $2}' | head -1
            ;;
        *)
            echo "192.168.1.1"
            ;;
    esac
}

get_local_ip() {
    local platform=$(get_platform)

    case $platform in
        TERMUX|LINUX|WSL)
            ip route get 1 | awk '{print $NF;exit}' 2>/dev/null
            ;;
        MACOS)
            ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
            ;;
        *)
            hostname -I | awk '{print $1}'
            ;;
    esac
}

get_local_mac() {
    ip link show | grep "link/ether" | awk '{print $2}' | head -1
}

get_connected_ssid() {
    local platform=$(get_platform)

    case $platform in
        TERMUX)
            if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then
                termux-wifi-connectioninfo 2>/dev/null | jq -r '.ssid // "Unknown"' 2>/dev/null
            else
                echo "Unknown"
            fi
            ;;
        LINUX)
            nmcli -t -f active,ssid dev wifi 2>/dev/null | grep "^yes:" | cut -d: -f2
            ;;
        MACOS)
            /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I \
                | grep " SSID:" | awk '{print $2}'
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

init_config() {
    BASE_DIR="$HOME/.wifi-security"
    LOG_DIR="$BASE_DIR/logs"
    REPORT_DIR="$BASE_DIR/reports"
    BLOCKLIST_FILE="$BASE_DIR/blocklist.txt"
    THREAT_LOG="$LOG_DIR/threats.log"

    mkdir -p "$BASE_DIR" "$LOG_DIR" "$REPORT_DIR" 2>/dev/null
    touch "$BLOCKLIST_FILE" "$THREAT_LOG"

    export BASE_DIR LOG_DIR REPORT_DIR BLOCKLIST_FILE THREAT_LOG
}

check_dependencies() {
    local platform=$(get_platform)

    echo "[INFO] Platform detected: $platform"
    echo ""

    case $platform in
        TERMUX)
            if ! command -v termux-wifi-scaninfo >/dev/null 2>&1; then
                echo "[WARN] termux-api not found. Install: pkg install termux-api"
            fi
            ;;
        LINUX|WSL)
            if ! command -v nmcli >/dev/null 2>&1; then
                echo "[WARN] Network tools limited. Install: sudo apt install network-manager"
            fi
            ;;
    esac

    if ! command -v nmap >/dev/null 2>&1; then
        echo "[WARN] nmap not found. Pentest features limited."
        echo "[INFO] Install: pkg install nmap (Termux) | sudo apt install nmap (Linux)"
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo "[WARN] curl not found. Install: pkg install curl"
    fi
}

log_threat() {
    local type=$1
    local source=$2
    local detail=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "$timestamp|$type|$source|$detail" >> "$THREAT_LOG"
    echo "[THREAT] $type detected from $source - $detail"
}

block_ip() {
    local ip=$1
    local platform=$(get_platform)

    echo "$ip" >> "$BLOCKLIST_FILE"
    echo "[INFO] IP $ip added to blocklist"

    case $platform in
        LINUX)
            if command -v iptables >/dev/null 2>&1; then
                sudo iptables -A INPUT -s "$ip" -j DROP 2>/dev/null && \
                    echo "[INFO] IP blocked via iptables"
            fi
            ;;
        MACOS)
            sudo pfctl -t blocklist -T add "$ip" 2>/dev/null && \
                echo "[INFO] IP blocked via pf"
            ;;
    esac
}

block_ip_interactive() {
    echo -n "Enter IP to block: "
    read -r ip

    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        block_ip "$ip"
    else
        echo "[ERROR] Invalid IP format"
    fi
}
