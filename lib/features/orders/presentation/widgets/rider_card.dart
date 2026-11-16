import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';

/// Shown while the order is on the way. The rider is demo data.
class RiderCard extends StatelessWidget {
  const RiderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: BkColors.surface,
        borderRadius: BkRadius.card,
        boxShadow: BkShadow.subtle,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: BkColors.soft,
            child: Text('A', style: TextStyle(fontWeight: FontWeight.w800, color: BkColors.plum)),
          ),
          const SizedBox(width: BkSpace.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed', style: BkText.bodyStrong),
                Text('Honda CD 70, LEC-4821', style: BkText.small),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Call rider (demo)',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling is not part of the demo')),
            ),
            style: IconButton.styleFrom(backgroundColor: BkColors.plum),
            icon: const Icon(Icons.call_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
