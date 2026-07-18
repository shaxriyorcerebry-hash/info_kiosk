import 'package:flutter/material.dart';

import '../config.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

/// Address, phones, hours and a location panel.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key, required this.lang});

  final Lang lang;

  @override
  Widget build(BuildContext context) {
    final t = Tr(lang);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 6, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: InfoCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Row(icon: Icons.place_outlined, label: t.addressLabel, value: KioskConfig.orgAddress),
                        _Row(icon: Icons.call_outlined, label: t.phoneLabel, value: KioskConfig.orgPhone),
                        _Row(icon: Icons.support_agent_outlined, label: t.trustLabel, value: KioskConfig.trustPhone),
                        _Row(icon: Icons.schedule_outlined, label: t.hoursLabel, value: t.hoursValue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  flex: 5,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 380),
                    child: InfoCard(
                      padding: const EdgeInsets.all(14),
                      child: _LocationPanel(
                        title: t.mapPlaceholder,
                        address: KioskConfig.orgAddress,
                      ),
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

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.panelBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 19, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({required this.title, required this.address});
  final String title;
  final String address;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF2FB), Color(0xFFD9E9FA)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 72, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontSize: 20, color: AppColors.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(address,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
