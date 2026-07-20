import 'l10n.dart';

/// Static kiosk configuration — organisation details shown across the app.
///
/// These are the only values that are specific to a given reception office;
/// everything else (departments, schedule, FAQ …) lives in [AppData].
class KioskConfig {
  const KioskConfig._();

  /// Window title / process-facing name (not translated).
  static const String orgName = 'Xalq qabulxonasi';

  /// Short organisation name shown in the footer, per language.
  static const Map<Lang, String> orgShortName = {
    Lang.uz: 'Xalq qabulxonasi',
    Lang.ru: 'Народная приёмная',
    Lang.en: "People's Reception",
  };

  static const Map<Lang, String> orgAddress = {
    Lang.uz: 'Nurafshon shahri',
    Lang.ru: 'город Нурафшон',
    Lang.en: 'Nurafshon city',
  };

  /// Office location shown on the contact map (latitude, longitude).
  static const double orgLat = 41.0245810;
  static const double orgLon = 69.3455854;

  /// Offline map of the office surroundings, stitched from OpenStreetMap
  /// tiles (zoom 15) by `tool` scripts at build time, and the fractional
  /// position of [orgLat]/[orgLon] within that image.
  static const String mapAsset = 'assets/images/office_map.png';
  static const double mapPinX = 0.5979;
  static const double mapPinY = 0.5369;

  static const String orgPhone = '(71) 230-24-30';
  static const String trustPhone = '(71) 230-24-31';

  /// Seconds of inactivity before the kiosk resets to the home screen.
  static const int idleSeconds = 90;

  /// Password required to leave kiosk mode, asked for by the exit button.
  ///
  /// This only stops a visitor walking up and closing the kiosk; it is
  /// compiled into the executable and so is not a secret from anyone with
  /// access to the files on the machine.
  static const String exitPassword = '20median47';

  static const String logoAsset = 'assets/images/xalq_qabulxona_icon.png';

  /// Origin of the qabulhona backend that answers AI questions, or empty to
  /// run fully offline (the kiosk then only uses its built-in knowledge base).
  static const String backendOrigin = 'https://qabulxona.gennis.uz';

  /// API path prefix on that backend.
  static const String apiPrefix = '/api';

  /// Full API base, e.g. `https://qabulxona.gennis.uz/api`. Empty => offline.
  static String get apiBase =>
      backendOrigin.isEmpty ? '' : '$backendOrigin$apiPrefix';

  /// Gemini speaker for the live advisor, requested when minting a token.
  ///
  /// This must be a real voice name. The backend's own default is `auto`,
  /// which Gemini rejects outright ("No matching speaker voice found for
  /// name: auto"), closing the session the moment it opens — so the kiosk
  /// always asks for a specific one. `Aoede` is a warm female voice supported
  /// by every live model, and the avatar kiosk uses it too.
  static const String aiVoice = 'Aoede';
}
