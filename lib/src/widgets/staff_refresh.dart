import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../theme.dart';

/// Staff held the logo: fetch now rather than wait for the timer, and say how
/// it went — the notice is the only sign on screen that anything happened.
///
/// [lang] is read twice, so a notice follows the visitor language even if it
/// changes while the request is out. [refresh] never throws and reports
/// whether every answer arrived (`ContentStore.refresh`).
Future<void> runStaffRefresh(
  BuildContext context, {
  required Lang Function() lang,
  required Future<bool> Function() refresh,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(_notice(Tr(lang()).refreshing, Icons.sync_rounded));
  final ok = await refresh();
  if (!context.mounted) return;
  final t = Tr(lang());
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(ok
        ? _notice('${t.refreshDone} · ${AppData.formatTime(DateTime.now())}',
            Icons.check_circle_outline_rounded)
        : _notice(t.refreshFailed, Icons.cloud_off_rounded, error: true));
}

SnackBar _notice(String text, IconData icon, {bool error = false}) => SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 640,
      duration: const Duration(seconds: 4),
      backgroundColor: error ? const Color(0xFF8A2A2A) : AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
