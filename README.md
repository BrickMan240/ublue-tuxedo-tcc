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

These images include pre-built and signed Tuxedo kernel modules using Aurora's existing signing keys. Secure Boot is fully supported out of the box - no additional configuration required.

## Features

- ✅ Tuxedo Control Center pre-installed
- ✅ All Tuxedo kernel modules pre-built
- ✅ Automatic module loading at boot
- ✅ Support for all Tuxedo laptop models
- ✅ Secure Boot compatible (out of the box)

## Troubleshooting

If Tuxedo Control Center doesn't detect your hardware:
1. Check if modules are loaded: `lsmod | grep tuxedo`
2. Manually load modules: `sudo /usr/bin/load-tuxedo-modules`
3. Check system logs: `journalctl -u tuxedo-modules.service`

## Building from Source

See the [Justfile](Justfile) for build commands.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.
