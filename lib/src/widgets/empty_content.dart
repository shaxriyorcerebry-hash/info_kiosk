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
/// network on start-up does not accuse the office of an empty database, and
/// [offline] when the kiosk has never reached the server at all — that is a
/// job for a technician, not for whoever edits the content, and saying so
/// here is what stops a day being lost in the wrong admin panel.
class EmptyContent extends StatelessWidget {
  const EmptyContent({
    super.key,
    required this.lang,
    this.loading = false,
    this.offline = false,
  });

  final Lang lang;
  final bool loading;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    final title = loading
        ? t.contentLoading
        : offline
            ? t.noConnection
            : t.noContent;
    final hint = offline ? t.noConnectionHint : t.noContentHint;
    final icon = loading
        ? Icons.cloud_download_outlined
        : offline
            ? Icons.wifi_off_rounded
            : Icons.inbox_outlined;
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
                child: Icon(icon, size: 46, color: AppColors.primary),
              ),
              const SizedBox(height: 26),
              Text(
                title,
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
                  hint,
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
