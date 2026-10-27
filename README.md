# Xalq qabulxonasi — Axborot kioski

A native **Flutter Windows** kiosk application for a People's Reception office
(*Xalq qabulxonasi*). Fully offline, touch-first, and trilingual (Uzbek /
Russian / English). Built entirely in Dart — no WebView, minimal dependencies.

## Screens

- **Bosh sahifa** — section grid (home)
- **Qabul tartibi** — reception steps + required documents
- **Ish vaqti va qabul jadvali** — working hours + leadership schedule
- **Bo'limlar va xodimlar** — departments, staff, rooms, phones
- **Xizmatlar** — services + how to apply
- **Ko'p beriladigan savollar** — FAQ accordion
- **AI Maslahatchi** — an offline advisor that answers from the built-in
  knowledge base (dark theme)
- **Bog'lanish** — address, phone, helpline, hours, location

## Project structure

```
lib/
  main.dart                  bootstrap: kiosk window + wakelock
  src/
    app.dart                 MaterialApp
    kiosk_root.dart          shell: state, clock, idle reset, layout
    kiosk_state.dart         observable navigation / language / chat state
    config.dart              organisation details (name, address, phones)
    l10n.dart                trilingual UI strings
    data.dart                sections, schedule, departments, services, FAQ …
    ai_responder.dart        offline knowledge-base answerer
    theme.dart               colours + light/dark palettes
    screen.dart              Screen enum
    widgets/                 background, header, section nav, footer, cards, exit
    screens/                 one file per section
assets/images/qabulxona_icon.jpg   logo
```

## Configuration

Edit `lib/src/config.dart` to change the organisation name, address, phone and
helpline. Section content (departments, schedule, FAQ …) lives in
`lib/src/data.dart`.

## Run & build

```bash
flutter run -d windows            # fullscreen kiosk
flutter build windows --release   # production build
```

Deploy the **entire** `build/windows/x64/runner/Release/` folder.

### Development / verification mode

Set `KIOSK_WINDOWED=1` to run in a normal resizable window instead of locked
fullscreen (handy for development and screenshots):

```bash
KIOSK_WINDOWED=1 flutter run -d windows
```

## Kiosk behaviour

- Fullscreen, taskbar-hidden, always-on, screen kept awake (`wakelock_plus`).
- Alt+F4 / window close is blocked (`window_manager` prevent-close).
- Exit only via the on-screen **door** button (bottom-right), which asks for
  the exit password (only its SHA-256 hash is in the code —
  `KioskConfig.exitPasswordSha256`).
- Holding the door button opens the staff **Sozlamalar** panel (no password).
- Auto-resets to the home screen (Uzbek) after `KioskConfig.idleSeconds` of
  inactivity.

For OS-level lockdown (Shell Launcher, auto-login, registry hardening) on a
dedicated kiosk PC, see Windows Shell Launcher v2 configuration.

## Yangilanish va Setup.exe (ADR-037)

Kiosk o'zi yangilanadi: ochilgandan 60 s keyin va har 3 soatda
`https://qabulxona.gennis.uz/downloads/kiosk/info_kiosk/version.json` ni
tekshiradi, yangi versiyani fonda yuklab SHA-256 ni tekshiradi va kiosk bo'sh
turganda (≥ 2 daqiqa teginish yo'q, bosh sahifa, dialog va ovozli suhbat yo'q)
15 s ogohlantirishdan keyin jim o'rnatadi. Kod: `lib/core/update/`
(`_kiosk_update_kit` dan nusxa — shu yerda tahrirlamang).

**Reliz yig'ish** (versiya `pubspec.yaml` dan olinadi — avval uni oshiring):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\release-windows.ps1 -Changelog "..."
```

Natija: `dist\InfoKiosk_Setup_vX.Y.Z.exe` (+ `dist\version.json` namunasi,
`dist\symbols\X.Y.Z` — saqlab qo'ying, serverga emas). Inno Setup kerak
(`%LOCALAPPDATA%\Programs\Inno Setup 6` yoki `winget install JRSoftware.InnoSetup`).

**Serverga yuklash:** admin panel → Sozlamalar → Kiosk yangilanishlari →
`info_kiosk` → **faqat `.exe`** ni yuklang (`version.json` ni server o'zi yozadi).

**Sozlamalar paneli (xodim):** pastki o'ngdagi «Chiqish» (eshik) tugmasini
**bosib turing** → «Sozlamalar» parolsiz ochiladi: versiyalar, holat,
«Hozir tekshirish», «Hozir o'rnatish», Log. Paneldagi «Chiqish» — odatdagi
parolli chiqish. Oddiy bosish — avvalgidek parol so'raydi.

**Birinchi o'rnatish:** kioskda `InfoKiosk_Setup_vX.Y.Z.exe` ni bir marta qo'lda
ishga tushiring — ilova doim `C:\Kiosk\InfoKiosk` ga o'rnatiladi (admin huquqi
shart emas). Keyingi versiyalar online keladi. Log:
`%LOCALAPPDATA%\InfoKiosk\update.log`.
