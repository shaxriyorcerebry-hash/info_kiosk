import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

/// Services grid + how-to-apply note.
class XizmatlarScreen extends StatelessWidget {
  const XizmatlarScreen({super.key, required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    final rows = AppData.xizmatlar[lang]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  for (final s in rows)
                    SizedBox(
                      width: 460,
                      child: InfoCard(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s[0],
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.25)),
                            const SizedBox(height: 8),
                            Text(s[1],
                                style: const TextStyle(fontSize: 20, height: 1.4, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F1FA),
                  border: Border.all(color: const Color(0xFFC4D6EC)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.arizaTitle,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 8),
                    Text(t.arizaText,
                        style: const TextStyle(fontSize: 20, height: 1.5, color: AppColors.body)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
