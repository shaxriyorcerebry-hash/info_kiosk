/// Static kiosk configuration — organisation details shown across the app.
///
/// These are the only values that are specific to a given reception office;
/// everything else (departments, schedule, FAQ …) lives in [AppData].
class KioskConfig {
  const KioskConfig._();

  static const String orgName = 'Xalq qabulxonasi';
  static const String orgAddress = 'Nurafshon shahri';
  static const String orgPhone = '1000';
  static const String trustPhone = '1000';

  /// Seconds of inactivity before the kiosk resets to the home screen.
  static const int idleSeconds = 90;

  static const String logoAsset = 'assets/images/qabulxona_icon.jpg';
}
