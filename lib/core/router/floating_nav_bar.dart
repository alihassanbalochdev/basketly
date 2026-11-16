import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:flutter/material.dart';

typedef NavItem = ({IconData icon, IconData activeIcon, String label});

/// The white pill that floats above every tab. Two tabs on each side,
/// the basket button raised in the middle.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.basket,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Widget basket;

  static const items = <NavItem>[
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Browse'),
    (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: 'Orders'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget tab(int index) => _NavTab(
          item: items[index],
          selected: index == currentIndex,
          onTap: () => onSelect(index),
        );

    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: BkColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(34)),
        boxShadow: BkShadow.floating,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          tab(0),
          tab(1),
          // Lifted so it sits half above the bar.
          Transform.translate(offset: const Offset(0, -16), child: basket),
          tab(2),
          tab(3),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BkColors.plum : BkColors.muted;

    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox(
          width: 56,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.activeIcon : item.icon, color: color, size: 23),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              // Saffron dot under the active tab.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: selected ? BkColors.saffron : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
