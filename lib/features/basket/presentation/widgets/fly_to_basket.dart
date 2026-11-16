import 'package:flutter/material.dart';

/// Flies a small picture of the product from one widget to another
/// (the add button to the basket), above every screen.
abstract final class FlyToBasket {
  static void launch({
    required BuildContext context,
    required GlobalKey from,
    required GlobalKey to,
    required Widget child,
    required VoidCallback onLanded,
  }) {
    final fromBox = from.currentContext?.findRenderObject() as RenderBox?;
    final toBox = to.currentContext?.findRenderObject() as RenderBox?;

    // Nothing to fly between, or the person turned animations off:
    // just add the item.
    if (fromBox == null || toBox == null || MediaQuery.disableAnimationsOf(context)) {
      onLanded();
      return;
    }

    final start = fromBox.localToGlobal(fromBox.size.center(Offset.zero));
    final end = toBox.localToGlobal(toBox.size.center(Offset.zero));

    // An OverlayEntry draws on top of the whole app, outside the page.
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Flight(
        start: start,
        end: end,
        onDone: () {
          entry.remove();
          onLanded(); // the basket bounces as the item lands
        },
        child: child,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _Flight extends StatefulWidget {
  const _Flight({
    required this.start,
    required this.end,
    required this.onDone,
    required this.child,
  });

  final Offset start;
  final Offset end;
  final VoidCallback onDone;
  final Widget child;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  static const _size = 48.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward().whenComplete(widget.onDone);

  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  // The arc's high point: midway across, above both ends.
  late final Offset _control = Offset(
    (widget.start.dx + widget.end.dx) / 2,
    (widget.start.dy < widget.end.dy ? widget.start.dy : widget.end.dy) - 90,
  );

  /// A quadratic Bezier curve: start -> pulled toward control -> end.
  Offset _pointAt(double t) {
    final u = 1 - t;
    return widget.start * (u * u) + _control * (2 * u * t) + widget.end * (t * t);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final t = _t.value;
        final point = _pointAt(t);
        final scale = 1 - 0.65 * t; // shrinks to about a third
        final opacity = t < 0.75 ? 1.0 : (1 - t) / 0.25; // fades at the end

        return Positioned(
          left: point.dx - _size / 2,
          top: point.dy - _size / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        );
      },
      child: SizedBox.square(dimension: _size, child: widget.child),
    );
  }
}
