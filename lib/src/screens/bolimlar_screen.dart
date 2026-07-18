import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

/// Departments & staff — one card per department.
class BolimlarScreen extends StatelessWidget {
  const BolimlarScreen({super.key, required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final rows = AppData.bolimlar[lang]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              for (final r in rows) _DeptCard(r),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeptCard extends StatelessWidget {
  const _DeptCard(this.r);
  final List<String> r; // [name, person, room, phone]

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 460,
      child: InfoCard(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r[0],
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.25)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 24, color: AppColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r[1], style: const TextStyle(fontSize: 21, color: AppColors.body)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Chip(icon: Icons.meeting_room_outlined, text: r[2]),
                _Chip(icon: Icons.phone_outlined, text: r[3]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.ink),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
