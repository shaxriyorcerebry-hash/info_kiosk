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
                        _Row(icon: Icons.place_outlined, label: t.addressLabel, value: KioskConfig.orgAddress[lang]!),
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
                        address: KioskConfig.orgAddress[lang]!,
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

/// The office location on an offline OpenStreetMap extract, with a drop pin
/// on the reception building and an address chip beneath it.
class _LocationPanel extends StatelessWidget {
  const _LocationPanel({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(KioskConfig.mapAsset, fit: BoxFit.cover),
          // Drop pin: anchored so its tip touches the office coordinates.
          Align(
            alignment: Alignment(
              KioskConfig.mapPinX * 2 - 1,
              KioskConfig.mapPinY * 2 - 1,
            ),
            child: const FractionalTranslation(
              translation: Offset(0, -0.5),
              child: Icon(Icons.location_on,
                  size: 58,
                  color: Color(0xFFD11F2F),
                  shadows: [
                    Shadow(color: Color(0x59000000), blurRadius: 10, offset: Offset(0, 4)),
                  ]),
            ),
          ),
          // Address chip.
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(color: Color(0x26062040), blurRadius: 14, offset: Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_outlined, size: 22, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(address,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ],
                ),
              ),
            ),
          ),
          // OpenStreetMap attribution (required by the tile licence).
          Positioned(
            right: 6,
            bottom: 2,
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF26415F).withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
