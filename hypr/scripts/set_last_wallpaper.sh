#!/bin/bash

# Start swww-daemon if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format xrgb &
    sleep 1
fi

# Default wallpaper
DEFAULT_WALLPAPER="$HOME/Pictures/wallpapers/hyprland-wallpaper_1.png"

# Check for last wallpaper
LAST_WALLPAPER="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

if [ -f "$LAST_WALLPAPER" ]; then
    WALLPAPER_TO_SET="$LAST_WALLPAPER"
else
    WALLPAPER_TO_SET="$DEFAULT_WALLPAPER"
fi

# Set the wallpaper based on file type
if [[ "$WALLPAPER_TO_SET" =~ \.(mp4|mkv|mov|webm|gif|MP4|MKV|MOV|WEBM|GIF)$ ]]; then
    # Kill swww if running
    swww kill 2>/dev/null || true
    pkill mpvpaper 2>/dev/null || true
    # Get all monitor names
    monitors=$(hyprctl monitors -j | jq -r '.[].name')
    # Set video/GIF wallpaper to each monitor using mpvpaper
    for monitor in $monitors; do
        mpvpaper "$monitor" -o "load-scripts=no no-audio --loop --video-unscaled=no --keepaspect=no" "$WALLPAPER_TO_SET" &
    done
else
# Kill mpvpaper if running
pkill mpvpaper 2>/dev/null || true
# Start swww-daemon if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon --format xrgb &
    sleep 1
fi
# Set image wallpaper using swww (to all monitors)
swww img "$WALLPAPER_TO_SET" --transition-type outer --transition-duration 2.0 --transition-fps 60
fi