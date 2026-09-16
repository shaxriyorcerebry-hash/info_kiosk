# CLAUDE.md — Axborot kioski (`info_kiosk`)

> Bu fayl **Claude Code** tomonidan avtomatik o'qiladi.
> Sen — **🟧 Mobile dasturchining yordamchisisan** (Flutter, Windows desktop kiosk).
>
> ⚙️ Bu fayl skript bilan yaratiladi — **qo'lda tahrirlamang**, shablonni o'zgartiring:
> `../Projects-FinTech/scripts/templates/mobile-info_kiosk.md`
> va skriptni qayta ishga tushiring: `..\Projects-FinTech\scripts\setup-mobile-info-kiosk.ps1`

---

## 📁 Bu nima?

| | |
|--|--|
| **Ilova** | `info_kiosk` — Xalq qabulxonasi zalidagi **axborot** beruvchi teginish ekranli kiosk |
| **Vazifasi** | Qabul tartibi, jadval (shaxsiy + sayyor qabul), tashkilot va masalalar, FAQ, AI maslahatchi (matn + ovoz), bog'lanish — uz · ru · en |
| **Platforma** | **Faqat Windows** (fullscreen kiosk, sensor ekran). `android/ ios/ linux/ macos/ web/` — Flutter standart papkalari, ishlatilmaydi |
| **Mening rolim** | 🟧 Mobile |
| **Vault loyihasi** | `qabulhona` |
| **Hujjatlar (docs vault)** | `../Projects-FinTech/` (alohida git repo) |
| **Backend** | `https://qabulxona.gennis.uz/api` |

> Quyida qisqartma: **`…/qabulhona/`** = `../Projects-FinTech/01_Projects/qabulhona/`
>
> ⚠️ Repodagi `README.md` **eskirgan** («fully offline, no WebView» deydi — aslida backend + WebView2).
> Unga emas, quyidagi hujjatlarga va koddagi haqiqatga ishon.

---

## 🎯 Session boshlanganda DARHOL qil

### 1. Docs vault'ni yangila
```bash
git -C ../Projects-FinTech pull
```

### 2. Asosiy hujjatlarni o'qib chiq

| # | Fayl | Nima uchun |
|---|------|------------|
| 1 | `../Projects-FinTech/CLAUDE.md` | Vault umumiy qoidalari (nom konvensiyasi, savollar tanlov shaklida) |
| 2 | `…/qabulhona/09 - Mobile (App)/Info Kiosk/00 - Info Kiosk ro'yxati.md` | **⭐ Shu ilova hujjatlari** (index) |
| 3 | `…/qabulhona/09 - Mobile (App)/Info Kiosk/10 - Backend ulanishi bajarildi + qurilma tuzatishlari (2026-07).md` | **⭐ Joriy arxitektura**: 8 kontent API, kesh, sensor, AI, TLS, vositalar |
| 4 | `…/qabulhona/09 - Mobile (App)/Info Kiosk/11 - Joriy kod holati (2026-08-03).md` | Kod auditi. `01`, `02`, `05`–`07` dagi «offline / API yo'q» jumlalari **tarixiy** |
| 4b | `…/qabulhona/09 - Mobile (App)/Info Kiosk/12 - Hokim qabul vaqti, vertikal ekran, v1.6.0 (2026-09-16).md` | v1.6.0: hokim sanasi, qo'lda yangilash, vertikal ekran, sayyor tartibi, 5 bug |
| 4c | `…/qabulhona/09 - Mobile (App)/Info Kiosk/13 - Joriy kod holati v1.6.1 (2026-09-16).md` | **⭐ Joriy release** v1.6.1: bosh sahifa header ostidan, paket |
| 5 | `…/qabulhona/01 - Vazifalar (Todo)/03 - Mobile.md` | **⭐ Mening vazifalarim** — fayl katta (1300+ qator): `info_kiosk` / `Info Kiosk` bo'yicha qidiring |
| 6 | `…/qabulhona/02 - API/25 - Info Kiosk — Backend so'rovi (seed, reception-schedule, 3 maydon, RAG).md` | API contract (Backend yozadi, men o'qiyman) |
| 7 | `…/qabulhona/05 - Buglar (Bugs)/BUG-001 - Info Kiosk qurilmasida TLS sertifikat xatosi.md` | Qurilmadagi TLS muammosi va yechimi |
| 8 | `…/qabulhona/00 - Loyiha haqida (Project).md` | Butun platforma (kerak bo'lganda) |

### 3. Foydalanuvchiga ko'rsat
```
Mobile.md dagi info_kiosk vazifalari:
1. [ ] ...
2. [ ] ...

Qaysi vazifa ustida ishlaymiz?
```
Ochiq vazifa topilmasa — shuni ayt va nima qilishni **tanlov shaklida** so'ra.

---

## 🔧 Texnik — REAL stack

> ⚠️ Umumiy mobile shablondagi **Riverpod / Dio / go_router / Freezed / Hive / FCM bu loyihada YO'Q.**
> Ularni qo'shma va ularga mo'ljallangan skill'larni (`Ekran yaratish`, `Riverpod provider`, `Pro Mobile`) bu yerda ishlatma.

| Qatlam | Nima ishlatiladi |
|--------|------------------|
| Flutter / Dart | Dart SDK `^3.12.2`, lint: `flutter_lints` |
| State | `ChangeNotifier`: `KioskState` (til, ekran, chat, ovoz) + `ContentStore` (kontent) |
| HTTP | `dart:io` `HttpClient` — faqat `KioskTls.client()` (`services/tls.dart`) orqali; tarmoq paketi yo'q |
| Kontent | `KioskContentApi` — 8 bo'lim (`/kiosk/info/*`), `?lang=all`, `If-None-Match` → `304`, konvert `{data:…}` va top-level shakl; + `fetchReceptionPoints()` (hokim sanasi) |
| Kesh | `%LOCALAPPDATA%\info_kiosk\content\` — har bo'lim JSON + `reception-points.json` + `log.txt`; fonda har **5** daqiqada yangilanadi, logotipni 3 s bosish — darhol |
| Routing | Yo'q — `KioskRoot` + `Screen` enum (`home, qabul, jadval, masalalar, faq, ai, contact`) |
| AI | `AiApi` (`/avatar/ask`, `/avatar/converse`, `/avatar/voice-token`) + `AiResponder` (lokal FAQ/xizmatlar) |
| Ovoz | Gemini Live — `webview_windows` (WebView2) + `assets/web/genai.min.js` (`VoiceSession`); oflayn — Windows SAPI (`SpeechService`, yashirin PowerShell) |
| Lokalizatsiya | O'zimizniki: `Lang` enum + `Tr` (`l10n.dart`) — `intl`/ARB emas |
| Konfiguratsiya | `lib/src/config.dart` — `const` (build vaqtida); `idle_seconds` va idora ma'lumotlari backend `config` bo'limidan ustun keladi |
| Platforma paketlari | `window_manager`, `wakelock_plus`, `webview_windows` |
| Assetlar | logo · `office_map.png` (oflayn xarita) · `web/genai.min.js` · `certs/roots.pem` |
| Test | `test/` — 10 fayl, 82 test (kontent, backend-only, AI, exit paroli, idle/ovoz, state, sensor, widget, hokim sanasi + vertikal ekran + qo'lda yangilash, sayyor oynasi) |

### Papka tuzilmasi (`lib/`)
```
lib/
├── main.dart                         # fullscreen, preventClose, wakelock, KIOSK_WINDOWED
└── src/
    ├── app.dart                      # KioskApp (MaterialApp, kursor: KioskConfig.hideCursor)
    ├── kiosk_root.dart               # shell: soat, idle-timer, layout, Screen → ekran
    ├── kiosk_state.dart              # KioskState: lang, screen, chat, voice
    ├── kiosk_scroll_behavior.dart    # ⚠️ sensor: mouse-drag scroll + doimiy scrollbar
    ├── windows_shell.dart            # chiqishda oddiy Windows desktop'ni qaytarish
    ├── config.dart                   # KioskConfig: idora, xarita, idle, exitPassword, backendOrigin, aiVoice
    ├── content_models.dart           # payload → ekran tiplari (icon kalitlari, sana, uz fallback)
    ├── screen.dart                   # Screen enum
    ├── l10n.dart · theme.dart
    ├── ai_responder.dart             # lokal FAQ/xizmatlar bo'yicha token-overlap javob
    ├── data.dart · masalalar_data.dart · sayyor_data.dart   # ⚠️ faqat SEED manbasi (runtime'da emas)
    ├── services/
    │   ├── kiosk_content_api.dart    # 8 bo'lim + reception-points HTTP klient
    │   ├── content_store.dart        # kesh + fon yangilash (5 daq., Future<bool>) + log.txt + officialsShown
    │   ├── hokim_reception.dart      # HokimReception — hokim panelda belgilagan sana (UTC+5)
    │   ├── ai_api.dart               # /avatar/ask · converse · voice-token
    │   ├── voice_session.dart        # Gemini Live (WebView2, kiosk-voice.local)
    │   ├── speech_service.dart       # Windows SAPI ko'prigi
    │   └── tls.dart                  # KioskTls — ichki ildiz sertifikatlari (BUG-001)
    ├── screens/                      # home, qabul, jadval, masalalar, faq, ai, contact
    └── widgets/                      # header_bar (logo 3 s → yangilash), section_nav, footer_bar, empty_content,
                                      # glass_panel, info_card, kiosk_background, pressable, exit_button,
                                      # exit_password_dialog, staff_refresh (runStaffRefresh + xabar)
```

### Tipik buyruqlar (PowerShell)
```powershell
flutter pub get
flutter analyze
flutter test
$env:KIOSK_WINDOWED = "1"; flutter run -d windows   # oynali rejim (dev, skrinshot)
Remove-Item Env:KIOSK_WINDOWED                      # oynali rejimni o'chirish
flutter run -d windows                              # haqiqiy kiosk rejimi (Alt+F4 bloklangan!)
flutter build windows --release                     # → build\windows\x64\runner\Release\
```

**Jonli tekshiruv vositalari (`tool/`)** — tarmoq kerak:

| Buyruq | Nima qiladi |
|--------|-------------|
| `flutter test tool/content_probe.dart` | Jonli backend'ni ilova ko'zi bilan tekshiradi (8 bo'lim + hokim sanasi) |
| `flutter test tool/tls_probe.dart` | Tizim do'konisiz ham ichki sertifikatlar yetarlimi |
| `flutter test tool/ai_answer_probe.dart` | AI real savollarga javob beradimi |
| `flutter test tool/export_seed.dart` | Ilovadagi kontentni backend seed JSON + markdown qilib chiqaradi |
| `tool/kiosk_diagnostika.ps1` | **Qurilmada**: soat, DNS, 443, proxy, API, log, kesh → xulosa (paket ichida ketadi) |

> Kiosk rejimidan chiqish — pastdagi tugma → parol (`KioskConfig.exitPassword`).
> Kioskda konsol yo'q — xato matni: `%LOCALAPPDATA%\info_kiosk\content\log.txt`.
> Ma'lumotni darhol yangilash — tepadagi **logotipni 3 soniya** bosib turish (natija pastda xabar bilan).
>
> Dev mashinada `flutter` PATH da bo'lmasligi mumkin: `$env:Path = "C:\src\flutter\bin;$env:Path"`.
> `flutter build windows` plaginlar uchun **Developer Mode** talab qiladi. `flutter pub get` yangi SDK'da
> `analysis_options.yaml` ga `analyzer: exclude:` qo'shadi va plugin registrant fayllarini qayta yozadi — bu kutilgan.
> `KioskRoot` ni testda ko'tarma — `initSpeech()` haqiqiy PowerShell ochadi; ekranlarni alohida chiz.

### Release
1. `pubspec.yaml` versiyasini oshir (`version:` qatori) va `tool/OQING.txt` dagi versiyani yangila
2. `flutter analyze` + `flutter test` — ikkalasi toza bo'lsin; tarmoq bo'lsa `tool/content_probe.dart` ham
3. `flutter build windows --release`
4. `build\windows\x64\runner\Release\` ichini (+ `tool/OQING.txt` → `O'QING.txt`, `kiosk_diagnostika.ps1`)
   `XalqQabulxonasi_Kiosk\` papkasi ichida zip qil →
   `dist/XalqQabulxonasi_Kiosk_v<versiya>_win-x64.zip` (eski zip'larga **tegma** — har versiya alohida fayl; v1.6.0 = 31 fayl)
5. `dist/`, `build/`, `.dart_tool/`, `windows/flutter/ephemeral/` — `.gitignore` da (GitHub 100 MB limit).
   Tafsilot: `GITHUBGA_TUSHMAGAN_FAYLLAR.md`, `QAYTA_TIKLASH.md`

---

## 🧱 Loyiha invariantlari (buzma)

1. **Backend — yagona haqiqat manbai.** Ekrandagi har bir kontent so'zi `/kiosk/info/*` dan keladi.
   Bo'lim bo'sh (`data: null`) → «Ma'lumot kiritilmagan». `data.dart` / `masalalar_data.dart` /
   `sayyor_data.dart` runtime'da **ishlatilmaydi** — `backend_only_test.dart` shuni qo'riqlaydi.
   (`shaxiy_qabul_kiosk` da teskarisi — u yerdagi ilova ichidagi fallback bu yerga **ko'chirilmaydi**.)
2. **Tarmoq uzilishi ≠ bo'sh bo'lim.** Uzilishda oxirgi kesh ko'rinadi; kesh ham bo'lmasa —
   «Server bilan bog'lanib bo'lmadi» (texnik xodimga), «Ma'lumot kiritilmagan» (muharrirga) bilan aralashmasin.
3. **Bitta buzuq bo'lim** qolgan 7 tasini yiqitmaydi; buzuq yozuv tashlanadi, tarjima yo'q bo'lsa `uz` ga tushadi.
4. **8 bo'lim:** `sections, config, reception, reception-schedule, faq, topics, mobile-schedule, services`.
   Hammasi `/kiosk/info/<bo'lim>?lang=all` — til almashtirish tarmoqqa chiqmaydi. `reception-schedule` ham
   `/kiosk/info/` ostida (2026-09-16 dan; `shaxiy_qabul_kiosk` bilan bir manzil). Eski `/kiosk/reception-schedule`
   aliasi `ETag` bermaydi va 2026-07-28 da `404` edi — unga qaytma.
   Har bir yangilashda (5 daq.) **`GET /kiosk/reception-points`** ham so'raladi (bitta so'rov bo'lib birlashadi).
5. **Har HTTP so'rov `KioskTls.client()` orqali** — ichki `roots.pem` tizim do'koni ustiga qo'shiladi
   (BUG-001). Yangi `HttpClient()` ni to'g'ridan-to'g'ri yaratma.
6. **Sensor ekran:** hover'ga bog'liq UI yo'q (feedback bosilganda); `KioskScrollBehavior` da
   `dragDevices` ga **mouse** kiradi (IR ramka Windows'ga mouse bo'lib ko'rinadi — busiz uzun ro'yxat scroll bo'lmaydi);
   kursor faqat release'da yashirin (`hideCursor = kReleaseMode`); touch maydoni ≥ 56 px.
7. **AI javob tartibi:** lokal FAQ/xizmatlar → `/avatar/ask` (faqat `grounded: true`) →
   `/avatar/converse` (oxirgi 10 xabar bilan) → «javob topolmadim». `converse` ni olib tashlama.
   Ovoz nomi haqiqiy bo'lsin (`aiVoice = 'Aoede'`) — backend default `auto` ni Gemini rad etadi.
8. **Idle:** vaqt backend `config.idle_seconds` dan (15–600), bo'lmasa `KioskConfig.idleSeconds` (90) →
   bosh sahifa + `uz`. Ovozli suhbat paytida idle-reset bo'lmaydi (`lastVoiceActivity`).
9. **Birinchi ishga tushishda internet SHART** (kesh bo'sh) — deploy yo'riqnomasida shuni ayt.
10. **3 til to'liq:** har yangi UI matni `uz` + `ru` + `en` uchalasida.
11. **Minimal paketlar:** hozir `window_manager` + `wakelock_plus` + `webview_windows`.
    Yangi paket qo'shishdan oldin foydalanuvchidan **tanlov shaklida** so'ra.
12. **Hokim sanasi** (2026-09-16): `reception-points` → `ticket_prefix: "H"` → `next_reception_at` (UTC → Toshkent +5).
    «Shaxsiy qabul»da faqat hokim kartasi (`isHokimOfficial`) `ContentStore.officialsShown` orqali o'zgaradi:
    sana bor → katta sana + vaqt + joy; yo'q/o'tgan → «Qabul vaqti belgilanmagan»; noma'lum → haftalik matn.
    `reception-schedule` bo'sh bo'lsa sana karta **yaratmaydi** — «Ma'lumot kiritilmagan» qoladi (invariant 1).
13. **Vertikal ekran birinchi:** zal kiosklari 1080×1920 portret (Windows 10). UI o'zgarsa: 100% da
    «Shaxsiy qabul» aylantirishsiz sig'sin; 864/720 px (125/150%) da overflow bo'lmasin; header < 1000 px — 2 qator;
    bosh sahifa kartalari haqiqiy qatorlar soniga qarab, blok esa **header ostidan** boshlanadi
    (markazga tekislama — foydalanuvchi talabi, v1.6.1). Ahem (test shrifti) haqiqiydan farq qiladi —
    o'lchash uchun Segoe UI (`C:\Windows\Fonts`) ni `FontLoader` bilan yukla.
14. **Sayyor qabul oynasi:** avval bugungi/kelgusi qabullar, keyin «O'tgan qabullar» (xira);
    kelgusi yo'q bo'lsa — ogohlantirish. Hech narsa yashirilmaydi (`MobileScheduleInfo.isPast`).
    `sayyor_data.dart` generatsiya qilinadi — unga mantiq qo'shma.

### 🛡️ Xavfsizlik
- `exitPassword` manba kodda ochiq (`config.dart`) — u faqat zaldagi tasodifiy odamni to'xtatadi.
  Qattiqlashtirish so'ralsa → skill **`flutter-windows-security`** (SHA-256 + constant-time + backoff).
  So'ralmasa parolga tegma.
- API kalitlari ilovada **yo'q** — Gemini Live uchun vaqtinchalik token backend'dan (`/avatar/voice-token`) olinadi. Shunday qolsin.

---

## ⚙️ Vazifa bajarish workflow

1. **Kod** — shu repoda, yuqoridagi struktura bo'yicha.
2. **Tekshir** — `flutter analyze` + `flutter test`; UI o'zgarsa `KIOSK_WINDOWED=1` bilan ko'rib chiq,
   sensorga oid o'zgarishda `test/touch_input_test.dart` ni kengaytir.
3. **Hujjat** — `…/qabulhona/09 - Mobile (App)/Info Kiosk/`:
   - release yoki katta o'zgarish — yangi `NN - <Mavzu> (YYYY-MM-DD).md` + `00 - Info Kiosk ro'yxati.md`;
   - `…/qabulhona/09 - Mobile (App)/00 - Mobile ro'yxati.md` — versiya / commit jadvali.
4. **API kerak bo'lsa** → `…/qabulhona/01 - Vazifalar (Todo)/01 - Backend.md` ga faqat YANGI TODO:
   ```markdown
   - [ ] **[Mobile so'rovi]** `info_kiosk`: <nima kerak>
   ```
   Seed (kontent) kerak bo'lsa — `…/qabulhona/02 - API/24 - Info Kiosk mock kontent (seed manbasi)/` ga qarang.
5. **Vazifani yop** — `…/qabulhona/01 - Vazifalar (Todo)/03 - Mobile.md`:
   `- [x] ~~Vazifa~~ — YYYY-MM-DD — @kim`
6. **Changelog** — `…/qabulhona/07 - O'zgarishlar tarixi (Changelog).md`

---

## 🚫 HECH QACHON qilma

- ❌ Riverpod / Dio / go_router / Freezed / Hive qo'shma (foydalanuvchi so'ramasa)
- ❌ Ekranga ilova ichidagi (hardcoded) kontentni qaytarma — bo'sh bo'lim «Ma'lumot kiritilmagan» bo'lib qolsin
- ❌ `Backend.md`, `Frontend.md` ni tahrirlama — faqat yangi TODO qo'shish
- ❌ `02 - API/`, `03 - Database (Baza)/`, `08 - Frontend (Web)/` ni o'zgartirma
- ❌ `dist/` dagi eski zip'ni o'chirma yoki ustidan yozma
- ❌ `build/`, `.dart_tool/`, `windows/flutter/ephemeral/`, `*.pdb` ni commit qilma
- ❌ `analyze` / `test` o'tmasdan release chiqarma
- ❌ Bu faylni qo'lda tahrirlama — shablonni o'zgartirib skriptni qayta ishga tushir

## ✅ HAR DOIM qil

- ✅ Session oxirida **2 ta git diff** ko'rsat: bu repo (kod) + `../Projects-FinTech` (hujjat)
- ✅ Conventional commit: bu repoda `feat(content): ...`, `fix(ai): ...`, `fix(tls): ...`; vault'da `docs(mobile): ...`
- ✅ Savolni **tanlov shaklida** ber (2–4 variant + oqibati + tavsiya) — vault qoidasi
- ✅ Push qilishdan oldin foydalanuvchidan so'ra

---

## 🛠️ Skill'lar

Skript quyidagi skill'larni `.claude/skills/<nom>/SKILL.md` ga o'rnatadi (Claude Code avtomatik topadi). Yangilash uchun skriptni qayta ishga tushiring.

| Skill | Manba (`../Projects-FinTech/03_Claude_Skills/`) | Qachon |
|-------|------------------------------------------------|--------|
| `flutter-windows-security` | `03 - Mobile/04 - Flutter Windows security (kiosk).md` | "kiosk xavfsizligi", "chiqish paroli", "obfuscate" |
| `adr-write` | `04 - Umumiy/01 - ADR yozish.md` | "ADR yoz" |
| `conventional-commit` | `04 - Umumiy/02 - Conventional commit.md` | "commit message yoz" |
| Flutter Skills Pack (reference) | `03 - Mobile/03 - Flutter Skills Pack (community).md` | umumiy Flutter savollari — o'rnatish buyrug'i shu faylda |
