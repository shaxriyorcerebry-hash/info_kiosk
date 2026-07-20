import 'package:flutter_test/flutter_test.dart';
import 'package:info_kiosk/src/kiosk_state.dart';
import 'package:info_kiosk/src/l10n.dart';
import 'package:info_kiosk/src/screen.dart';

void main() {
  test('back pops one jadval level at a time, then goes home', () {
    final s = KioskState();
    s.open(Screen.jadval);
    s.openJadval(JadvalView.sayyor);

    s.back();
    expect(s.screen, Screen.jadval);
    expect(s.jadvalView, JadvalView.hub);

    s.back();
    expect(s.screen, Screen.home);
    s.dispose();
  });

  test('back pops the open masalalar organisation first', () {
    final s = KioskState();
    s.open(Screen.masalalar);
    s.openMasalaOrg(3);

    s.back();
    expect(s.screen, Screen.masalalar);
    expect(s.masalaOrg, isNull);

    s.back();
    expect(s.screen, Screen.home);
    s.dispose();
  });

  test('opening a section starts at its top level', () {
    final s = KioskState();
    s.open(Screen.jadval);
    s.openJadval(JadvalView.shaxsiy);
    s.goHome();
    s.open(Screen.jadval);
    expect(s.jadvalView, JadvalView.hub);

    s.open(Screen.masalalar);
    s.openMasalaOrg(1);
    s.open(Screen.masalalar);
    expect(s.masalaOrg, isNull);
    s.dispose();
  });

  test('idle reset returns to a pristine home state', () {
    final s = KioskState();
    s.setLang(Lang.ru);
    s.open(Screen.jadval);
    s.openJadval(JadvalView.sayyor);

    s.reset();
    expect(s.lang, Lang.uz);
    expect(s.screen, Screen.home);
    expect(s.jadvalView, JadvalView.hub);
    expect(s.masalaOrg, isNull);
    expect(s.faqOpen, -1);
    s.dispose();
  });
}
