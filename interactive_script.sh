#!/bin/bash
# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# run_block function: Processes each block with a description, confirmation prompt, and command execution.
run_block() {
    local description="$1"
    local commands="$2"
    local explanation="$3"

    echo -e "${BLUE}------------------------------------------------------${NC}"
    echo -e "${BLUE}Block: ${YELLOW}$description${NC}"
    echo -e "${GREEN}Commands to be executed:${NC}"
    echo -e "${GREEN}$commands${NC}"
    echo -e "Press [y] or Enter to execute, [n] to skip, or [e] to view an explanation."
    read -r -p "Your choice: " choice

    if [[ "$choice" == "e" ]]; then
        echo -e "${YELLOW}Explanation: $explanation${NC}"
        read -r -p "Press [y] or Enter to execute, or [n] to skip: " choice
    fi

    if [[ -z "$choice" || "$choice" == "y" ]]; then
        echo -e "${GREEN}Executing...${NC}"
        # Execute commands line by line
        while IFS= read -r line; do
            # Skip empty lines or comment lines
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            echo -e "${BLUE}Executing: ${NC}$line"
            eval "$line"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Success.${NC}"
            else
                echo -e "${RED}Error occurred.${NC}"
            fi
        done <<< "$commands"
    else
        echo -e "${RED}Block skipped: $description${NC}"
    fi
    echo -e "${BLUE}------------------------------------------------------${NC}"
    echo ""
}

# 1. Disable AppArmor permanently
run_block "Disable AppArmor" \
"sudo systemctl disable apparmor" \
"This command permanently disables the AppArmor security module. AppArmor increases system security by restricting program access rights, but it may be disabled in some cases for compatibility or performance reasons."

# 2. System Update and Repair
run_block "System Update and Repair" \
"sudo apt update
sudo apt upgrade -y
sudo apt install -f
sudo dpkg --configure -a" \
"These commands update package lists, upgrade outdated packages, repair broken dependencies, and complete unfinished configurations. They are used to resolve package issues arising from online sources."

# 3. Firmware Update
run_block "Firmware Update" \
"sudo apt update
sudo apt install --reinstall linux-firmware" \
"These commands reinstall the Linux firmware package, ensuring your hardware has the latest firmware."

# 4. Update Nvidia Drivers
run_block "Update Nvidia Drivers" \
"sudo apt purge nvidia-*
sudo apt install nvidia-driver-XXX" \
"These commands remove the current Nvidia drivers and install the specified Nvidia driver. Replace 'nvidia-driver-XXX' with the appropriate driver version for your system."

# 5. Remove Snap Packages (Individual Removal)
run_block "Remove Snap Packages (Individual Removal)" \
"snap list
sudo snap remove --purge firefox
sudo snap remove --purge gnome-42-2204
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge snap-store
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge bare
sudo snap remove --purge core22" \
"These commands first list installed Snap packages, then completely remove specified Snap packages from the system."

# 6. Remove Snapd and Dependencies
run_block "Remove Snapd and Dependencies" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap /snap ~/snap" \
"These commands remove the Snapd package manager and its dependencies from your system, and clean up directories related to Snap."

# 7. Stop and Disable Snap-related systemd Services
run_block "Stop and Disable Snap Services" \
"sudo systemctl stop snap-bare-5.mount
sudo systemctl stop snap-core22-1612.mount
sudo systemctl stop snapd.mounts-pre.target
sudo systemctl disable snap-bare-5.mount
sudo systemctl disable snap-core22-1612.mount
sudo systemctl disable snapd.mounts-pre.target
sudo systemctl stop snapd.socket
sudo systemctl stop snapd.service
sudo systemctl disable snapd.socket
sudo systemctl disable snapd.service" \
"These commands stop the Snap-related systemd services to prevent them from starting automatically."

# 8. Additional Snap Cleanup
run_block "Additional Snap Cleanup" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap
sudo rm -rf /snap" \
"These commands completely remove the Snap package system and its associated directories."

# 9. Prevent Snap from Being Reinstalled
run_block "Prevent Snap Reinstallation" \
"sudo tee /etc/apt/preferences.d/no-snap.pref > /dev/null <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF" \
"This command creates the no-snap.pref file in the /etc/apt/preferences.d/ directory, configuring package priorities to prevent Snapd from being reinstalled."

# 10. Clean Snap Folders and Update System
run_block "Clean Snap Folders and Update System" \
"sudo rm -rf ~/snap
sudo apt autoremove -y
sudo apt update
sudo apt upgrade -y" \
"These commands remove the Snap folder in the user's directory, clean up unused dependencies, and update the system."

# 11. Install Flatpak and Add Flathub Repository
run_block "Install Flatpak and Add Flathub" \
"sudo apt install flatpak -y
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" \
"These commands install the Flatpak package manager and add the popular Flathub repository, providing an alternative method for application installation."

# 12. Install Ubuntu GNOME Desktop
run_block "Install Ubuntu GNOME Desktop" \
"sudo apt update
sudo apt install ubuntu-gnome-desktop" \
"These commands install the Ubuntu GNOME desktop environment on your system."

# 13. Install GNOME Core
run_block "Install GNOME Core" \
"sudo apt install gnome-core" \
"This command installs the core components of the GNOME desktop."

# 14. Install GNOME Tweaks and Extensions
run_block "Install GNOME Tweaks and Extensions" \
"sudo apt install gnome-tweaks gnome-shell-extensions" \
"These commands install additional configuration tools and shell extensions for GNOME."

# 15. Install Additional GNOME Theme and Icon Packages
run_block "Install Additional GNOME Theme and Icon Packages" \
"sudo apt install adwaita-icon-theme-full gnome-themes-extra gtk2-engines-pixbuf -y" \
"This command installs additional themes, icons, and graphical engine packages for the GNOME desktop."

echo -e "${BLUE}All blocks completed.${NC}"
