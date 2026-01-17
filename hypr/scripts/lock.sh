#!/usr/bin/env bash

# Get current wallpaper from swww
current_wallpaper=$(swww query | grep -oP 'image: \K.*')

# Update hyprlock.conf background path
sed -i "s|^	path = .*|	path = $current_wallpaper|" ~/.config/hypr/hyprlock.conf

# Run hyprlock
hyprlock