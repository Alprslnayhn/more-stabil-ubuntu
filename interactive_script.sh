#!/bin/bash
# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Reset color

# run_block function: Processes each block with an explanation, confirmation, and command execution.
run_block() {
    local description="$1"
    local commands="$2"
    local explanation="$3"

    echo -e "${BLUE}------------------------------------------------------${NC}"
    echo -e "${BLUE}Block: ${YELLOW}$description${NC}"
    echo -e "${GREEN}Commands to be executed:${NC}"
    echo -e "${GREEN}$commands${NC}"
    echo -e "Press [y] or Enter to execute, [n] to skip, or [e] to view the explanation."
    read -r -p "Your choice: " choice

    if [[ "$choice" == "e" ]]; then
        echo -e "${YELLOW}Explanation: $explanation${NC}"
        read -r -p "Press [y] or Enter to execute, or [n] to skip: " choice
    fi

    if [[ -z "$choice" || "$choice" == "y" ]]; then
        echo -e "${GREEN}Executing...${NC}"
        # Execute the commands line by line
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

# -------------------------------
# (Previous blocks: AppArmor, system update, firmware, Nvidia driver update, Snap/Flatpak operations, etc.)

# 1. Disable AppArmor permanently
run_block "Disable AppArmor" \
"sudo systemctl disable apparmor" \
"This command permanently disables the AppArmor security module. AppArmor enhances security by restricting application privileges, but may be disabled for compatibility or performance reasons."

# 2. System update and repair broken packages
run_block "System Update and Repair" \
"sudo apt update
sudo apt upgrade -y
sudo apt install -f
sudo dpkg --configure -a" \
"These commands update the package lists, upgrade outdated packages, fix broken dependencies, and complete any unfinished package configurations. They help resolve package issues from external sources."

# 3. Firmware update
run_block "Firmware Update" \
"sudo apt update
sudo apt install --reinstall linux-firmware" \
"These commands reinstall the linux-firmware package to ensure your hardware has the latest firmware."

# 4. Nvidia driver update
run_block "Nvidia Driver Update" \
"sudo apt purge nvidia-*
sudo apt install nvidia-driver-XXX" \
"These commands remove existing Nvidia drivers and install the specified Nvidia driver. Replace 'nvidia-driver-XXX' with the appropriate version for your system."

# 5. List and remove Snap packages (one by one)
run_block "Remove Snap Packages (List and Individual Removal)" \
"snap list
sudo snap remove --purge firefox
sudo snap remove --purge gnome-42-2204
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge snap-store
sudo snap remove --purge snapd-desktop-integration
sudo snap remove --purge bare
sudo snap remove --purge core22" \
"These commands first list the installed Snap packages, then remove specific Snap packages completely from the system."

# 6. Remove Snapd and its dependencies
run_block "Remove Snapd and Its Dependencies" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap /snap ~/snap" \
"These commands remove the Snapd package manager and its associated directories from the system."

# 7. Stop and disable Snap-related systemd services
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
"These commands stop Snap-related systemd services and prevent them from starting automatically."

# 8. Additional Snap cleanup
run_block "Additional Snap Cleanup" \
"sudo apt purge snapd -y
sudo rm -rf /var/snap
sudo rm -rf /snap" \
"These commands completely remove the Snap package system and its associated directories."

# 9. Prevent Snap from being reinstalled by creating an apt preference
run_block "Prevent Snap Reinstallation" \
"sudo tee /etc/apt/preferences.d/no-snap.pref > /dev/null <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF" \
"This command creates a no-snap.pref file in /etc/apt/preferences.d/ to prevent the Snapd package from being reinstalled by setting its priority to -10."

# 10. Clean up user Snap directory, remove unnecessary packages, and update the system
run_block "Clean Up Snap Directories and Update System" \
"sudo rm -rf ~/snap
sudo apt autoremove -y
sudo apt update
sudo apt upgrade -y" \
"These commands remove the Snap directory from your home folder, clean up unused packages, and update your system."

# 11. Install Flatpak and add the Flathub repository
run_block "Install Flatpak and Add Flathub Repository" \
"sudo apt install flatpak -y
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" \
"These commands install the Flatpak package manager and add the popular Flathub repository, providing an alternative method for installing applications."

# 12. Ubuntu GNOME desktop installation / GNOME Core / Tweaks & Extensions / Additional theme and icon packages
echo -e "${BLUE}------------------------------------------------------${NC}"
echo -e "${BLUE}Which desktop interface would you like to use?${NC}"
echo -e "${GREEN}[1] Ubuntu GNOME Desktop (Default)${NC}"
echo -e "${GREEN}[2] Legacy Ubuntu Interface (Update and gnome-software installation)${NC}"
read -r -p "Your choice (1/2): " interface_choice
echo -e "${BLUE}------------------------------------------------------${NC}"
echo ""

if [[ "$interface_choice" == "2" ]]; then
    # Legacy Ubuntu interface selected
    run_block "Legacy Ubuntu Interface Setup" \
    "sudo apt update
sudo apt install --install-suggests gnome-software" \
    "These commands update the package lists and install the gnome-software package needed for the legacy Ubuntu interface. Press 'e' to view the explanation."
else
    # Default to GNOME desktop installation
    run_block "Ubuntu GNOME Desktop Installation" \
    "sudo apt update
sudo apt install ubuntu-gnome-desktop" \
    "These commands install the Ubuntu GNOME desktop environment."
    
    run_block "GNOME Core Installation" \
    "sudo apt install gnome-core" \
    "This command installs the core components of the GNOME desktop."
    
    run_block "GNOME Tweaks and Extensions Installation" \
    "sudo apt install gnome-tweaks gnome-shell-extensions" \
    "These commands install additional configuration tools and shell extensions for GNOME."
    
    run_block "Additional GNOME Theme and Icon Packages Installation" \
    "sudo apt install adwaita-icon-theme-full gnome-themes-extra gtk2-engines-pixbuf -y" \
    "This command installs additional themes, icons, and graphics engine packages for the GNOME desktop."
fi

echo -e "${BLUE}All blocks have been completed.${NC}"
echo ""

# -------------------------------
# Ubuntu Pro Cleanup Operations
echo -e "${BLUE}------------------------------------------------------${NC}"
echo -e "${BLUE}Are you using Ubuntu Pro on your computer?${NC}"
echo -e "${GREEN}[1] Yes, I am using Ubuntu Pro.${NC}"
echo -e "${GREEN}[2] No, I am not using it.${NC}"
read -r -p "Your choice (1/2): " ubuntu_pro_choice
echo -e "${BLUE}------------------------------------------------------${NC}"
echo ""

if [[ "$ubuntu_pro_choice" == "1" ]]; then
    run_block "Ubuntu Pro Cleanup" \
    "sudo apt purge ubuntu-advantage-tools -y
sudo rm -rf /var/lib/ubuntu-advantage/ubuntu_pro_esm_cache
echo -e \"\${YELLOW}Please open /etc/apt/sources.list and manually remove any lines containing 'esm' or 'ubuntu-pro'. Once done, press Enter.\"
read -r -p \"Press Enter to continue...\" 
sudo rm /etc/apt/sources.list.d/ubuntu-pro-*.list
sudo apt update
sudo apt autoremove --purge -y
ls -l /var/lib/update-notifier
sudo rm -r /var/lib/update-notifier
sudo apt install --reinstall ubuntu-release-upgrader-core -y
sudo apt purge ubuntu-release-upgrader-core -y
sudo apt autoremove --purge -y" \
    "Ubuntu Pro is unnecessary and may cause conflicts with other packages. In particular, 'ubuntu-advantage-tools' and its associated cache files can lead to issues. These steps remove Ubuntu Pro related tools and extra files."
else
    echo -e "${GREEN}Ubuntu Pro cleanup skipped.${NC}"
fi

echo -e "${BLUE}Script completed. Your system has been updated and your preferences applied.${NC}"
