#!/bin/bash

# Setup script for Secure Boot with Tuxedo modules
# This script helps users enroll the MOK key for Secure Boot compatibility

set -e

echo "=== Tuxedo Secure Boot Setup ==="
echo ""
echo "This script will help you enroll the MOK (Machine Owner Key) for Secure Boot compatibility."
echo "The Tuxedo kernel modules are signed with a custom key that needs to be enrolled in Secure Boot."
echo ""

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

# Check if Secure Boot is enabled
if [ -d /sys/firmware/efi/efivars ] && [ -f /sys/firmware/efi/efivars/SecureBoot-* ]; then
    SECURE_BOOT=$(cat /sys/firmware/efi/efivars/SecureBoot-* 2>/dev/null | od -An -t u1 | awk '{print $1}')
    if [ "$SECURE_BOOT" = "1" ]; then
        echo "✓ Secure Boot is enabled"
    else
        echo "⚠ Secure Boot is disabled - no MOK enrollment needed"
        echo "The Tuxedo modules should work without additional setup."
        exit 0
    fi
else
    echo "⚠ Cannot determine Secure Boot status"
    echo "Proceeding with MOK enrollment instructions..."
fi

# Check if MOK key exists
if [ ! -f "/etc/pki/akmods/certs/signing_key.x509" ]; then
    echo "❌ MOK key not found at /etc/pki/akmods/certs/signing_key.x509"
    echo "Please ensure you're running this on a system with Tuxedo modules installed."
    exit 1
fi

echo "✓ MOK key found"
echo ""

# Check if mokutil is available
if command -v mokutil >/dev/null 2>&1; then
    echo "=== MOK Enrollment Instructions ==="
    echo ""
    echo "To enroll the MOK key for Secure Boot:"
    echo ""
    echo "1. Run the following command to import the MOK key:"
    echo "   sudo mokutil --import /etc/pki/akmods/certs/signing_key.x509"
    echo ""
    echo "2. Reboot your system"
    echo "3. During boot, you should see a blue MOK management screen"
    echo "4. Follow the prompts to enroll the key"
    echo "5. Reboot again to complete the process"
    echo ""
    echo "If you don't see the MOK management screen:"
    echo "- Try pressing a key during boot when you see 'Press any key to continue'"
    echo "- Check your BIOS/UEFI settings for 'MOK Management' or 'Key Management'"
    echo "- Some systems may require disabling 'Fast Boot' or 'Secure Boot' temporarily"
    echo ""
    
    # Ask if user wants to proceed with mokutil
    echo "Would you like to proceed with MOK enrollment now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Importing MOK key..."
        mokutil --import /etc/pki/akmods/certs/signing_key.x509
        echo ""
        echo "MOK key imported successfully!"
        echo "Please reboot your system to complete the enrollment process."
        echo "After reboot, follow the MOK management prompts."
    else
        echo "You can run the enrollment later with:"
        echo "sudo mokutil --import /etc/pki/akmods/certs/signing_key.x509"
    fi
else
    echo "=== MOK Enrollment Instructions ==="
    echo ""
    echo "mokutil is not available. You'll need to enroll the key manually:"
    echo ""
    echo "1. Copy the certificate to an accessible location:"
    echo "   sudo cp /etc/pki/akmods/certs/signing_key.x509 /boot/"
    echo ""
    echo "2. Reboot your system"
    echo "3. During boot, access MOK management"
    echo "4. Select 'Enroll key from disk'"
    echo "5. Navigate to /boot/signing_key.x509"
    echo "6. Follow the prompts to enroll the key"
    echo "7. Reboot again to complete the process"
    echo ""
fi

echo "=== Verification ==="
echo ""
echo "After enrollment, you can verify the modules are signed:"
echo "modinfo /lib/modules/\$(uname -r)/updates/tuxedo_nb05_keyboard.ko | grep signature"
echo ""
echo "The signature should show a valid signature instead of 'signature: (null)'"
echo ""

echo "Setup complete! Please reboot and enroll the MOK key as described above."
