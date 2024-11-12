#!/bin/bash

# Error handling
set -euo pipefail

# Get brightness
if ! brightness=$(brightnessctl g); then
    notify-send -u critical "Brightness Error" "Failed to get brightness"
    exit 1
fi

if ! max_brightness=$(brightnessctl m); then
    notify-send -u critical "Brightness Error" "Failed to get max brightness"
    exit 1
fi

percent=$(( brightness * 100 / max_brightness ))

# Ensure percent is within bounds
if [ "$percent" -gt 100 ]; then
    percent=100
elif [ "$percent" -lt 0 ]; then
    percent=0
fi

dunstify -h string:x-canonical-private-synchronous:sys-notify \
         -a "Brightness" \
         -u low \
         -i display-brightness \
         -h string:x-dunst-stack-tag:brightness \
         "Brightness: ${percent}%" \
         -h int:value:"$percent"

