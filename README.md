# ublue-tuxedo-tcc

Universal Blue images with Tuxedo Control Center and drivers pre-installed for Tuxedo and Clevo laptops.

## Supported Images

- **Aurora**: `tuxedo-aurora`
- **Bluefin**: `tuxedo-bluefin` 
- **Bazzite**: `tuxedo-bazzite`

## Installation

Rebase to the desired image:

```bash
# Aurora
rpm-ostree rebase ostree-unverified-registry:ghcr.io/brickman240/tuxedo-aurora:latest

# Bluefin
rpm-ostree rebase ostree-unverified-registry:ghcr.io/brickman240/tuxedo-bluefin:latest

# Bazzite
rpm-ostree rebase ostree-unverified-registry:ghcr.io/brickman240/tuxedo-bazzite:latest
```

Then reboot:
```bash
systemctl reboot
```

## Secure Boot Compatibility

These images include pre-built and signed Tuxedo kernel modules using MOK (Machine Owner Key) signing. For Secure Boot compatibility, you need to enroll the MOK key:

1. After rebasing, run: `sudo /usr/bin/setup-secureboot`
2. The script will automatically import the MOK key using `mokutil`
3. Reboot and follow the MOK enrollment prompts during boot
4. Reboot again to complete the process

The setup script handles the entire process automatically.

## Features

- ✅ Tuxedo Control Center pre-installed
- ✅ All Tuxedo kernel modules pre-built
- ✅ Automatic module loading at boot
- ✅ Support for all Tuxedo laptop models
- ✅ Secure Boot compatible (with MOK enrollment)

## Troubleshooting

If Tuxedo Control Center doesn't detect your hardware:
1. Check if modules are loaded: `lsmod | grep tuxedo`
2. Manually load modules: `sudo /usr/bin/load-tuxedo-modules`
3. Check system logs: `journalctl -u tuxedo-modules.service`
4. If modules fail to load with "Operation not permitted", run: `sudo /usr/bin/setup-secureboot`
5. If mokutil is not available, manually copy the certificate to /boot/ and enroll via MOK screen

## Building from Source

See the [Justfile](Justfile) for build commands.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.
