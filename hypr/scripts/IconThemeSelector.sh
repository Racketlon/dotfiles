#!/usr/bin/env bash
# Icon Theme Selector for Hyprland

# --- Configuration ---
IDIR="$HOME/.config/swaync/images"  # For notifications

# --- Helper Functions ---

# Function to send a notification
notify_user() {
  notify-send -u low -i "$1" "$2" "$3"
}

# Function to apply the selected icon theme
apply_icon_theme() {
  local theme_name="$1"
  gsettings set org.gnome.desktop.interface icon-theme "$theme_name"
  # Also update the active Rofi theme to use the same icon theme
  local rofi_config_file="$HOME/.config/rofi/config.rasi"
  local current_theme_path=$(grep -oP '^\s*@theme\s*"\K[^"]+' "$rofi_config_file" | tail -n 1)
  if [[ "$current_theme_path" =~ ^~ ]]; then
    current_theme_path="${HOME}${current_theme_path#~}"
  fi
  if [[ -f "$current_theme_path" ]]; then
    sed -i '/icon-theme:/d' "$current_theme_path"
    sed -i '/show-icons:/a\    icon-theme: "'$theme_name'";' "$current_theme_path"
  fi
  return 0
}

# --- Main Script Execution ---

# Generate a sorted list of available icon theme names
mapfile -t available_themes < <( (find /usr/share/icons -maxdepth 1 -type d -exec basename {} \; 2>/dev/null; find ~/.local/share/icons -maxdepth 1 -type d -exec basename {} \; 2>/dev/null) | sort -V -u )

if [ ${#available_themes[@]} -eq 0 ]; then
  notify_user "$IDIR/error.png" "No Icon Themes" "No icon themes found in /usr/share/icons."
  exit 1
fi

# Get the currently active theme
current_theme=$(gsettings get org.gnome.desktop.interface icon-theme | sed 's/'\''//g')

# Find the index of the current theme
current_selection_index=0
for i in "${!available_themes[@]}"; do
  if [[ "${available_themes[$i]}" == "$current_theme" ]]; then
    current_selection_index=$i
    break
  fi
done

# Main loop
while true; do
  # Prepare theme list for Rofi
  rofi_input_list=""
  for theme in "${available_themes[@]}"; do
    rofi_input_list+="$theme\n"
  done
  rofi_input_list_trimmed="${rofi_input_list%\\n}"

  # Launch Rofi and get user's choice
  chosen_index=$(echo -e "$rofi_input_list_trimmed" |
    rofi -dmenu -i \
      -format 'i' \
      -p "Icon Theme" \
      -mesg "‼️ **note** ‼️ Enter: Preview || Ctrl+S: Apply & Exit || Esc: Cancel" \
      -selected-row "$current_selection_index" \
      -kb-custom-1 "Control+s")

  rofi_exit_code=$?

  # Handle Rofi's exit code
  if [ $rofi_exit_code -eq 0 ]; then # Enter (preview)
    if [[ "$chosen_index" =~ ^[0-9]+$ ]] && [ "$chosen_index" -lt "${#available_themes[@]}" ]; then
      current_selection_index="$chosen_index"
      apply_icon_theme "${available_themes[$chosen_index]}"
      notify_user "$IDIR/ja.png" "Icon Theme Preview" "Applied ${available_themes[$chosen_index]} (restart apps to see changes)"
    fi
  elif [ $rofi_exit_code -eq 1 ]; then # Escape
    notify_user "$IDIR/note.png" "Icon Theme" "Selection cancelled. Reverting."
    apply_icon_theme "$current_theme"
    break
  elif [ $rofi_exit_code -eq 10 ]; then # Custom bind 1 (Ctrl+S)
    notify_user "$IDIR/ja.png" "Icon Theme Applied" "${available_themes[$current_selection_index]}"
    break
  else # Error
    notify_user "$IDIR/error.png" "Rofi Error" "Unexpected exit code. Reverting."
    apply_icon_theme "$current_theme"
    break
  fi
done

exit 0