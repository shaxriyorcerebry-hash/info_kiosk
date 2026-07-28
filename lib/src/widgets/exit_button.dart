import 'package:flutter/material.dart';

import '../theme.dart';
import 'pressable.dart';

/// Small, discreet exit affordance shown inside the footer. It is a door icon
/// on a blue-and-white badge; tapping it asks for confirmation before leaving
/// kiosk mode.
///
/// The badge stays visually small — it is for staff, not for visitors, and it
/// should not invite curious taps — but it sits inside a 56×56 touch area, so
/// a member of staff hits it first time without aiming. It carries no tooltip:
/// a tooltip only appears on hover or long-press, neither of which happens on
/// a kiosk screen, and the door icon says enough on its own.
class ExitButton extends StatelessWidget {
  const ExitButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
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
