#!/usr/bin/env bash

# Create month-based subdirectory
month_folder=$(date '+%Y-%m')
save_dir=$(xdg-user-dir PICTURES)/Screenshots/$month_folder
mkdir -p "$save_dir"

# Determine active window name and sanitize it
active_win=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
clean_title=$(echo "$active_win" | sed 's/[^a-zA-Z0-9_-]/_/g' | cut -c1-50)
if [ -z "$clean_title" ] || [ "$clean_title" = "null" ]; then
    clean_title="screenshot"
fi

# Define output path
save_path="$save_dir/${clean_title}_$(date '+%Y-%m-%d_%H.%M.%S').png"

# Capture a region to a temporary file
temp_file="/tmp/satty_temp_screenshot.png"
rm -f "$temp_file"

# Run grim to capture the active monitor or fallback to whole desktop
active_monitor=$(hyprctl activeworkspace -j | jq -r '.monitor' 2>/dev/null)
if [ -n "$active_monitor" ] && [ "$active_monitor" != "null" ]; then
    grim_cmd="grim -o $active_monitor"
else
    grim_cmd="grim"
fi

if $grim_cmd "$temp_file"; then
    # Run satty on the captured image in fullscreen mode with crop tool
    satty -f "$temp_file" -o "$save_path" --fullscreen --initial-tool crop --early-exit --save-after-copy
    
    # Check if the output file was saved/copied
    if [ -f "$save_path" ]; then
        wl-copy -t image/png < "$save_path"
        action=$(notify-send -i "$save_path" -a 'Screenshot' 'Скриншот сохранен' "Сохранено в $save_path и скопировано в буфер" --action="open=Открыть папку")
        if [ "$action" = "open" ]; then
            xdg-open "$(dirname "$save_path")"
        fi
    fi
fi

# Cleanup
rm -f "$temp_file"
