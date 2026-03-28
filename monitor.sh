#!/usr/bin/env bash

start_monitor() {
    echo ""
    echo "Wi-Fi Security Suite - Monitor Active"
    echo "Platform: $(get_platform) | Gateway: $(get_gateway)"
    echo ""
    echo "[INFO] Monitoring started"
    echo "[INFO] Press Ctrl+C to stop"
    echo ""

    local gateway=$(get_gateway)
    local local_ip=$(get_local_ip)
    local arp_cache=""


    local gateway_mac_baseline=$(arp -a 2>/dev/null | grep "$gateway" | awk '{print $4}' | head -1)

    while true; do
        local current_arp=$(arp -a 2>/dev/null | grep -v incomplete || echo "")
        local timestamp=$(date '+%H:%M:%S')

        if [ -n "$current_arp" ] && [ "$current_arp" != "$arp_cache" ]; then
            local new_entries=$(comm -13 \
                <(echo "$arp_cache" | sort) \
                <(echo "$current_arp" | sort) 2>/dev/null)

            if [ -n "$new_entries" ]; then
                echo "[ARP] $timestamp - New ARP entry detected"
                echo "$new_entries" | while read -r line; do
                    local ip=$(echo "$line" | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)' | tr -d '()')
                    local mac=$(echo "$line" | awk '{print $4}')

                    if [ -n "$ip" ] && [ "$ip" != "$local_ip" ]; then
                        echo "      IP: $ip | MAC: $mac"

                        # Cek apakah IP ini ada di blocklist
                        local is_blocked=$(grep -c "$ip" "$BLOCKLIST_FILE" 2>/dev/null)
                        if [ "$is_blocked" -gt 0 ]; then
                            echo "[ALERT] Blocked IP detected: $ip"
                            log_threat "BLOCKED_IP" "$ip" "Blocked IP reconnected"
                        fi
                    fi
                done
            fi

            if [ -n "$gateway_mac_baseline" ]; then
                local gateway_mac_now=$(echo "$current_arp" | grep "$gateway" | awk '{print $4}' | head -1)
                if [ -n "$gateway_mac_now" ] && [ "$gateway_mac_now" != "$gateway_mac_baseline" ]; then
                    echo "[MITM] $timestamp - Possible ARP spoofing! Gateway MAC changed"
                    echo "       Was: $gateway_mac_baseline | Now: $gateway_mac_now"
                    log_threat "ARP_SPOOF" "$gateway" "Gateway MAC changed: $gateway_mac_baseline -> $gateway_mac_now"
                    # Update baseline supaya ga spam alert terus
                    gateway_mac_baseline="$gateway_mac_now"
                fi
            fi

            arp_cache="$current_arp"
        fi

        # Cek unusual connections (brute force indicator)
        local connections=$(netstat -tn 2>/dev/null | grep -c "ESTABLISHED" || echo 0)
        if [ "$connections" -gt 100 ]; then
            echo "[BRUTE] $timestamp - Unusual connection count: $connections"
            log_threat "BRUTE_FORCE" "local" "High connection count: $connections"
        fi

        sleep 2
    done
}

view_threats() {
    echo ""
    echo "Active Threats"
    echo ""

    if [ ! -s "$THREAT_LOG" ]; then
        echo "No threats detected yet"
        return
    fi

    echo "Timestamp           Type           Source              Details"
    echo ""

    tail -20 "$THREAT_LOG" | while IFS='|' read -r ts type source detail; do
        printf "  %-18s %-13s %-18s %s\n" "$ts" "$type" "$source" "$detail"
    done
    echo ""
}
