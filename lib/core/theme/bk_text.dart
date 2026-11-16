import 'package:basketly/core/theme/bk_colors.dart';
import 'package:flutter/material.dart';

/// One typeface, Schibsted Grotesk. Headings are heavy with tight
/// letter spacing; everything else is calm. Sentence case everywhere.
abstract final class BkText {
  static const family = 'SchibstedGrotesk';

  static const display = TextStyle(
    fontFamily: family, fontSize: 38, fontWeight: FontWeight.w800,
    letterSpacing: -0.95, height: 1.05, color: BkColors.ink,
  );
  static const title = TextStyle(
    fontFamily: family, fontSize: 28, fontWeight: FontWeight.w800,
    letterSpacing: -0.7, height: 1.05, color: BkColors.ink,
  );
  static const heading = TextStyle(
    fontFamily: family, fontSize: 20, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, height: 1.1, color: BkColors.ink,
  );
  static const body = TextStyle(
    fontFamily: family, fontSize: 15, fontWeight: FontWeight.w400,
    height: 1.35, color: BkColors.ink,
  );
  static const bodyStrong = TextStyle(
    fontFamily: family, fontSize: 15, fontWeight: FontWeight.w600,
    height: 1.35, color: BkColors.ink,
  );
  static const label = TextStyle(
    fontFamily: family, fontSize: 13, fontWeight: FontWeight.w600,
    color: BkColors.ink,
  );
  static const small = TextStyle(
    fontFamily: family, fontSize: 13, fontWeight: FontWeight.w400,
    color: BkColors.muted,
  );
  static const tiny = TextStyle(
    fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400,
    color: BkColors.muted,
  );
  static const price = TextStyle(
    fontFamily: family, fontSize: 16, fontWeight: FontWeight.w800,
    letterSpacing: -0.16, color: BkColors.ink,
  );
}
