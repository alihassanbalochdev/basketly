import 'package:flutter/material.dart';

abstract final class BkSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0; // screen side padding
  static const xxl = 24.0;

  /// Room at the bottom of scrolling screens so the floating nav
  /// never covers the last item.
  static const navClearance = 120.0;
}

abstract final class BkRadius {
  static const tile = BorderRadius.all(Radius.circular(24));
  static const card = BorderRadius.all(Radius.circular(22));
  static const hero = BorderRadius.all(Radius.circular(28));
  static const small = BorderRadius.all(Radius.circular(16));
}

abstract final class BkShadow {
  /// Only for things that float above the page: nav bar, basket, search.
  static const floating = [
    BoxShadow(color: Color(0x243D1440), blurRadius: 32, offset: Offset(0, 12)),
  ];
  static const subtle = [
    BoxShadow(color: Color(0x0F3D1440), blurRadius: 10, offset: Offset(0, 2)),
  ];
}
