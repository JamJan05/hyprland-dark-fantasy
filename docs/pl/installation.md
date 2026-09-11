# Instalacja

[← README](../../README.pl.md) · [English](../installation.md)

Pulpit instalują trzy skrypty. Każdy z nich **pokazuje plan i niczego nie zmienia**, dopóki nie dodasz `--apply`.

| Skrypt | Co robi | Root |
|---|---|---|
| [`install.sh`](../../install.sh) | Dowiązuje `config/` i resztę do `~/.config` i `~/.local` | nie |
| [`bootstrap.sh`](../../bootstrap.sh) | Instalacja Gentoo od zera: overlaye, pliki Portage, pakiety, klon, `install.sh --apply`, reguła udev | przez `sudo` |
| [`sddm/install-theme.sh`](../../sddm/install-theme.sh) | Instaluje motyw logowania SDDM i ustawia go jako domyślny | przez `sudo` |

## Wariant A: od zera przez `bootstrap.sh`

Najpierw sam plan:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh | bash
```

Potem wykonanie:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh | bash -s -- --apply
```

Próba na sucho jest domyślna celowo. Skrypt podany z `curl` wprost do powłoki nie powinien instalować kilkudziesięciu pakietów i przestawiać systemu, zanim zobaczysz, co zamierza zrobić.

Co robi `--apply`, po kolei:

1. Sprawdza, czy to Gentoo, czy są `emerge`, `git` i `sudo` i czy skrypt **nie** działa jako root. Rozpoznaje też OpenRC albo systemd.
2. Od razu na początku raz prosi o hasło `sudo`. Przy `curl | bash` czyta je z `/dev/tty`.
3. Włącza overlaye **GURU** i **hyproverlay** przez `eselect repository` i je synchronizuje.
4. Klonuje repozytorium do `~/hyprland-dark-fantasy`. Inną ścieżkę podasz w `HYPR_REPO_DIR`. Uruchomiony z wnętrza klonu używa tego klonu.
5. Kopiuje `gentoo/package.accept_keywords/hyprland-desktop` i `gentoo/package.use/hyprland-desktop` do `/etc/portage/`, jeśli ich tam jeszcze nie ma.
6. Instaluje pakiety przez `emerge --ask --verbose --changed-use`. Kompilacja Hyprlanda i zależności Qt trochę trwa.
7. Uruchamia `install.sh --apply`.
8. Wgrywa regułę udev dla baterii, ale tylko wtedy, gdy bateria ma progi ładowania.

Skrypt jest idempotentny: przy ponownym uruchomieniu pomija to, co już zrobione. `./bootstrap.sh --help` wypisuje to samo streszczenie.

Jeśli `sudo` nie może zapytać o hasło, bo nie ma terminala, pobierz skrypt na dysk i uruchom go bezpośrednio:

```sh
curl -fsSL https://raw.githubusercontent.com/JamJan05/hyprland-dark-fantasy/main/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh --apply
```

`bootstrap.sh` celowo **nie** instaluje programów użytkownika, czyli przeglądarek, komunikatorów czy gier. Uzbrojenie (Arsenal) pokazuje po prostu to, co jest zainstalowane.

## Wariant B: pakiety samodzielnie

Włącz overlaye:

```sh
sudo eselect repository enable guru
sudo eselect repository enable hyproverlay
sudo emaint sync -r guru -r hyproverlay
```

Skopiuj pliki Portage. Dodają keywordy dla pakietów `~amd64` i flagi USE, których ta konfiguracja potrzebuje:

```sh
sudo cp gentoo/package.accept_keywords/hyprland-desktop /etc/portage/package.accept_keywords/
sudo cp gentoo/package.use/hyprland-desktop             /etc/portage/package.use/
```

Zainstaluj tę samą listę, co tablica `PAKIETY` w `bootstrap.sh`:

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

Uwagi do listy:

- **Waybar** potrzebuje USE `backlight network wifi mpris tray pipewire pulseaudio upower`. Bez `wifi` moduł sieci nie pokaże SSID ani siły sygnału.
- **Quickshell** zostaje na domyślnych flagach USE. Jego obsługa awarii ciągnie `dev-cpp/cpptrace`, któremu potrzebne jest USE `unwind` (ustawione w `gentoo/package.use`).
- **Pakiety wyglądu**: `eb-garamond` to krój napisów, `adw-gtk3` motyw GTK, `papirus-icon-theme` ikony w GTK i w Uzbrojeniu, a `bibata-xcursors` kursor. `btop` obsługuje kafel Status. `pillow` przetwarza okładkę na pasku, ikony kafli i tekstury. `adw-gtk3` i `bibata-xcursors` pochodzą z GURU.
- **Bez któregoś pakietu** odpowiadający mu element wraca do domyślnego wyglądu albo pokazuje stan „niedostępne”; pulpit i tak wstaje.
- **SDDM** i **fish** nie są na liście. Motyw SDDM i `config/fish/config.fish` są opcjonalne.

Potem dowiąż konfigurację:

```sh
git clone https://github.com/JamJan05/Hyprland-Dark-Fantasy.git ~/hyprland-dark-fantasy
cd ~/hyprland-dark-fantasy
./install.sh
./install.sh --apply
```

## Co dowiązuje `install.sh`

Każdy wpis to **dowiązanie symboliczne** do repozytorium. Jeśli w miejscu docelowym leży zwykły plik, najpierw trafia on do `<plik>.bak-RRRRMMDD-GGMMSS`. Dowiązanie, które już wskazuje we właściwe miejsce, zostaje nietknięte.

| Obszar | Źródło w repo | Cel |
|---|---|---|
| Hyprland | `config/hypr/hyprland.lua`, `floors.lua`, `hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf` | `~/.config/hypr/` |
| Waybar | `config/waybar/config.jsonc`, `style.css` | `~/.config/waybar/` |
| SwayNC (nieaktywny, droga odwrotu) | `config/swaync/config.json`, `style.css` | `~/.config/swaync/` |
| fish | `config/fish/config.fish` | `~/.config/fish/config.fish` |
| rofi, kitty | `config/rofi/dark-fantasy.rasi`, `config/kitty/kitty.conf`, `panel.conf` | `~/.config/rofi/`, `~/.config/kitty/` |
| yazi, btop | `config/yazi/theme.toml`, `config/btop/btop.conf`, `themes/dark-fantasy.theme` | `~/.config/yazi/`, `~/.config/btop/` |
| GTK | `settings.ini` i `gtk.css` z `config/gtk-3.0/` i `config/gtk-4.0/` | `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/` |
| Portale | `config/xdg-desktop-portal/hyprland-portals.conf` | `~/.config/xdg-desktop-portal/` |
| Quickshell | cały katalog `config/quickshell/dark-fantasy/` | `~/.config/quickshell/dark-fantasy` |
| Skrypty | `local/bin/*` | `~/.local/bin/` |
| Demon powiadomień | `local/share/dbus-1/services/org.freedesktop.Notifications.service` | `~/.local/share/dbus-1/services/` |
| Ikony kafli | `assets/ikony-menu/256/` (generowane) | `~/.local/share/dark-fantasy/ikony-menu` |
| Domyślna tapeta | `assets/wallpaper.png` | `~/.local/share/dark-fantasy/wallpaper.png` |

`~/.local/share` oznacza `$XDG_DATA_HOME`, jeśli ta zmienna jest ustawiona.

Instalator robi jeszcze dwie rzeczy:

- **Ikony kafli.** Przy `--apply` uruchamia `tools/skaluj-ikony-menu.py` (potrzebny `python3` z Pillow), który robi kopie 256 px z oryginałów w `assets/ikony-menu/`. Jeśli brakuje oryginału, kafel pokazuje ciemny kwadrat z nazwą, a instalator wypisuje ostrzeżenie.
- **Katalog tapet.** Zębatka (Cogwheel) listuje obrazy z `<XDG Pictures>/Wallpapers` albo z istniejącego `<XDG Pictures>/Tapety`. Jeśli w tym katalogu nie ma obrazów, `--apply` kopiuje do niego `assets/wallpaper.png`, żeby lista nie była pusta na świeżej instalacji.

`kde-gtk-config`, moduł ustawień GTK z Plasmy, potrafi przy zmianie motywu w Plasmie podmienić dowiązanie `gtk.css` na zwykły plik. Ponowne `./install.sh --apply` odłoży ten plik do kopii i przywróci dowiązanie.

## Po instalacji

`install.sh --apply` kończy się listą ręcznych kroków:

1. **Pliki Portage**, jeśli nie skopiował ich już `bootstrap.sh` (patrz wariant B).
2. **Ekran logowania** (opcjonalnie): `cd sddm && ./install-theme.sh --apply`.
3. **Limit ładowania baterii bez pytania o hasło**, na laptopach z progami ładowania: patrz [reguła udev](#limit-ładowania-baterii-reguła-udev).
4. **Przeładowanie**: `hyprctl reload` albo uruchomienie Hyprlanda (z TTY: `Hyprland`).

`bootstrap.sh` dokłada jeszcze jeden: **Bluetooth**. Pasek pokazuje Bluetooth jako wyłączony, dopóki usługa nie działa.

```sh
sudo rc-service bluetooth start && sudo rc-update add bluetooth default   # OpenRC
sudo systemctl enable --now bluetooth                                     # systemd
```

Resztę, w tym tapetę, odstępy, animacje i układ klawiatury, ustawisz w Zębatce (`SUPER + U`). Patrz [cogwheel.md](cogwheel.md).

## Ekran logowania (SDDM)

W `sddm/dark-fantasy/` leży autorski motyw SDDM w tej samej palecie. Ma rozmytą tapetę z ziarnem, duży zegar, pole hasła dla ostatniego użytkownika (bez listy użytkowników), wybór sesji i motto na dole. Napisy są w EB Garamond, więc motyw instaluj po `media-fonts/eb-garamond`.

```sh
cd sddm
./install-theme.sh                                    # plan
./install-theme.sh --apply                            # instalacja i ustawienie jako domyślny
./install-theme.sh --apply --wallpaper /ścieżka/obraz.png --lang pl
```

| Opcja | Znaczenie |
|---|---|
| `--apply` | Naprawdę instaluje (używa `sudo`) |
| `--wallpaper PLIK` | Tapeta logowania. Domyślnie: `path` z `~/.config/hypr/hyprpaper.conf`, potem `assets/wallpaper.png` |
| `--lang en\|pl` | Język ekranu logowania. Domyślnie: język wybrany w Zębatce → Język, a bez niego `en` |
| `-h`, `--help` | Pomoc |

Podgląd bez wylogowywania:

```sh
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/dark-fantasy
```

Co warto wiedzieć:

- **SDDM to nie hyprlock.** hyprlock to ekran *blokady* w Twojej sesji (konfiguracja w hyprlangu). SDDM to ekran *logowania* przed sesją (QML / Qt 6). Wyglądają podobnie, ale nie dzielą kodu.
- **Tapeta jest kopiowana do katalogu motywu.** Greeter działa jako użytkownik `sddm` i nie widzi Twojego katalogu domowego; ścieżka w `~/` dałaby czarne tło bez żadnego komunikatu.
- **Plik konfiguracyjny nazywa się `zz-dark-fantasy.conf` celowo.** SDDM czyta `/etc/sddm.conf.d/*.conf` alfabetycznie, a **późniejszy plik nadpisuje wcześniejszy** (`src/common/ConfigReader.cpp`), odwrotnie niż w systemd. Przedrostek `zz-` sortuje się po `kde_settings.conf`, którym zarządza moduł SDDM w Plasmie i który ustawia `breeze`. Instalator usuwa też stary, nieskuteczny `10-dark-fantasy.conf` i na końcu sprawdza, który motyw faktycznie wygrywa.
- **Wartość z przecinkiem w `theme.conf` musi być w cudzysłowie.** SDDM czyta plik przez QSettings, które z wartości z przecinkiem bez cudzysłowu robi listę.
- **Na Gentoo z OpenRC usługa nazywa się `display-manager`, nie `sddm`.** Konfiguracja jest w `/etc/conf.d/display-manager`. Restart to `sudo rc-service display-manager restart`, który **zamyka bieżącą sesję graficzną**.

## Limit ładowania baterii (reguła udev)

Zębatka → System → Zasilanie potrafi zatrzymać ładowanie na wybranym poziomie. Jądro wystawia to jako `charge_control_end_threshold` i `charge_control_start_threshold`, a te pliki należą do roota. Bez reguły każda zmiana pyta o hasło administratora przez `pkexec`. Reguła daje grupie `wheel` prawo zapisu:

```sh
sudo mkdir -p /etc/udev/rules.d      # może nie istnieć: Gentoo trzyma reguły pakietów w /lib/udev/rules.d
sudo cp udev/99-dark-fantasy-bateria.rules /etc/udev/rules.d/
sudo udevadm trigger --subsystem-match=power_supply --action=change
```

`bootstrap.sh` wgrywa regułę sam, jeśli istnieje `/sys/class/power_supply/BAT*/charge_control_end_threshold`. Więcej o limicie ładowania w [cogwheel.md](cogwheel.md#profil-zasilania-i-limit-ładowania).

## Kopia zapasowa i przywracanie

### Repozytorium jest kopią

Po `install.sh --apply` pliki w `~/.config` są dowiązaniami do repozytorium. Nie ma dwóch kopii, jest jeden plik widziany z dwóch ścieżek. Czy edytujesz w repo, czy w `~/.config`, `git status` widzi zmianę, więc kopia to po prostu commit:

```sh
cd ~/hyprland-dark-fantasy
git add -A && git commit -m "opis zmiany" && git push
```

### Co nie jest dowiązane

Te pliki leżą w katalogach systemowych i wymagają roota. Jeśli je zmienisz, skopiuj je do repo samodzielnie.

| Plik | Instaluje go |
|---|---|
| `/etc/portage/package.accept_keywords/hyprland-desktop`, `/etc/portage/package.use/hyprland-desktop` | `bootstrap.sh` albo ręcznie |
| `/usr/share/sddm/themes/dark-fantasy/` | `sddm/install-theme.sh` |
| `/etc/udev/rules.d/99-dark-fantasy-bateria.rules` | `bootstrap.sh` albo ręcznie |

Część stanu celowo zostaje **poza** repozytorium, bo dotyczy jednego komputera, a nie konfiguracji pulpitu:

- `~/.config/hypr/ustawienia.lua`: ustawienia Hyprlanda z Zębatki (wpisane też do `.gitignore`),
- `~/.local/state/dark-fantasy/powloka.json`: ustawienia powłoki (język, paski HUD-u, limit ładowania).

**Wyjątkiem jest tapeta.** Wybór tapety w Zębatce przepisuje `path` w `hyprpaper.conf` i `$tapeta` w `hyprlock.conf`. Oba pliki są dowiązaniami do repo, więc zmiana pojawia się w `git status`. Commituj ją tylko wtedy, gdy ta ścieżka istnieje też na Twoich innych komputerach.

> [!WARNING]
> `sed -i` i edytory z „zapisem atomowym” podmieniają dowiązanie na zwykły plik. Zmiana wtedy działa, ale do repo nie trafia. Patrz [troubleshooting.md](troubleshooting.md#sed--i-zrywa-dowiązania).

### Przywracanie po reinstalacji systemu

Na świeżym Gentoo z siecią i `git`:

```sh
git clone https://github.com/JamJan05/Hyprland-Dark-Fantasy.git ~/hyprland-dark-fantasy
cd ~/hyprland-dark-fantasy
./bootstrap.sh              # plan
./bootstrap.sh --apply      # overlaye, pakiety, dowiązania, reguła udev
cd sddm && ./install-theme.sh --apply && cd ..            # opcjonalnie
sudo rc-service bluetooth start && sudo rc-update add bluetooth default
```

Po zalogowaniu do Hyprlanda wszystko wstaje z autostartu w `hyprland.lua`.

**Repozytorium nie odtworzy** haseł i kluczy, danych aplikacji (zakładki przeglądarki, sesje odtwarzaczy), ustawień z Zębatki ani pakietów spoza powyższej listy.
