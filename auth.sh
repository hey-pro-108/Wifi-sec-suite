#!/usr/bin/env bash

AUTH_FILE="$HOME/.wifi-security/auth.session"
AUTH_LOG="$HOME/.wifi-security/logs/auth.log"

init_auth() {
    mkdir -p "$(dirname "$AUTH_LOG")" 2>/dev/null
    touch "$AUTH_LOG"
}

check_auth() {
    if [ -f "$AUTH_FILE" ]; then
        local saved_time=$(cat "$AUTH_FILE" | cut -d'|' -f2)
        local current_time=$(date +%s)
        local diff=$((current_time - saved_time))

        if [ $diff -lt 3600 ]; then
            echo "verified"
            return
        fi
    fi

    echo "not_verified"
}

save_auth() {
    local username=$1
    local timestamp=$(date +%s)
    echo "$username|$timestamp" > "$AUTH_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGIN_SUCCESS|$username" >> "$AUTH_LOG"
}

clear_auth() {
    rm -f "$AUTH_FILE"
}

router_login() {
    local gateway=$(get_gateway)
    local router_ip="$gateway"

    echo ""
    echo "Router Authentication"
    echo "Gateway: $router_ip"
    echo ""

    echo -n "Router Username: "
    read -r username

    echo -n "Router Password: "
    read -rs password
    echo ""
    echo ""

    echo "[INFO] Verifying credentials..."

    if verify_router_credentials "$router_ip" "$username" "$password"; then
        echo "[SUCCESS] Authentication successful"
        save_auth "$username"
        echo "[INFO] Session saved for 1 hour"
    else
        echo "[FAILED] Authentication failed"
        echo "[WARN] Incorrect username or password"
        echo "[INFO] Login attempts logged"

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGIN_FAILED|$username|$router_ip" >> "$AUTH_LOG"
    fi

    echo ""
    echo -n "Press Enter to continue..."
    read -r
}

verify_router_credentials() {
    local router_ip=$1
    local username=$2
    local password=$3

    if command -v curl >/dev/null 2>&1; then
        local response=$(curl -s -o /dev/null -w "%{http_code}" \
            --connect-timeout 5 \
            --max-time 10 \
            -u "$username:$password" \
            "http://$router_ip/" 2>/dev/null)

        
        if [ "$response" = "200" ] || [ "$response" = "302" ]; then
            return 0
        fi
    fi

    if command -v wget >/dev/null 2>&1; then
        wget --spider --timeout=5 --user="$username" --password="$password" \
            "http://$router_ip/" 2>/dev/null
        if [ $? -eq 0 ]; then
            return 0
        fi
    fi

    return 1
}
