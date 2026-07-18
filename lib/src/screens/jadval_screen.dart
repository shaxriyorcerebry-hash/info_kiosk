import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

/// Working hours + leadership reception schedule.
class JadvalScreen extends StatelessWidget {
  const JadvalScreen({super.key, required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    final work = AppData.workRows[lang]!;
    final rows = AppData.jadval[lang]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: InfoCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.workTitle,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < work.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.panelBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(work[i][0],
                                      style: const TextStyle(fontSize: 21, color: AppColors.body)),
                                ),
                                Text(work[i][1],
                                    style: const TextStyle(
                                        fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.ink)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  flex: 5,
                  child: InfoCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.receptionTitle,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        const SizedBox(height: 18),
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _ScheduleRow(rows[i]),
                        ],
                        const SizedBox(height: 18),
                        Text(t.receptionNote,
                            style: const TextStyle(fontSize: 19, height: 1.45, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow(this.row);
  final List<String> row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1EAF5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(row[0],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
          ),
          Expanded(
            flex: 2,
            child: Text(row[1], style: const TextStyle(fontSize: 20, color: AppColors.body)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5FAF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(row[2],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
