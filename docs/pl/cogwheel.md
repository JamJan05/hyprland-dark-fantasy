# Zębatka (ustawienia)

[← README](../../README.pl.md) · [English](../cogwheel.md)

Cogwheel (Zębatka) to kafel ustawień w układzie opcji z gry: po lewej sekcje, po prawej rzędy „etykieta … wartość”. Suwaki to te same 6-pikselowe paski co w HUD-zie, a przełączniki to napisy `Wł. / Wył.` w kapitalikach. W angielskim interfejsie kafel nazywa się Cogwheel.

Otwiera ją `SUPER + U` albo kafel w rzędzie.

| Gdzie | Klawisze |
|---|---|
| Lista sekcji | `↑` `↓` wybór, `→` / `Enter` do opcji, `Esc` z powrotem do rzędu kafli |
| Opcje | `↑` `↓` rząd, `←` `→` zmiana wartości, `Enter` zatwierdzenie albo edycja, `Esc` powrót do listy |

Sieć i Bluetooth potrzebują list urządzeń, haseł i parowania, a to nie mieści się w rzędach „etykieta … wartość”. Zostały kartami obsługiwanymi myszą; klawiatura tylko je przewija.

## Sekcje

W nawiasach nazwy z angielskiego interfejsu.

### System

| Sekcja | Opcje |
|---|---|
| **Dźwięk** (Sound) | Urządzenie wyjściowe, głośność, wyciszenie, głośność mikrofonu, wyciszenie mikrofonu, głośność grających programów (z PipeWire) |
| **Ekran** (Display) | Jasność podświetlenia i nazwa urządzenia |
| **Zasilanie** (Power) | Profil zasilania, limit ładowania, próg wznowienia ładowania, stan baterii |
| **Zachowanie** (Behavior) | Nie wygaszaj ekranu (wstrzymuje wygaszanie, blokadę i uśpienie), paski HUD-u |
| **Sieć** (Network) | Przełącznik Wi-Fi, lista sieci, łączenie z hasłem (NetworkManager) |
| **Bluetooth** | Zasilanie, lista urządzeń, łączenie |
| **Język** (Language) | Angielski albo polski (patrz [Język](#język)) |

### Hyprland

| Sekcja | Opcje |
|---|---|
| **Wygląd** (Appearance) | Odstęp między oknami, odstęp od krawędzi, grubość ramki, rozmycie, siła rozmycia, krycie nieaktywnych okien, przygaszanie nieaktywnych, siła przygaszania |
| **Ruch** (Motion) | Animacje wł. / wył., tempo animacji 0,5× - 2× (jeden mnożnik dla wszystkich animacji) |
| **Tapeta** (Wallpaper) | Wybór pliku z katalogu tapet z podglądem, potem „Ustaw jako tapetę” |
| **Wejście** (Input) | Czułość touchpada (reguła tylko dla touchpada, nie dla myszy), naturalne przewijanie, układ klawiatury, gesty pięter (3 palce) |
| **Ekran** (Monitor) | Skala (tylko „czyste” skale dla bieżącej rozdzielczości), odświeżanie, położenie drugiego monitora |
| **Piętra** (Floors) | Liczba pięter (1-10) i nazwa każdego piętra |
| **Skróty** (Shortcuts) | Podgląd wszystkich skrótów z opisami, prosto z `hyprctl binds` |
| **Przywróć domyślne** (Restore defaults) | Usuwa plik ustawień i przeładowuje Hyprlanda. Pierwszy Enter pyta, drugi wykonuje. |

Dostępne układy klawiatury: `pl`, `us`, `gb`, `de`, `fr`, `es`, `it`, `cz`, `sk`, `ua`.

Skale są ograniczone do „czystych” wartości, bo rozdzielczość podzielona przez skalę musi dać liczbę całkowitą. Inaczej Hyprland po cichu wybiera inną skalę. Listę wylicza powłoka z `hyprctl monitors`.

## Profil zasilania i limit ładowania

**Profil zasilania.** `SUPER + B` przełącza profil power-profiles-daemon w kółko: oszczędny → zrównoważony → wydajność. Wydajność pojawia się tylko, gdy sprzęt ją zgłasza. Nowy profil potwierdza OSD. Ten sam wybór jest w System → Zasilanie.

**Limit ładowania.** Zatrzymuje ładowanie na wybranym poziomie, np. 75 %, i wznawia je dopiero 5 punktów niżej. Bateria laptopa trzymanego na kablu starzeje się wtedy wolniej.

- Zapis idzie do `charge_control_end_threshold` i `charge_control_start_threshold` w `/sys/class/power_supply/BAT0/`. Na ThinkPadach wystawia je sterownik `thinkpad_acpi`; inne laptopy z tym samym interfejsem jądra też zadziałają.
- **Bez tych plików rzędy limitu się nie pokazują.**
- Pliki należą do roota. Bez [reguły udev](installation.md#limit-ładowania-baterii-reguła-udev) każda zmiana pyta o hasło administratora (`pkexec`).
- Powłoka pamięta ostatni limit i przywraca go przy starcie sesji, ale tylko po cichu, czyli tylko z wgraną regułą udev. ThinkPad i tak pamięta progi w kontrolerze.
- Z terminala: `limit-ladowania` wypisuje `start koniec zapisywalny`, a `limit-ladowania 75` ustawia limit. Skrypt zna kolejność zapisu, której wymaga `thinkpad_acpi`.

## Tapeta

Sekcja Tapeta listuje pliki `.png`, `.jpg`/`.jpeg` i `.webp` z `<XDG Pictures>/Wallpapers`. Jeśli ten katalog nie istnieje, a istnieje `<XDG Pictures>/Tapety`, używa tego drugiego. Bez `xdg-user-dir` bierze `~/Pictures`.

Strzałki tylko wybierają kandydata i pokazują jego podgląd. Dopiero **Ustaw jako tapetę**:

1. przepisuje `path` w `~/.config/hypr/hyprpaper.conf` i `$tapeta` w `~/.config/hypr/hyprlock.conf`,
2. restartuje hyprpaper tej sesji.

Oba pliki są dowiązaniami do repozytorium, więc zmiana pojawia się w `git status`. Domyślna tapeta to `~/.local/share/dark-fantasy/wallpaper.png`, dowiązanie do `assets/wallpaper.png`. **Przywróć domyślne** nie rusza tapety.

## Jak zapisują się ustawienia

Zębatka **nigdy nie edytuje `hyprland.lua`**. Ten plik jest pisany ręcznie, z komentarzami. Zamiast tego Zębatka jest właścicielem jednego pliku, `~/.config/hypr/ustawienia.lua` (ścieżka idzie za `$XDG_CONFIG_HOME`):

1. **Każda zmiana trafia od razu do kompozytora** przez `hyprctl eval`, np. `hl.config({ general = { gaps_in = 12 } })`. `hyprctl keyword` przy konfiguracji w Lua nie działa.
2. **Po 600 ms ciszy** powłoka przepisuje cały plik, a nie przy każdym kroku suwaka.
3. **`hyprland.lua` wczytuje plik na samym końcu**, żeby jego wartości nadpisywały domyślne. Wczytanie idzie przez `dofile` w `pcall`: błąd w pliku kończy się powiadomieniem ze wskazówką „Przywróć domyślne”, a nie rozsypaniem całej konfiguracji.
4. **Przywróć domyślne** usuwa plik i uruchamia `hyprctl reload`.

Przykład (skrócony):

```lua
-- stan: {"opcje":{"general:gaps_in":12},"tempo":2,"pietra":4,"nazwy":["","Praca"],"gesty":true,...}
--
-- FILE MANAGED BY THE SHELL (Cogwheel -> Hyprland).
-- Manual edits will be overwritten by the next change in the Cogwheel.
-- "Restore defaults" deletes this file. It is loaded at the end of hyprland.lua.
-- The "stan" line above is the data this file is generated from.

hl.config({ general = { gaps_in = 12 } })
ustawAnimacje(2)
floors.ustaw({ pietra = 4, nazwy = { "", "Praca" }, gesty = true })
```

Pierwsza linia to dane, z których plik wygenerowano. Z niej Zębatka odczytuje to, czego nie poda `hyprctl getoption`: tempo animacji, czułość touchpada, piętra i skalę monitora. Pozostałe wartości czyta z `hyprctl getoption` przy każdym otwarciu.

Plik leży **poza repozytorium**. Opisuje ten komputer, a nie konfigurację pulpitu.

### Ustawienia powłoki

To, co należy do samej powłoki, trafia do `~/.local/state/dark-fantasy/powloka.json` (ścieżka idzie za `$XDG_STATE_HOME`):

| Klucz | Znaczenie |
|---|---|
| `hudBars` | Paski HUD-u wł. / wył. |
| `limitLadowania` | Ostatni limit ładowania (0 = nigdy nie ustawiony) |
| `jezyk` | Język interfejsu, `en` albo `pl` |

## Język

Domyślny jest angielski. **System → Język** przełącza na polski natychmiast, bez restartu. Nazwy języków są zawsze zapisane w swoim własnym języku, żeby opcja była rozpoznawalna niezależnie od tego, który jest aktywny.

Co idzie za językiem:

| Część | Jak |
|---|---|
| Powłoka (wszystkie panele, kafle, OSD, dymki) | `services/Tr.qml`: każde wiązanie `Tr.t("English", "Polski")` przelicza się samo |
| Opisy skrótów Hyprlanda, nazwa katalogu zrzutów | `T(en, pl)` w `hyprland.lua` czyta `powloka.json`; po zmianie powłoka uruchamia `hyprctl reload` |
| Waybar (data, odtwarzacz, dymek temperatury) | Skrypty pytają `local/bin/df-jezyk`; powłoka wysyła `SIGRTMIN+12`, żeby odświeżyły się od razu |
| hyprlock (pole hasła, motto) | Powłoka zapisuje `~/.local/state/dark-fantasy/hyprlock-jezyk.conf`, który `hyprlock.conf` dołącza |
| Ekran logowania SDDM | Ustawiany przy instalacji: `sddm/install-theme.sh --apply --lang pl`. Bez `--lang` bierze język z `powloka.json` |

Greeter SDDM działa jako użytkownik `sddm`, zanim ktokolwiek się zaloguje, więc nie może śledzić Zębatki na żywo. Po zmianie języka uruchom `install-theme.sh` ponownie.

Ze skryptu: `qs -c dark-fantasy ipc call jezyk ustaw pl`.
