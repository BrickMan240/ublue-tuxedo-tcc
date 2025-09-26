#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install screen

#Exec perms for symlink script
chmod +x /usr/bin/fixtuxedo
chmod +x /usr/bin/load-tuxedo-modules
#And autorun
systemctl enable /etc/systemd/system/fixtuxedo.service
systemctl enable /etc/systemd/system/tuxedo-modules.service

# Install tuxedo drivers from official repository
rpm-ostree install tuxedo-drivers

# Prebuild kernel modules for this system
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

# Copy source to writable location and build modules
cp -r /usr/src/tuxedo-drivers-4.15.4 /tmp/tuxedo-drivers-build
cd /tmp/tuxedo-drivers-build

# Build all available modules
make -C /lib/modules/${KERNEL_VERSION}/build M=$(pwd) modules

# Install the built modules
make -C /lib/modules/${KERNEL_VERSION}/build M=$(pwd) modules_install

# Generate MOK (Machine Owner Key) for Secure Boot module signing
echo "Generating MOK keys for Secure Boot compatibility..."

# Create directory for MOK keys
mkdir -p /etc/pki/akmods/certs

# Generate private key
openssl req -new -x509 -newkey rsa:2048 -keyout /etc/pki/akmods/certs/signing_key.pem -out /etc/pki/akmods/certs/signing_key.x509 -outform DER -days 36500 -subj "/CN=Tuxedo Modules/" -nodes

# Convert to PEM format for the certificate
openssl x509 -inform DER -in /etc/pki/akmods/certs/signing_key.x509 -out /etc/pki/akmods/certs/signing_key.x509.pem

# Set proper permissions
chmod 600 /etc/pki/akmods/certs/signing_key.pem
chmod 644 /etc/pki/akmods/certs/signing_key.x509*

# Sign all built modules with the generated MOK
echo "Signing modules with generated MOK keys..."
for module in $(find /lib/modules/${KERNEL_VERSION}/updates -name "*.ko" 2>/dev/null); do
    /usr/src/kernels/${KERNEL_VERSION}/scripts/sign-file sha256 /etc/pki/akmods/certs/signing_key.pem /etc/pki/akmods/certs/signing_key.x509.pem "$module" 2>/dev/null || true
done

echo "Modules signed with MOK keys. Users will need to enroll the MOK key in Secure Boot."

# Clean up
cd /
rm -rf /tmp/tuxedo-drivers-build

#Hacky workaround to make TCC install elsewhere
mkdir -p /usr/share
rm /opt
ln -s /usr/share /opt

rpm-ostree install tuxedo-control-center

cd /
rm /opt
ln -s var/opt /opt
ls -al /

rm /usr/bin/tuxedo-control-center
ln -s /usr/share/tuxedo-control-center/tuxedo-control-center /usr/bin/tuxedo-control-center

sed -i 's|/opt|/usr/share|g' /etc/systemd/system/tccd.service
sed -i 's|/opt|/usr/share|g' /usr/share/applications/tuxedo-control-center.desktop

systemctl enable tccd.service

systemctl enable tccd-sleep.service

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File


systemctl enable podman.socket
