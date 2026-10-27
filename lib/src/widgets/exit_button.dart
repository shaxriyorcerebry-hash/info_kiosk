import 'package:flutter/material.dart';

import '../theme.dart';
import 'pressable.dart';

/// Small, discreet exit affordance shown inside the footer. It is a door icon
/// on a blue-and-white badge. A single tap does nothing (lead decision
/// 2026-10-27: visitors must not reach the exit dialog by tapping); holding it
/// opens the staff «Sozlamalar» panel — updates and the password-protected
/// exit.
///
/// The badge stays visually small — it is for staff, not for visitors, and it
/// should not invite curious taps — but it sits inside a 56×56 touch area, so
/// a member of staff hits it first time without aiming. It carries no tooltip:
/// a tooltip only appears on hover or long-press — and long-press is taken by
/// the settings panel — and the door icon says enough on its own.
class ExitButton extends StatelessWidget {
  const ExitButton({super.key, required this.onLongPress});

  /// Uzoq bosish — xodim uchun «Sozlamalar» paneli (parolsiz): yangilanish va
  /// parolli «Chiqish». Oddiy bosish hech narsa qilmaydi.
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {}, // bir bosish — hech narsa (faqat bosilish animatsiyasi)
      onLongPress: onLongPress,
      pressedScale: 0.88,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332563EB),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.meeting_room_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
