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
#And autorun
systemctl enable /etc/systemd/system/fixtuxedo.service

#Build and install tuxedo drivers
rpm-ostree install rpm-build
rpm-ostree install rpmdevtools
rpm-ostree install kmodtool

export HOME=/tmp

cd /tmp

rpmdev-setuptree

git clone https://github.com/BrickMan240/tuxedo-drivers-kmod

cd tuxedo-drivers-kmod/
git checkout update-to-4.14.1
./build.sh
cd ..

# Extract the Version value from the spec file
export TD_VERSION=$(cat tuxedo-drivers-kmod/tuxedo-drivers-kmod-common.spec | grep -E '^Version:' | awk '{print $2}')


rpm-ostree install ~/rpmbuild/RPMS/x86_64/akmod-tuxedo-drivers-$TD_VERSION-1.fc42.x86_64.rpm ~/rpmbuild/RPMS/x86_64/tuxedo-drivers-kmod-$TD_VERSION-1.fc42.x86_64.rpm ~/rpmbuild/RPMS/x86_64/tuxedo-drivers-kmod-common-$TD_VERSION-1.fc42.x86_64.rpm ~/rpmbuild/RPMS/x86_64/kmod-tuxedo-drivers-$TD_VERSION-1.fc42.x86_64.rpm

KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "tuxedo-drivers-kmod"

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
