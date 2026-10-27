import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'core/update/kiosk_updater.dart';
import 'src/app.dart';
import 'src/config.dart';
import 'src/kiosk_root.dart';
import 'src/services/tls.dart';

/// Kiosk bootstrap: lock the window to fullscreen, block Alt+F4 / close, and
/// keep the screen awake. Set `KIOSK_WINDOWED=1` in the environment to run in a
/// normal resizable window instead (handy for development and screenshots).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final windowed = (Platform.environment['KIOSK_WINDOWED'] ?? '').isNotEmpty;

  final options = WindowOptions(
    title: KioskConfig.orgName,
    fullScreen: !windowed,
    titleBarStyle: windowed ? TitleBarStyle.normal : TitleBarStyle.hidden,
    // Only the development window gets a minimum. The hall kiosks are
    // portrait: at 125–150 % scaling a 1080 px screen is 720–864 logical
    // pixels wide, and a minimum wider than that fights the fullscreen window.
    minimumSize: windowed ? const Size(720, 640) : null,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    if (!windowed) {
      await windowManager.setFullScreen(true);
      await windowManager.setPreventClose(true);
    }
    await windowManager.show();
    await windowManager.focus();
  });

  await WakelockPlus.enable();

  // Online yangilanish (ADR-037). Yangilovchi ham kioskning boshqa so'rovlari
  // kabi ilova bilan birga keladigan ildiz sertifikatlariga ishonadi — eski
  // Windows obrazlarida tizim ildizlari yetishmaydi (services/tls.dart).
  await KioskTls.context();
  KioskUpdater.init(
    KioskUpdateConfig(
      appKey: 'info_kiosk',
      appTitle: 'Info kiosk',
      installName: 'InfoKiosk',
      origin: KioskConfig.backendOrigin,
      httpClient: KioskTls.cachedClient,
    ),
    // Faqat bosh sahifada, dialog ochiq emas va ovozli suhbat yo'q paytda.
    canInstall: KioskRoot.canInstallUpdate,
  );

  runApp(const KioskApp());
}
