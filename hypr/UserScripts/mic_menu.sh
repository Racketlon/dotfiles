#!/bin/bash

CHOICE=$(echo -e "Toggle Mute\nSet Volume" | rofi -dmenu -p "Microphone Volume" -i)

SOURCE="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

if [ "$CHOICE" = "Toggle Mute" ]; then
    pactl set-source-mute "$SOURCE" toggle
elif [ "$CHOICE" = "Set Volume" ]; then
    CURRENT=$(pactl get-source-volume "$SOURCE" | awk -F'/' '{print $2}' | sed 's/%//' | xargs)
    VALUE=$(yad --scale --title="Set Microphone Volume" --value="$CURRENT" --min-value=0 --max-value=100 --step=1 --width=300 --height=100 --posx=-1 --posy=-1)
    if [ -n "$VALUE" ]; then
        pactl set-source-volume "$SOURCE" "${VALUE}%"
    fi
fi