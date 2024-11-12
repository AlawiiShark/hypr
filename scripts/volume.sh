#!/bin/bash

# Play sound effect using paplay (you'll need 'libcanberra-pulse' package)
function play_sound() {
    paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &
}

# Get volume and mute status
function get_volume() {
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1)
    mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    echo "$volume" "$mute"
}

case $1 in
    up)
        # Increase volume
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        read -r volume mute <<< "$(get_volume)"
        play_sound
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i audio-volume-high "Volume: ${volume}%" -h int:value:"$volume"
        ;;
    down)
        # Decrease volume
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        read -r volume mute <<< "$(get_volume)"
        play_sound
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i audio-volume-low "Volume: ${volume}%" -h int:value:"$volume"
        ;;
    mute)
        # Toggle mute
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        read -r volume mute <<< "$(get_volume)"
        if [ "$mute" = "yes" ]; then
            notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i audio-volume-muted "Volume: Muted"
        else
            notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i audio-volume-high "Volume: Unmuted"
            play_sound
        fi
        ;;
esac

