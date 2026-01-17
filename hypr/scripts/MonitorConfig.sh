#!/usr/bin/env bash
# Monitor Configuration Script for Hyprland

# --- Configuration ---
IDIR="$HOME/.config/swaync/images"

# --- Helper Functions ---

# Function to send a notification
notify_user() {
  notify-send -u low -i "$1" "$2" "$3"
}

# Function to get monitor info
get_monitors() {
  hyprctl monitors | awk '/Monitor/ {print $2}' | head -2
}

# Function to apply monitor config
apply_config() {
  local config="$1"
  hyprctl keyword monitor "$config"
}

# Function to set workspace rules
set_workspace_rules() {
  local setup="$1"
  case "$setup" in
    "Laptop Only")
      for i in {1..10}; do hyprctl keyword workspace $i,monitor:$laptop; done
      ;;
    "External Only")
      for i in {1..10}; do hyprctl keyword workspace $i,monitor:$external; done
      ;;
    "Extend Right"|"Extend Left")
      # For extend, assign existing workspaces to laptop, let new ones go to focused monitor
      # Get active workspaces on laptop
      active_workspaces=$(hyprctl workspaces | grep "workspace ID" | awk '{print $3}' | sort -n)
      for ws in $active_workspaces; do
        if [ "$ws" -le 5 ]; then
          hyprctl keyword workspace $ws,monitor:$laptop
        fi
      done
      ;;
    "Mirror")
      for i in {1..10}; do hyprctl keyword workspace $i,monitor:$laptop; done
      ;;
  esac
}

# --- Main Script Execution ---

# Get monitors
monitors=($(get_monitors))
if [ ${#monitors[@]} -eq 0 ]; then
  notify_user "$IDIR/error.png" "No Monitors" "No monitors detected."
  exit 1
fi

# Define configs based on number of monitors
if [ ${#monitors[@]} -eq 1 ]; then
  options=("Laptop Only: ${monitors[0]},preferred,0x0,1")
elif [ ${#monitors[@]} -eq 2 ]; then
  laptop="${monitors[0]}"
  external="${monitors[1]}"
  # Get laptop width
  laptop_width=$(hyprctl monitors | grep "$laptop" -A 5 | grep 'Size' | awk '{print $2}' | cut -dx -f1)
  if [ -z "$laptop_width" ]; then laptop_width=1920; fi  # fallback
  options=(
    "Laptop Only: $laptop,preferred,0x0,1 ; $external,disable"
    "External Only: $external,preferred,0x0,1 ; $laptop,disable"
    "Extend Right: $laptop,preferred,0x0,1 ; $external,preferred,${laptop_width}x0,1"
    "Extend Left: $laptop,preferred,${laptop_width}x0,1 ; $external,preferred,0x0,1"
    "Mirror: $laptop,preferred,0x0,1,mirror,$external"
  )
fi

# Use rofi to select
selected=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Monitor Setup")

if [ -n "$selected" ]; then
  # Extract the setup name before :
  setup_name=$(echo "$selected" | cut -d: -f1)
  # Extract the config part after :
  config_part=$(echo "$selected" | cut -d: -f2- | sed 's/^ *//')
  # Split by ; and apply each
  IFS=';' read -ra configs <<< "$config_part"
  for config in "${configs[@]}"; do
    config=$(echo "$config" | sed 's/^ *//')
    if [ -n "$config" ]; then
      apply_config "$config"
    fi
  done
  # Set workspace rules
  set_workspace_rules "$setup_name"
  notify_user "$IDIR/ja.png" "Monitor Setup Applied" "$selected"
else
  notify_user "$IDIR/note.png" "Monitor Setup" "Cancelled"
fi

exit 0