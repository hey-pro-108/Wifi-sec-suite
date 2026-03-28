#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

source ./core.sh
source ./monitor.sh
source ./pentest.sh
source ./reporter.sh
source ./auth.sh

init_config
init_auth

clear
echo "Wi-Fi Security Suite v2.0"
echo "Developed by: Hexa Dev"
echo ""

platform=$(get_platform)
gateway=$(get_gateway)
ssid=$(get_connected_ssid)

echo "Platform: $platform"
echo "Gateway: $gateway"
echo "SSID: $ssid"
echo ""

show_menu() {
    local auth_status=$(check_auth)
    
    if [ "$auth_status" != "verified" ]; then
        echo "[!] Pentest mode requires router authentication"
        echo ""
        echo "[1] Start Monitor (MITM/ARP/Brute Force Detection)"
        echo "[2] Router Authentication (Required for Pentest)"
        echo "[3] Quick Vulnerability Scan (Requires Auth)"
        echo "[4] Full Security Audit (Requires Auth)"
        echo "[5] Block Suspicious IP"
        echo "[6] View Threat Log"
        echo "[7] Generate Report"
        echo "[8] Exit"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case $choice in
            1) start_monitor ;;
            2) router_login ;;
            3) echo "[ERROR] Please authenticate first (option 2)"; sleep 2 ;;
            4) echo "[ERROR] Please authenticate first (option 2)"; sleep 2 ;;
            5) block_ip_interactive ;;
            6) view_threats ;;
            7) generate_report ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    else
        echo "[1] Start Monitor (MITM/ARP/Brute Force Detection)"
        echo "[2] Re-authenticate Router"
        echo "[3] Quick Vulnerability Scan"
        echo "[4] Full Security Audit"
        echo "[5] Block Suspicious IP"
        echo "[6] View Threat Log"
        echo "[7] Generate Report"
        echo "[8] Exit"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case $choice in
            1) start_monitor ;;
            2) router_login ;;
            3) quick_scan ;;
            4) full_audit ;;
            5) block_ip_interactive ;;
            6) view_threats ;;
            7) generate_report ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    fi
}

while true; do
    show_menu
done        echo "[3] Quick Vulnerability Scan (Requires Auth)"
        echo "[4] Full Security Audit (Requires Auth)"
        echo "[5] Block Suspicious IP"
        echo "[6] View Threat Log"
        echo "[7] Generate Report"
        echo "[8] Exit"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case $choice in
            1) start_monitor ;;
            2) router_login ;;
            3) echo "[ERROR] Please authenticate first (option 2)"; sleep 2 ;;
            4) echo "[ERROR] Please authenticate first (option 2)"; sleep 2 ;;
            5) block_ip_interactive ;;
            6) view_threats ;;
            7) generate_report ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    else
        echo "[1] Start Monitor (MITM/ARP/Brute Force Detection)"
        echo "[2] Re-authenticate Router"
        echo "[3] Quick Vulnerability Scan"
        echo "[4] Full Security Audit"
        echo "[5] Block Suspicious IP"
        echo "[6] View Threat Log"
        echo "[7] Generate Report"
        echo "[8] Exit"
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case $choice in
            1) start_monitor ;;
            2) router_login ;;
            3) quick_scan ;;
            4) full_audit ;;
            5) block_ip_interactive ;;
            6) view_threats ;;
            7) generate_report ;;
            8) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    fi
}

while true; do
    show_menu
done
