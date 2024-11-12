#!/bin/bash

# Get brightness
brightness=$(brightnessctl g)
max_brightness=$(brightnessctl m)
percent=$(( brightness * 100 / max_brightness ))

dunstify -a "Brightness" -u low -i display-brightness -h string:x-dunst-stack-tag:brightness "Brightness: ${percent}%" -h int:value:"$percent"

