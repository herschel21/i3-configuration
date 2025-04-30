#!/bin/bash

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Constants
readonly REPO_URL="https://github.com/herschel21/i3-configuration/archive/refs/heads/main.zip" # Replace with your actual repo URL
readonly TEMP_DIR="/tmp/i3_config_install_$(date +%s)"
readonly DEST_DIR="$HOME/.config"
readonly LOG_FILE="$TEMP_DIR/install.log"

# Color constants
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

sudo apt install -y \
    i3 \
    i3lock \
    i3blocks \
    feh \
    picom \
    rofi \
    nautilus \
    blueman \
    flameshot \
    pavucontrol


# Function to log messages
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} - ${message}" | tee -a "$LOG_FILE"
}

# Function to log errors
error_log() {
    log "${RED}ERROR: $1${NC}"
}

# Function to handle errors
error_exit() {
    error_log "$1"
    error_log "Installation failed. Check the log file at: $LOG_FILE"
    exit 1
}

# Function to check command availability
check_command() {
    if ! command -v "$1" &>/dev/null; then
        error_exit "Required command '$1' not found. Please install it first."
    fi
}

# Function to install i3 configuration
install_config() {
    log "Cloning i3 configuration repository..."
    git clone "$REPO_URL" "$TEMP_DIR/repo" || error_exit "Failed to clone repository"
    
    log "Installing configurations..."
    mkdir -p "$DEST_DIR" || error_exit "Failed to create config directory"
    
    # Copy each configuration directory
    local dirs=("i3" "i3blocks" "picom" "rofi")
    for dir in "${dirs[@]}"; do
        if [ -d "$TEMP_DIR/repo/$dir" ]; then
            cp -r "$TEMP_DIR/repo/$dir" "$DEST_DIR/" || error_exit "Failed to copy $dir configuration"
            log "Installed $dir configuration to $DEST_DIR/$dir"
        else
            log "${YELLOW}Warning: $dir directory not found in repository${NC}"
        fi
    done
}

# Main installation process
main() {
    # Create temporary directory and start logging
    mkdir -p "$TEMP_DIR" || error_exit "Failed to create temporary directory"
    log "Starting i3 configuration installation..."
    
    # Check prerequisites
    check_command git
    check_command i3
    
    # Perform installation steps
    install_config
    
    # Cleanup
    log "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    
    log "${GREEN}Installation completed successfully!${NC}"
    log "i3 configuration has been installed to: $DEST_DIR/i3"
    log "i3blocks configuration has been installed to: $DEST_DIR/i3blocks"
    log "picom configuration has been installed to: $DEST_DIR/picom"
    log "rofi configuration has been installed to: $DEST_DIR/rofi"
    [ -d "$BACKUP_DIR" ] && log "Previous configurations were backed up to: $BACKUP_DIR"
    log "${YELLOW}Note: Ensure the following files exist for full i3 functionality:${NC}"
    log "  - ~/Pictures/homescreen.png (for background)"
    log "  - ~/Pictures/lockscreen.png (for lock screen)"
    log "  - ~/.config/i3/display_setup.sh"
    log "  - ~/.Xresources"
    log "  - ~/.config/rofi/helper/wifi_launcher.sh"
    log "  - ~/.config/rofi/helper/volume_control.pl"
    log "  - ~/.config/rofi/helper/brightness_control.pl"
    log "  - ~/.config/rofi/powermenu/powermenu.sh"
}

# Execute main function
main "$@"
