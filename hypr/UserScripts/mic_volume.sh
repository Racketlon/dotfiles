#!/bin/bash

SOURCE="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source"

if [ "$1" = "set" ]; then
    pactl set-source-volume "$SOURCE" "$2%"
elif [ "$1" = "get" ]; then
    pactl get-source-volume "$SOURCE" | awk '{print $5}' | tr -d '%'
fi