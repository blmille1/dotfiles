# VNC client for Raspberry Pi

## Recommendation

Use TigerVNC Viewer on macOS. Raspberry Pi's current remote-access documentation explicitly recommends TigerVNC for connecting to the VNC server included with Raspberry Pi OS (`wayvnc`). The documentation gives macOS users the TigerVNC `.dmg` download and connection steps. This makes TigerVNC the best-supported first client to try instead of macOS Screen Sharing for this use case.

The Homebrew Cask `tigervnc` installs `TigerVNC.app` in `/Applications`; it is the same upstream viewer distributed as a macOS DMG. This repository now manages that cask in `darwin/configuration.nix`.

## Connect

1. Enable VNC on the Pi. Raspberry Pi OS includes `wayvnc`; enable VNC in the Pi's desktop settings or with `raspi-config`.
2. Ensure the Mac and Pi are on the same local network or connected through a VPN.
3. Open TigerVNC Viewer, enter the Pi's IP address in the VNC server field, and connect.
4. If prompted, accept the Pi's certificate exception, then authenticate with a valid Raspberry Pi account username and password.

For access from outside the local network, Raspberry Pi lists using VNC within a VPN or using Raspberry Pi Connect as options. Connect avoids manually finding the Pi's local IP address or changing the network firewall.

## Sources

- [Raspberry Pi documentation - Screen share with VNC](https://www.raspberrypi.com/documentation/computers/remote-access.html#vnc) - identifies `wayvnc` as the Raspberry Pi OS VNC server and recommends downloading and using TigerVNC, including its connection and authentication steps.
- [Homebrew Cask - TigerVNC](https://formulae.brew.sh/cask/tigervnc) - current cask name, install command (`brew install --cask tigervnc`), macOS requirement, and `TigerVNC.app` artifact.
- [TigerVNC releases](https://github.com/TigerVNC/tigervnc/releases) - upstream release announcements and links to the macOS binaries.
- [Raspberry Pi documentation - Raspberry Pi Connect](https://www.raspberrypi.com/documentation/services/connect.html) - official alternative for remote access without manually finding the Pi's local IP or changing network firewall settings.
