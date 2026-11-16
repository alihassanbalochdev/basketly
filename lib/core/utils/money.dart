import 'package:intl/intl.dart';

final _grouping = NumberFormat.decimalPattern('en_US');

/// Prices are whole rupees (int). 3290 -> "Rs 3,290".
String rs(int rupees) => 'Rs ${_grouping.format(rupees)}';
