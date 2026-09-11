# Installation

[← README](../README.md) · [Polski](pl/installation.md)

Three scripts install this desktop. Each one **shows a plan and changes nothing** until you add `--apply`.

| Script | What it does | Needs root |
|---|---|---|
| [`install.sh`](../install.sh) | Symlinks `config/` and friends into `~/.config` and `~/.local` | no |
| [`bootstrap.sh`](../bootstrap.sh) | From-scratch Gentoo setup: overlays, Portage files, packages, clone, `install.sh --apply`, udev rule | through `sudo` |
| [`sddm/install-theme.sh`](../sddm/install-theme.sh) | Installs the SDDM login theme and makes it the default | through `sudo` |

## Option A: from scratch with `bootstrap.sh`

Show the plan first:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh | bash
```

Then run it for real:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh | bash -s -- --apply
```

The dry run is the default on purpose. A script piped from `curl` into a shell should not install dozens of packages and change the system before you have seen what it is going to do.

What `--apply` does, in order:

1. Checks that the system is Gentoo, that `emerge`, `git` and `sudo` exist, and that the script is **not** running as root. It also detects OpenRC or systemd.
2. Asks for the `sudo` password once, up front. With `curl | bash` it reads the password from `/dev/tty`.
3. Enables the **GURU** and **hyproverlay** overlays with `eselect repository` and syncs them.
4. Clones the repository into `~/hyprland-dark-fantasy`. Set `HYPR_REPO_DIR` to use a different path. If the script is run from inside a clone, it uses that clone.
5. Copies `gentoo/package.accept_keywords/hyprland-desktop` and `gentoo/package.use/hyprland-desktop` into `/etc/portage/`, unless they already exist.
6. Installs the packages with `emerge --ask --verbose --changed-use`. Compiling Hyprland and the Qt dependencies takes a while.
7. Runs `install.sh --apply`.
8. Installs the battery udev rule, but only if the battery exposes charge thresholds.

The script is idempotent: running it again skips whatever is already done. `./bootstrap.sh --help` prints the same summary.

If `sudo` cannot ask for a password because there is no terminal, download the script and run it directly:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh --apply
```

`bootstrap.sh` deliberately does **not** install user programs such as browsers, messengers or games. Arsenal simply shows whatever is installed.

## Option B: install the packages yourself

Enable the overlays:

```sh
sudo eselect repository enable guru
sudo eselect repository enable hyproverlay
sudo emaint sync -r guru -r hyproverlay
```

Copy the Portage files. They add keywords for the `~amd64` packages and the USE flags this setup needs:

```sh
sudo cp gentoo/package.accept_keywords/hyprland-desktop /etc/portage/package.accept_keywords/
sudo cp gentoo/package.use/hyprland-desktop             /etc/portage/package.use/
```

Install the same list as the `PAKIETY` array in `bootstrap.sh`:

```sh
sudo emerge --ask --verbose --changed-use \
  gui-wm/hyprland gui-apps/waybar gui-apps/swaync gui-apps/hyprlock \
  gui-apps/hypridle gui-apps/hyprpaper gui-apps/hyprshot gui-apps/wl-clipboard \
  app-misc/cliphist gui-apps/rofi-wayland sys-auth/hyprpolkitagent \
  gui-libs/xdg-desktop-portal-hyprland media-fonts/nerdfonts media-sound/playerctl \
  media-video/pipewire media-video/wireplumber gui-apps/grim gui-apps/slurp \
  app-misc/jq x11-terms/kitty app-misc/brightnessctl media-sound/cava \
  sys-power/power-profiles-daemon net-wireless/bluez app-misc/yazi app-misc/tty-clock \
  media-fonts/eb-garamond x11-themes/adw-gtk3 x11-themes/papirus-icon-theme \
  x11-themes/bibata-xcursors sys-process/btop dev-python/pillow gui-apps/quickshell
```

Notes on the list:

- **Waybar** needs USE `backlight network wifi mpris tray pipewire pulseaudio upower`. Without `wifi` the network module shows no SSID or signal strength.
- **Quickshell** stays on its default USE flags. Its crash handler pulls in `dev-cpp/cpptrace`, which needs USE `unwind` (set in `gentoo/package.use`).
- **Theme packages**: `eb-garamond` provides the lettering font, `adw-gtk3` the GTK theme, `papirus-icon-theme` the icons in GTK and in Arsenal, and `bibata-xcursors` the cursor. `btop` backs the Status tile. `pillow` processes the cover art on the bar, the tile icons and the textures. `adw-gtk3` and `bibata-xcursors` come from GURU.
- **Without a package**, the matching element falls back to a default look or shows an "unavailable" state; the desktop still starts.
- **SDDM** and **fish** are not on the list. The SDDM theme and `config/fish/config.fish` are optional.

Then link the configuration:

```sh
git clone https://github.com/JamJan05/Hyprland-Dark-Fantasy.git ~/hyprland-dark-fantasy
cd ~/hyprland-dark-fantasy
./install.sh
./install.sh --apply
```

## What `install.sh` links

Every entry is a **symbolic link** into the repository. If a real file already exists at the target, it is moved to `<file>.bak-YYYYMMDD-HHMMSS` first, and a link that already points to the right place is left alone.

| Area | Source in the repo | Target |
|---|---|---|
| Hyprland | `config/hypr/hyprland.lua`, `floors.lua`, `hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf` | `~/.config/hypr/` |
| Waybar | `config/waybar/config.jsonc`, `style.css` | `~/.config/waybar/` |
| SwayNC (inactive fallback) | `config/swaync/config.json`, `style.css` | `~/.config/swaync/` |
| fish | `config/fish/config.fish` | `~/.config/fish/config.fish` |
| rofi, kitty | `config/rofi/dark-fantasy.rasi`, `config/kitty/kitty.conf`, `panel.conf` | `~/.config/rofi/`, `~/.config/kitty/` |
| yazi, btop | `config/yazi/theme.toml`, `config/btop/btop.conf`, `themes/dark-fantasy.theme` | `~/.config/yazi/`, `~/.config/btop/` |
| GTK | `config/gtk-3.0/` and `config/gtk-4.0/` `settings.ini`, `gtk.css` | `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` |
| Portals | `config/xdg-desktop-portal/hyprland-portals.conf` | `~/.config/xdg-desktop-portal/` |
| Quickshell | the whole `config/quickshell/dark-fantasy/` directory | `~/.config/quickshell/dark-fantasy` |
| Helper scripts | `local/bin/*` | `~/.local/bin/` |
| Notification daemon | `local/share/dbus-1/services/org.freedesktop.Notifications.service` | `~/.local/share/dbus-1/services/` |
| Tile icons | `assets/ikony-menu/256/` (generated) | `~/.local/share/dark-fantasy/ikony-menu` |
| Default wallpaper | `assets/wallpaper.png` | `~/.local/share/dark-fantasy/wallpaper.png` |

`~/.local/share` above means `$XDG_DATA_HOME` when that variable is set.

It also does two more things:

- **Tile icons.** With `--apply` it runs `tools/skaluj-ikony-menu.py`, which needs `python3` with Pillow, to make 256 px copies of the originals in `assets/ikony-menu/`. If an original is missing, that tile shows a dark square with its name, and the installer prints a warning.
- **Wallpaper folder.** Cogwheel lists images from `<XDG Pictures>/Wallpapers`, or from an existing `<XDG Pictures>/Tapety`. If that folder has no images, `--apply` copies `assets/wallpaper.png` into it, so the list is not empty on a fresh install.

`kde-gtk-config`, the Plasma GTK settings module, can replace the `gtk.css` link with a regular file when you change the theme in Plasma. Run `./install.sh --apply` again to move that file to a backup and restore the link.

## After installation

`install.sh --apply` finishes by printing these manual steps:

1. **Portage files**, unless `bootstrap.sh` already copied them (see Option B).
2. **Login screen** (optional): `cd sddm && ./install-theme.sh --apply`.
3. **Battery charge limit without a password prompt**, on laptops with charge thresholds: see [the udev rule](#battery-charge-limit-udev-rule).
4. **Reload**: `hyprctl reload`, or start Hyprland (from a TTY: `Hyprland`).

`bootstrap.sh` adds one more: **Bluetooth**. The bar shows Bluetooth as off until the service runs.

```sh
sudo rc-service bluetooth start && sudo rc-update add bluetooth default   # OpenRC
sudo systemctl enable --now bluetooth                                     # systemd
```

Everything else, including the wallpaper, gaps, animations and keyboard layout, is set in the Cogwheel (`SUPER + U`). See [cogwheel.md](cogwheel.md).

## Login screen (SDDM)

`sddm/dark-fantasy/` holds an original SDDM theme in the same palette. It has a blurred wallpaper with grain, a large clock, a password field for the last user (no user list), a session picker and a motto at the bottom. Its labels use EB Garamond, so install `media-fonts/eb-garamond` before the theme.

```sh
cd sddm
./install-theme.sh                                    # show the plan
./install-theme.sh --apply                            # install and set as default
./install-theme.sh --apply --wallpaper /path/to/image.png --lang pl
```

| Option | Meaning |
|---|---|
| `--apply` | Really install (uses `sudo`) |
| `--wallpaper FILE` | Login wallpaper. Default: the `path` from `~/.config/hypr/hyprpaper.conf`, then `assets/wallpaper.png` |
| `--lang en\|pl` | Login screen language. Default: the language chosen in Cogwheel → Language, otherwise `en` |
| `-h`, `--help` | Show help |

Preview the theme without logging out:

```sh
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/dark-fantasy
```

Things worth knowing:

- **SDDM is not hyprlock.** hyprlock is the *lock* screen inside your session (hyprlang config). SDDM is the *login* screen before the session (QML / Qt 6). They look alike but share no code.
- **The wallpaper is copied into the theme directory.** The greeter runs as the `sddm` user and cannot read your home directory; a path in `~/` would give a black background without any error.
- **The config file is named `zz-dark-fantasy.conf` on purpose.** SDDM reads `/etc/sddm.conf.d/*.conf` alphabetically, and a **later file overrides an earlier one** (`src/common/ConfigReader.cpp`). This is the opposite of systemd. The `zz-` prefix sorts after `kde_settings.conf`, which Plasma's SDDM module manages and which sets `breeze`. The installer also removes an older, ineffective `10-dark-fantasy.conf`, and checks at the end which theme actually wins.
- **A value with a comma in `theme.conf` must be quoted.** SDDM reads the file through QSettings, which turns an unquoted comma into a list.
- **On Gentoo with OpenRC the service is `display-manager`, not `sddm`.** Its configuration is in `/etc/conf.d/display-manager`. Restart it with `sudo rc-service display-manager restart`, which **closes the current graphical session**.

## Battery charge limit (udev rule)

Cogwheel → System → Power can stop charging at a chosen level. The kernel exposes this as `charge_control_end_threshold` and `charge_control_start_threshold`, and those files belong to root. Without the rule, every change asks for the administrator password through `pkexec`. The rule gives the `wheel` group write access:

```sh
sudo mkdir -p /etc/udev/rules.d      # may not exist: Gentoo keeps package rules in /lib/udev/rules.d
sudo cp udev/99-dark-fantasy-bateria.rules /etc/udev/rules.d/
sudo udevadm trigger --subsystem-match=power_supply --action=change
```

`bootstrap.sh` installs the rule automatically when `/sys/class/power_supply/BAT*/charge_control_end_threshold` exists. For more on the charge limit, see [cogwheel.md](cogwheel.md#power-profile-and-charge-limit).

## Backup and restore

### The repository is the backup

After `install.sh --apply` the files in `~/.config` are symlinks into the repository. There are no two copies, just one file with two paths. Whether you edit in the repo or in `~/.config`, `git status` sees the change, so a backup is just a commit:

```sh
cd ~/hyprland-dark-fantasy
git add -A && git commit -m "describe the change" && git push
```

### What is not linked

These live in system directories and need root. If you change them, copy them back into the repo yourself.

| File | Installed by |
|---|---|
| `/etc/portage/package.accept_keywords/hyprland-desktop`, `/etc/portage/package.use/hyprland-desktop` | `bootstrap.sh` or by hand |
| `/usr/share/sddm/themes/dark-fantasy/` | `sddm/install-theme.sh` |
| `/etc/udev/rules.d/99-dark-fantasy-bateria.rules` | `bootstrap.sh` or by hand |

Some state is deliberately **outside** the repository, because it belongs to one computer and is not part of the desktop configuration:

- `~/.config/hypr/ustawienia.lua`: Hyprland settings from the Cogwheel (also listed in `.gitignore`),
- `~/.local/state/dark-fantasy/powloka.json`: shell settings (language, HUD bars, charge limit).

**Wallpaper changes are the exception.** Choosing a wallpaper in the Cogwheel rewrites `path` in `hyprpaper.conf` and `$tapeta` in `hyprlock.conf`. Both are symlinks into the repo, so the change shows up in `git status`. Commit it only if the image path also exists on your other machines.

> [!WARNING]
> `sed -i` and editors that save "atomically" replace the symlink with a regular file. The change then works but never reaches the repo. See [troubleshooting.md](troubleshooting.md#sed--i-breaks-the-symlinks).

### Restoring after a system reinstall

On a fresh Gentoo with network access and `git`:

```sh
git clone https://github.com/JamJan05/Hyprland-Dark-Fantasy.git ~/hyprland-dark-fantasy
cd ~/hyprland-dark-fantasy
./bootstrap.sh              # plan
./bootstrap.sh --apply      # overlays, packages, links, udev rule
cd sddm && ./install-theme.sh --apply && cd ..            # optional
sudo rc-service bluetooth start && sudo rc-update add bluetooth default
```

After you log in to Hyprland, everything starts from the autostart in `hyprland.lua`.

**The repository cannot restore** passwords and keys, application data (browser bookmarks, player sessions), Cogwheel settings, or packages outside the list above.
