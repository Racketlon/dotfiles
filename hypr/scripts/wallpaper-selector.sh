#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SYMLINK_PATH="$HOME/.config/hypr/current_wallpaper"

cd "$WALLPAPER_DIR" || exit 1

# === handle spaces name
IFS=$'\n'

# === ICON-PREVIEW SELECTION WITH ROFI, SORTED ALPHABETICALLY BY FILENAME ===
SELECTED_WALL=$(find . -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.jpeg" \) -exec basename {} \; | sort | uniq | rofi -dmenu -i -config ~/.config/rofi/wallpaper-config.rasi -p "Choose wallpaper")
[ -z "$SELECTED_WALL" ] && exit 1
# Find the full path for the selected filename
SELECTED_PATH=$(find "$WALLPAPER_DIR" -type f -name "$SELECTED_WALL" | head -1)

# === SET WALLPAPER ===
swww img "$SELECTED_PATH" --transition-type outer --transition-duration 2.0 --transition-fps 60

# === CREATE SYMLINK ===
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$SELECTED_PATH" "$SYMLINK_PATH"