````markdown
# Power Saving and Silent Mode Configuration with TLP on Ubuntu

This repository documents the steps I followed to make my Ubuntu system more stable and power-efficient using TLP (TLP Linux Advanced Power Management), optimizing it for silent operation both on battery and AC power.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [TLP Installation](#tlp-installation)
4. [TLP Configuration](#tlp-configuration)
   - Platform Profile
   - CPU Settings
   - Disk and SATA
   - USB Management
   - Network and Radio Interfaces
   - PCIe Runtime PM (GPU)
5. [Enabling and Verifying the Service](#enabling-and-verifying-the-service)
6. [Additional Settings for NVIDIA 3050](#additional-settings-for-nvidia-3050)
7. [Testing and Monitoring Tools](#testing-and-monitoring-tools)
8. [Contributing](#contributing)

---

## Introduction

TLP is a command-line power management tool that follows a "install and forget" philosophy, similar to Windows-like power-saving behaviors but without a GUI. This README guides you through configuring your Ubuntu system for low power consumption, reduced heat, and quieter fan operation, both on battery and AC power.

## Prerequisites

- Ubuntu 20.04 or newer
- A user with `sudo` privileges
- Internet connection (for downloading packages)

## TLP Installation

```bash
sudo apt update
sudo apt install tlp tlp-rdw
````

After installation, enable the service immediately:

```bash
sudo systemctl enable --now tlp.service
```

## TLP Configuration

All settings are located in `/etc/tlp.conf`. Add or modify the relevant sections with the following configuration:

```ini
# Platform Profile
PLATFORM_PROFILE_ON_AC=low-power
PLATFORM_PROFILE_ON_BAT=low-power

# CPU Settings
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0
CPU_ENERGY_PERF_POLICY_ON_AC=balance_power
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# Disk and SATA
DISK_IDLE_SECS_ON_AC=60
DISK_IDLE_SECS_ON_BAT=30
SATA_LINKPWR_ON_AC=min_power
SATA_LINKPWR_ON_BAT=min_power

# USB Management
USB_AUTOSUSPEND=1
USB_BLACKLIST="046d:c52b"

# Network and Radio Interfaces
WIFI_PWR_ON_BAT=1
DEVICES_TO_DISABLE_ON_BAT="bluetooth"

# PCIe Runtime PM (including GPU)
RUNTIME_PM_ON_AC=auto
RUNTIME_PM_ON_BAT=auto
RUNTIME_PM_BLACKLIST=""
```

## Enabling and Verifying the Service

```bash
sudo systemctl status tlp.service
```

You can check if TLP is running with:

```bash
tlp-stat -s
```

## Additional Settings for NVIDIA 3050

TLP alone doesn't fully manage discrete GPUs like the NVIDIA 3050. To extend power savings:

```bash
sudo systemctl mask power-profiles-daemon.service
```

Additionally, use tools like `nvidia-smi` or `switcheroo-control` to manage discrete GPU behavior.

Also consider installing `nvidia-prime` to switch between integrated and discrete graphics manually:

```bash
sudo apt install nvidia-prime
```

And switch to Intel GPU when on battery:

```bash
sudo prime-select intel
```

## Testing and Monitoring Tools

* `tlp-stat` – full status report
* `powertop` – real-time power consumption analysis
* `watch -n 1 cat /proc/acpi/battery/BAT0/state` – battery drain observation

## Contributing

Feel free to fork the repo, suggest improvements, or open issues if you encounter problems or have optimization tips for specific hardware setups.

```
```
