import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';

/// Delivery address and the account avatar.
/// The address is a placeholder until the account module adds real ones.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Change delivery address',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deliver to', style: BkText.tiny),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'DHA Phase 5, Lahore',
                            overflow: TextOverflow.ellipsis,
                            style: BkText.bodyStrong,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: BkColors.soft,
          child: Icon(Icons.person_rounded, color: BkColors.plum),
        ),
      ],
    );
  }
}
