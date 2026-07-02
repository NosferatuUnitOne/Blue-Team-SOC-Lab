#!/bin/bash



services=(
  "wazuh-manager:Wazuh Manager"
  "wazuh-dashboard:Wazuh Dashboard"
  "wazuh-indexer:Wazuh Indexer"
)

ports=(
  "1515:wazuh-authd"
  "1514:wazuh-remoted"
)

check_service() {
    service_name="$1"
    display_name="$2"

    echo -n "Checking $display_name"


    systemctl is-active --quiet "$service_name" &
    pid=$!

 
    while kill -0 "$pid" 2>/dev/null; do
        echo -n "."
        sleep 0.3
    done


    wait "$pid"
    status=$?

    echo

    if [ "$status" -eq 0 ]; then
        echo "$display_name : Up"
        return 0
    else
        echo "$display_name : Down"
        return 1
    fi
}

check_port() {
    port="$1"
    name="$2"

    echo -n "Checking port $port for $name"

    ss -ltnp | grep -q ":$port " &
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        echo -n "."
        sleep 0.3
    done

    wait "$pid"
    status=$?

    echo

    if [ "$status" -eq 0 ]; then
        echo "Port $port > $name : Listening"
        return 0
    else
        echo "Port $port > $name : Not Listening"
        return 1
    fi
}

echo "======================================"
echo "        SIEM Stack Health Check"
echo "======================================"
echo

all_services_ok=true
all_ports_ok=true

for item in "${services[@]}"; do
    service_name="${item%%:*}"
    display_name="${item##*:}"

    check_service "$service_name" "$display_name"

    if [ "$?" -ne 0 ]; then
        all_services_ok=false
    fi

    echo
done

echo "--------------------------------------"
echo

for item in "${ports[@]}"; do
    port="${item%%:*}"
    name="${item##*:}"

    check_port "$port" "$name"

    if [ "$?" -ne 0 ]; then
        all_ports_ok=false
    fi

    echo
done

echo "--------------------------------------"
echo

if [ "$all_services_ok" = true ]; then
    echo "> All Services Up and Running!"
else
    echo "> Some Services Are Down!"
fi

if [ "$all_ports_ok" = true ]; then
    echo "> All Services Listening on Proper Ports!"
else
    echo "> Some Required Ports Are Not Listening!"
fi

if [ "$all_services_ok" = true ] && [ "$all_ports_ok" = true ]; then
    echo "> Green Light to Receive Logs from Deployed Agents [/]"
else
    echo "> Not Ready Yet. Fix the failed checks above. [X]"
fi
