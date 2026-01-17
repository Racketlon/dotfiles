#!/bin/bash

case "$1" in
    --toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    --inc)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    --dec)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    --toggle-mic)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
    --mic-inc)
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+
        ;;
    --mic-dec)
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-
        ;;
    *)
        echo "Usage: $0 --toggle|--inc|--dec|--toggle-mic|--mic-inc|--mic-dec"
        exit 1
        ;;
esac