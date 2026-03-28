#!/usr/bin/env bash

generate_report() {
    local report_file="$REPORT_DIR/security_report_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "Wi-Fi Security Suite - Security Report"
        echo "============================================================"
        echo "Generated: $(date)"
        echo "Platform: $(get_platform)"
        echo ""

        echo "System Information"
        echo "------------------------------------------------------------"
        echo "Platform: $(get_platform)"
        echo "Gateway: $(get_gateway)"
        echo "Local IP: $(get_local_ip)"
        echo "Connected SSID: $(get_connected_ssid)"
        echo ""

        echo "Threat Summary"
        echo "------------------------------------------------------------"
        if [ -f "$THREAT_LOG" ]; then
            local total_threats=$(wc -l < "$THREAT_LOG")
            local mitm_count=$(grep -c "MITM" "$THREAT_LOG" 2>/dev/null || echo 0)
            local arp_count=$(grep -c "ARP_SPOOF" "$THREAT_LOG" 2>/dev/null || echo 0)
            local brute_count=$(grep -c "BRUTE_FORCE" "$THREAT_LOG" 2>/dev/null || echo 0)

            echo "Total Threats: $total_threats"
            echo "MITM Attacks: $mitm_count"
            echo "ARP Spoofing: $arp_count"
            echo "Brute Force: $brute_count"
        else
            echo "No threat log found"
        fi
        echo ""

        echo "Blocked IPs"
        echo "------------------------------------------------------------"
        if [ -f "$BLOCKLIST_FILE" ] && [ -s "$BLOCKLIST_FILE" ]; then
            cat "$BLOCKLIST_FILE"
        else
            echo "No blocked IPs"
        fi
        echo ""

        echo "Security Tips"
        echo "------------------------------------------------------------"
        echo "1. Always use WPA2/WPA3 encryption"
        echo "2. Disable WPS on your router"
        echo "3. Change default admin credentials"
        echo "4. Update router firmware regularly"
        echo "5. Enable firewall on all devices"
        echo "6. Use VPN on public networks"
        echo "7. Monitor connected devices regularly"
        echo ""

    } > "$report_file"

    echo "[INFO] Report saved: $report_file"
    echo ""

    cat "$report_file"
}
