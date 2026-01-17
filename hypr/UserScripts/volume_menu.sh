#!/bin/bash

CHOICE=$(echo -e "Toggle Mute\nSet Volume" | rofi -dmenu -p "Volume" -i)

if [ "$CHOICE" = "Toggle Mute" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
elif [ "$CHOICE" = "Set Volume" ]; then
    CURRENT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
    VALUE=$(yad --scale --title="Set Volume" --value="$CURRENT" --min-value=0 --max-value=100 --step=1 --width=300 --height=100 --posx=-1 --posy=-1)
    if [ -n "$VALUE" ]; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${VALUE}%"
    fi
fi