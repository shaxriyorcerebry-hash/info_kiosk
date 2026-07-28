import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme.dart';

/// What a section shows when the backend has nothing in it yet.
///
/// The kiosk draws every word it shows from the backend, so a section that has
/// not been filled in is simply empty — and says so plainly, in the visitor's
/// language, instead of leaving them staring at a blank screen wondering
/// whether the machine is broken.
///
/// Pass [loading] while the very first fetch is still in flight, so a slow
/// network on start-up does not accuse the office of an empty database.
class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key, required this.lang, this.loading = false});

  final Lang lang;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: Icon(
                  loading
                      ? Icons.cloud_download_outlined
                      : Icons.inbox_outlined,
                  size: 46,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                loading ? t.contentLoading : t.noContent,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              if (!loading) ...[
                const SizedBox(height: 12),
                Text(
                  t.noContentHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.45,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
