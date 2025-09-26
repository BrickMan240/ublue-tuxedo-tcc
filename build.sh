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

# Sign the modules for Secure Boot compatibility
for module in $(find /lib/modules/${KERNEL_VERSION}/updates -name "*.ko" 2>/dev/null); do
    /usr/src/kernels/${KERNEL_VERSION}/scripts/sign-file sha256 /usr/src/kernels/${KERNEL_VERSION}/certs/signing_key.pem /usr/src/kernels/${KERNEL_VERSION}/certs/signing_key.x509 "$module" 2>/dev/null || true
done

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
