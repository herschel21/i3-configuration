#!/bin/bash
# Main screenshot script (save as screenshot-menu)
# Configuration
options="$HOME/.config/rofi/screenshot/options.txt"
scripts_dir="$HOME/.config/rofi/screenshot/scripts"

# Check if required files exist
if [ ! -f "$options" ]; then
    notify-send "Screenshot Error" "Options file not found: $options"
    exit 1
fi

if [ ! -d "$scripts_dir" ]; then
    notify-send "Screenshot Error" "Scripts directory not found: $scripts_dir"
    exit 1
fi

# Check for screenshot tools
if ! command -v maim >/dev/null && ! command -v scrot >/dev/null && ! command -v flameshot >/dev/null; then
    notify-send "Screenshot Error" "No screenshot tool found. Please install maim, scrot, or flameshot"
    exit 1
fi

# Display rofi menu for screenshot type
chosen=$(cat "$options" | rofi -p "Screenshot menu" -dmenu -i)

# Process selection
if [ ! -z "$chosen" ]; then
    action=$(echo "$chosen" | awk '{print $1}')
    
    # Prompt for filename using rofi
    filename=$(rofi -p "Enter filename (leave empty for timestamp) : " -dmenu -l 0)
    
    # If filename is empty, use timestamp
    if [ -z "$filename" ]; then
        filename="Screenshot from $(date +%Y-%m-%d\ %H-%M-%S)"
    fi
    
    # Small delay to allow menus to close
    sleep 0.5
    
    # Execute appropriate script
    case $action in
        a*)
            if [ -x "$scripts_dir/area-screenshot" ]; then
                "$scripts_dir/area-screenshot" "$filename"
            else
                notify-send "Screenshot Error" "Area screenshot script not executable"
            fi
            ;;
        w*)
            if [ -x "$scripts_dir/window-screenshot" ]; then
                "$scripts_dir/window-screenshot" "$filename"
            else
                notify-send "Screenshot Error" "Window screenshot script not executable"
            fi
            ;;
        *)
            if [ -x "$scripts_dir/full-screenshot" ]; then
                "$scripts_dir/full-screenshot" "$filename"
            else
                notify-send "Screenshot Error" "Full screenshot script not executable"
            fi
            ;;
    esac
else
    notify-send "Screenshot" "Screenshot cancelled"
fi
