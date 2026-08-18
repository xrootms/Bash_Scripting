#!/bin/bash

LOGFILE="/var/log/patching_$(date +%F_%H-%M-%S).log"

echo "==========================================" | tee -a $LOGFILE
echo "STARTING UBUNTU PRODUCTION PATCHING" | tee -a $LOGFILE
echo "==========================================" | tee -a $LOGFILE

# Check root user
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script as root" | tee -a $LOGFILE
    exit 1
fi

# Host information
echo "Hostname: $(hostname)" | tee -a $LOGFILE
echo "Date: $(date)" | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# OS Information
echo "OS Information:" | tee -a $LOGFILE
cat /etc/os-release | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Check disk space
echo "Checking disk space..." | tee -a $LOGFILE
df -h | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Check failed services
echo "Checking failed services..." | tee -a $LOGFILE
systemctl --failed | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Save current kernel
OLD_KERNEL=$(uname -r)
echo "Current Kernel: $OLD_KERNEL" | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Update package metadata
echo "Updating package repository..." | tee -a "$LOGFILE"

if apt update >> "$LOGFILE" 2>&1; then
    echo "Package repository updated successfully" | tee -a "$LOGFILE"
else
    echo "ERROR: apt update failed" | tee -a "$LOGFILE"
    exit 1
fi

echo "==========================================" | tee -a $LOGFILE

# Check available updates
echo "Available package updates:" | tee -a $LOGFILE
apt list --upgradable 2>/dev/null | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Install security updates package if not present

if ! dpkg -l | grep -q unattended-upgrades; then
  echo "Installing unattended-upgrades..." | tee -a "$LOGFILE"
if apt install unattended-upgrades -y >> "$LOGFILE" 2>&1; then
  echo "unattended-upgrades installed successfully" | tee -a "$LOGFILE"
else
  echo "ERROR: Failed to install unattended-upgrades" | tee -a "$LOGFILE"
 exit 1
fi
else
  echo "unattended-upgrades is already installed" | tee -a "$LOGFILE"
fi
echo "==========================================" | tee -a $LOGFILE

# Apply security patches
echo "Applying security patches..." | tee -a $LOGFILE

if unattended-upgrade >> $LOGFILE 2>&1; then
    echo "Security patching completed successfully" | tee -a $LOGFILE
else
    echo "ERROR: Security patching failed" | tee -a $LOGFILE
    exit 1
fi

echo "==========================================" | tee -a $LOGFILE

# Check kernel after patching
NEW_KERNEL=$(uname -r)

echo "Old Kernel: $OLD_KERNEL" | tee -a $LOGFILE
echo "Current Kernel: $NEW_KERNEL" | tee -a $LOGFILE

echo "==========================================" | tee -a $LOGFILE

# Check if reboot required
if [ -f /var/run/reboot-required ]; then
    echo "Reboot required." | tee -a $LOGFILE
else
    echo "No reboot required." | tee -a $LOGFILE
fi

echo "==========================================" | tee -a $LOGFILE
echo "PATCHING COMPLETED" | tee -a $LOGFILE
echo "Log file: $LOGFILE" | tee -a $LOGFILE
echo "==========================================" | tee -a $LOGFILE
