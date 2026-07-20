import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

/// Reception procedure: numbered steps + required documents + a note.
class QabulScreen extends StatelessWidget {
  const QabulScreen({super.key, required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    final steps = AppData.qabulSteps[lang]!;
    final docs = AppData.qabulDocs[lang]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InfoCard(
                        padding: const EdgeInsets.all(28),
                        child: _StepsColumn(title: t.qabulStepsTitle, steps: steps),
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: InfoCard(
                        padding: const EdgeInsets.all(28),
                        child: _DocsColumn(title: t.qabulDocsTitle, docs: docs),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  border: Border.all(color: const Color(0xFFF0DFB4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t.qabulNote,
                  style: const TextStyle(fontSize: 19, height: 1.45, color: Color(0xFF7A5B12)),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  t.lawRef,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepsColumn extends StatelessWidget {
  const _StepsColumn({required this.title, required this.steps});
  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardTitle(title),
        const SizedBox(height: 18),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(steps[i],
                    style: const TextStyle(fontSize: 21, height: 1.4, color: AppColors.body)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DocsColumn extends StatelessWidget {
  const _DocsColumn({required this.title, required this.docs});
  final String title;
  final List<String> docs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardTitle(title),
        const SizedBox(height: 18),
        for (var i = 0; i < docs.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.panelBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description_outlined, size: 24, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(docs[i],
                      style: const TextStyle(fontSize: 21, height: 1.4, color: AppColors.body)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink),
      );
}
