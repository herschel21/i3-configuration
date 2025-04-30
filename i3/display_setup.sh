#!/bin/bash

# INTERNAL="eDP" CONNECTED=$(xrandr | grep " connected" | awk '{ print $1 }')
#
# # Automatically detect the first connected external display (not INTERNAL)
# EXTERNAL=$(echo "$CONNECTED" | grep -v "^$INTERNAL" | head -n 1)
#
# # Check if an external display was found
# if [ -n "$EXTERNAL" ]; then
#     POSITION=$(zenity --list --title="External Display Position" \
#         --text="Where do you want to place the external display ($EXTERNAL) relative to $INTERNAL?" \
#         --radiolist --column "Select" --column "Position" \
#         TRUE "above" FALSE "below" FALSE "left-of" FALSE "right-of")
#
#     if [ -n "$POSITION" ]; then
#         xrandr --output "$EXTERNAL" --mode 1920x1080 --"$POSITION" "$INTERNAL" --output "$INTERNAL" --auto
#         notify-send "Display Setup" "External display ($EXTERNAL) positioned $POSITION of internal ($INTERNAL)."
#     else
#         notify-send "Display Setup" "No position selected. No changes made."
#     fi
# else
#     xrandr --output "$INTERNAL" --auto
#     notify-send "Display Setup" "Only internal display ($INTERNAL) is active."
# fi

INTERNAL="eDP"
CONNECTED=$(xrandr | grep " connected" | awk '{ print $1 }')

# Automatically detect the first connected external display (not INTERNAL)
EXTERNAL=$(echo "$CONNECTED" | grep -v "^$INTERNAL" | head -n 1)

# If no external display found
if [ -z "$EXTERNAL" ]; then
    xrandr --auto 2>/dev/null
    notify-send "Display Setup" "Only internal display ($INTERNAL) is active."
    exit 0
fi

# Prompt user for display mode
MODE=$(zenity --list --title="Choose Display Mode" \
    --text="Select how you want to use the displays:" \
    --radiolist --column "Select" --column "Mode" \
    TRUE "Extend (position external relative to internal)" \
    FALSE "Internal Only" \
    FALSE "External Only")

if [ "$MODE" == "Internal Only" ]; then
    xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --off
    notify-send "Display Setup" "Only internal display ($INTERNAL) is active."
    exit 0
elif [ "$MODE" == "External Only" ]; then
    xrandr --output "$EXTERNAL" --auto --output "$INTERNAL" --off
    notify-send "Display Setup" "Only external display ($EXTERNAL) is active."
    exit 0
elif [ "$MODE" == "Extend (position external relative to internal)" ]; then
    POSITION=$(zenity --list --title="External Display Position" \
        --text="Where do you want to place the external display ($EXTERNAL) relative to $INTERNAL?" \
        --radiolist --column "Select" --column "Position" \
        TRUE "above" FALSE "below" FALSE "left-of" FALSE "right-of")

    if [ -n "$POSITION" ]; then
        xrandr --output "$EXTERNAL" --mode 1920x1080 --"$POSITION" "$INTERNAL" --output "$INTERNAL" --auto
        notify-send "Display Setup" "External display ($EXTERNAL) positioned $POSITION of internal ($INTERNAL)."
    else
        notify-send "Display Setup" "No position selected. No changes made."
    fi
else
    notify-send "Display Setup" "No mode selected. No changes made."
fi
