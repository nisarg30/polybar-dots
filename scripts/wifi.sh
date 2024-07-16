#!/bin/bash

INTERFACE="enp0s3"  # Replace with your WiFi interface name
NMCLI="nmcli"        # Adjust if using a different network manager command

get_status() {
    local status="$($NMCLI -t -f WIFI,STATE general)"
    if [[ "$status" == "enabled:connected" ]]; then
        echo "connected"
    elif [[ "$status" == "enabled:disconnected" ]]; then
        echo "disconnected"
    else
        echo "unknown"
    fi
}

get_available_networks() {
    $NMCLI -t -f ssid dev wifi list
}

connect_to_network() {
    local ssid="$1"
    $NMCLI device wifi connect "$ssid"
}

disconnect_from_network() {
    local device="$($NMCLI -t -f GENERAL.DEVICE dev wifi status | head -n1)"
    $NMCLI device disconnect "$device"
}

toggle_wifi() {
    local state="$($NMCLI -t -f WIFI general)"
    if [[ "$state" == "enabled" ]]; then
        $NMCLI radio wifi off
    else
        $NMCLI radio wifi on
    fi
}

main() {
    case "$1" in
        status)
            get_status
            ;;
        --toggle)
            toggle_wifi
            ;;
        --list)
            get_available_networks
            ;;
        --connect)
            connect_to_network "$2"
            ;;
        --disconnect)
            disconnect_from_network
            ;;
        *)
            echo "unknown command"
            exit 1
            ;;
    esac
}

main "$@"
