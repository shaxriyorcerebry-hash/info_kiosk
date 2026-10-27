import 'package:flutter/material.dart';

import '../../core/update/kiosk_update_ui.dart';
import '../theme.dart';
import 'pressable.dart';

/// Xodim sozlamalari paneli — «Chiqish» (eshik) tugmasini uzoq bosganda
/// ochiladi, **parolsiz** (lead qarori, ADR-037 dan keyingi talab).
///
/// Ichida: «Yangilanish» bo'limi ([KioskUpdatePanel] — versiyalar, holat,
/// «Hozir tekshirish», «Hozir o'rnatish», log) va «Chiqish» tugmasi. Parol
/// faqat ilovadan chiqish uchun kerak: «Chiqish» bosilsa panel yopiladi va
/// odatdagi parolli chiqish oqimi boshlanadi.
///
/// `true` — xodim «Chiqish»ni tanladi; `false` — panel shunchaki yopildi.
/// [onActivity] panel ichidagi har teginishda chaqiriladi — aks holda kiosk
/// root'ining bo'shlik taymeri (u dialoglar ichidagi teginishlarni ko'rmaydi)
/// xodim ishlab turgan panelni yopib yuboradi.
Future<bool> showKioskSettings(
  BuildContext context, {
  VoidCallback? onActivity,
}) async {
  final exit = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (ctx) => Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => onActivity?.call(),
      child: const KioskSettingsPanel(),
    ),
  );
  return exit ?? false;
}

/// Panelning o'zi (alohida — test va qayta ishlatish uchun).
class KioskSettingsPanel extends StatelessWidget {
  const KioskSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.88;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: maxH),
        child: Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(28),
          elevation: 24,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const KioskUpdatePanel(),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Yopish',
                              filled: false,
                              onTap: () => Navigator.of(context).pop(false),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _ActionButton(
                              label: 'Chiqish',
                              icon: Icons.lock_outline_rounded,
                              filled: true,
                              onTap: () => Navigator.of(context).pop(true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ilovadan chiqish uchun parol so\'raladi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: AppColors.muted),
                      ),
                    ],
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

/// Ko'k sarlavha tasmasi — parol dialogi bilan bir xil uslubda.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E4B8F), Color(0xFF2563EB)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sozlamalar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xodimlar uchun — ilova yangilanishi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.primaryDark;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : const Color(0x0F2563EB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? AppColors.primary : const Color(0x472563EB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
