# Printing Rates Release Notes

## What's New

### New Features

- Professional printing rate calculator
- Quotation generation system
- Modern Qt6-based interface
- Cross-platform support (Windows, Linux)

### Technical Features

- Built with Qt6 for modern UI
- Boost.Log integration for comprehensive logging
- CMake-based build system
- Automatic update system via eUpdater
- Cross-platform deployment scripts

## Installation

### Windows

Download and run the `PrintingRatesSetup-x64.exe` installer.

### Linux

#### AppImage (Universal)

1. Download the `.AppImage` file
2. Make it executable: `chmod +x Printing-Rates-*.AppImage`
3. Run: `./Printing-Rates-*.AppImage`

#### Debian/Ubuntu (.deb)

```bash
# Download the .deb file from the release
sudo dpkg -i printing-rates_*_amd64.deb
```

#### Fedora/RHEL (.rpm)

```bash
# Download the .rpm file from the release
sudo rpm -i printing-rates-*-1.x86_64.rpm
```

#### From Source

```bash
git clone https://github.com/Deadbush225/printing-rates.git
cd printing-rates
./build.sh
sudo ./install.sh
```

## System Requirements

### Minimum Requirements

- **OS**: Windows 10 (64-bit) / Linux (64-bit)
- **RAM**: 512 MB
- **Storage**: 100 MB available space
- **Display**: 1024x768 resolution

### Dependencies (Linux)

- Qt6 (Core, GUI, Widgets)
- Boost.Log libraries
- Standard C++ runtime

---

_For support and bug reports, please visit our [GitHub Issues](https://github.com/Deadbush225/printing-rates/issues) page._
