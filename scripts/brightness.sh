#!/bin/bash

# Error handling
set -euo pipefail

# Logging function
log_error() {
    logger -t "brightness.sh" -p user.error "$1"
    notify-send -u critical "Brightness Error" "$1"
}

# Check if brightnessctl is installed
if ! command -v brightnessctl &> /dev/null; then
    log_error "brightnessctl is not installed"
    exit 1
fi

# Get brightness with timeout
if ! brightness=$(timeout 2s brightnessctl g 2>/dev/null); then
    log_error "Failed to get brightness"
    exit 1
fi

if ! max_brightness=$(timeout 2s brightnessctl m 2>/dev/null); then
    log_error "Failed to get max brightness"
    exit 1
fi

# Calculate percentage with floating point precision
percent=$(awk "BEGIN {printf \"%.0f\", $brightness * 100 / $max_brightness}")

# Ensure percent is within bounds
if [ "$percent" -gt 100 ]; then
    percent=100
elif [ "$percent" -lt 0 ]; then
    percent=0
fi

# Try to send notification, fall back to notify-send if dunstify fails
if ! dunstify -h string:x-canonical-private-synchronous:sys-notify \
              -a "Brightness" \
              -u low \
              -i display-brightness \
              -h string:x-dunst-stack-tag:brightness \
              "Brightness: ${percent}%" \
              -h int:value:"$percent"; then
    notify-send -u low "Brightness" "Brightness: ${percent}%"
fi

