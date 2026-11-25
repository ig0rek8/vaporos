# VaporOS — Ultra-Light Open-Source SteamOS Alternative on Arch Linux

**VaporOS** — открытая, максимально облегчённая игровая ОС на базе **Arch Linux**, реализующая два режима работы в стиле SteamOS без лишнего хлама:

- **🎮 Игровой режим (Gaming Mode)**: `gamescope` + Steam Big Picture (`-gamepadui -steamos3`) + MangoHud + Gamemode + автоматический перевод CPU в `performance`.
- **🖥 Неигровой режим (Desktop Mode)**: минималистичный **Hyprland** (Wayland) с панелью **Waybar**, лаунчером **Fuzzel**, терминалом **Foot** и кнопкой возврата в Игровой режим в один клик (`Super + G` или кнопка на панели).
- **🔄 Бесшовное переключение**: нативный перехватчик `/usr/bin/steamos-session-select` позволяет нажать «Перейти на рабочий стол» прямо внутри Steam Big Picture и мгновенно попасть в Hyprland без перезагрузки и тяжёлых дисплей-менеджеров (используется `greetd`, ~3 МБ ОЗУ).
- **⚡ Минимум потребления**: ядро `linux-zen`, открытые драйверы **AMD (RADV) + Intel (ANV)**, сжатый своп в ОЗУ (`zram` + `zstd`), `iwd` вместо тяжёлого `wpa_supplicant`, ограниченный `journald` (64 МБ), Btrfs с сжатием `zstd:3` и `systemd-boot`.

## Архитектура проекта

```text
vaporos/
├── Dockerfile                        # Контейнер Arch Linux для сборки ISO с любой ОС
├── scripts/
│   ├── build-iso.sh                  # Основной скрипт сборки mkarchiso (Linux/Docker)
│   ├── build-iso.ps1                 # Сборка ISO одной командой на Windows (Docker Desktop)
│   └── test-vm.ps1                   # Быстрый запуск собранного ISO в QEMU
└── archiso/
    ├── profiledef.sh                 # Профиль образа archiso (zstd squashfs, UEFI + BIOS)
    ├── packages.x86_64               # Минимальный список пакетов без хлама
    ├── pacman.conf                   # Репозитории core, extra, multilib
    ├── efiboot/ & syslinux/          # Загрузчики (выбор Gaming Mode или Desktop Mode)
    └── airootfs/
        ├── etc/
        │   ├── greetd/config.toml                    # Автологин (~3 МБ ОЗУ)
        │   ├── sysctl.d/99-vaporos-gaming.conf       # Игровые твики ядра и памяти
        │   ├── systemd/zram-generator.conf           # zram (zstd)
        │   ├── NetworkManager/conf.d/wifi_backend.conf
        │   └── skel/.config/{hypr,waybar,fuzzel,foot,mako,MangoHud}/
        └── usr/
            ├── bin/steamos-session-select            # Нативный хук Steam Big Picture
            └── local/bin/
                ├── vaporos-session-dispatcher        # Диспетчер Gaming ↔ Desktop
                ├── vaporos-gaming-session            # Запуск gamescope + Steam
                ├── vaporos-desktop-session           # Запуск Hyprland
                ├── vaporos-switch-session            # Переключатель режимов
                ├── vaporos-ctl                       # Центр управления VaporOS
                └── vaporos-install                   # Установщик на NVMe/SSD (Btrfs)
```

## Как собрать ISO

### В облаке через GitHub Actions (без установки Docker/Linux)
1. Загрузите этот репозиторий на GitHub.
2. Откройте вкладку **Actions** → **Build VaporOS ISO** → нажмите **Run workflow**.
3. Через ~5–10 минут скачайте готовый `vaporos-*.iso` прямо из раздела **Releases** (или **Artifacts**).

### На Windows (через Docker Desktop + WSL2)
```powershell
.\scripts\build-iso.ps1
```
Готовый образ появится в `out\vaporos-YYYY.MM.DD-x86_64.iso`.

### На Arch Linux (нативно)
```bash
sudo pacman -S --needed archiso
sudo REPO_DIR="$(pwd)" ./scripts/build-iso.sh
```

## Горячие клавиши в Desktop Mode (Hyprland)

| Клавиши | Действие |
|---|---|
| `Super + G` | Вернуться в **Gaming Mode** (Gamescope + Steam) |
| `Super + Space` / `Super + D` | Лаунчер приложений (`fuzzel`) |
| `Super + Enter` | Терминал (`foot`) |
| `Super + C` | Центр управления (`vaporos-ctl`) |
| `Super + E` | Файловый менеджер (`thunar`) |
| `Super + Q` | Закрыть окно |
| `Super + F` | На весь экран |
| `Print` | Скриншот области в буфер обмена |
| `Right Shift + F12` | Показать/скрыть оверлей MangoHud в играх |

## Установка на диск
Загрузитесь с флешки (Ventoy / Rufus / `dd`), перейдите в Desktop Mode (или выберите его в меню загрузки) и запустите:
```bash
sudo vaporos-install
```
Установщик разметит выбранный NVMe/SSD под UEFI + Btrfs (`zstd:3`, подтома `@` и `@home`) и установит `systemd-boot` с обоими режимами загрузки.
