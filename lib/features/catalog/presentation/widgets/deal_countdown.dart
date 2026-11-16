import 'dart:async';

import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';

/// "Ends in 42:17", counting down to the top of the hour.
/// A plain StatefulWidget: the ticking clock is display-only, so it
/// doesn't belong in a Cubit.
class DealCountdown extends StatefulWidget {
  const DealCountdown({super.key});

  @override
  State<DealCountdown> createState() => _DealCountdownState();
}

class _DealCountdownState extends State<DealCountdown> {
  late Timer _timer;
  late Duration _left = _untilNextHour();

  static Duration _untilNextHour() {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    return nextHour.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _left = _untilNextHour());
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // a running timer after dispose would call setState and crash
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _left.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Ends in $minutes:$seconds',
        style: BkText.label.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
