import 'package:equatable/equatable.dart';

class DeliveryAddress extends Equatable {
  const DeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.line,
    required this.city,
  });

  final String fullName;
  final String phone;
  final String line; // house, street, area
  final String city;

  String get oneLine => '$line, $city';

  factory DeliveryAddress.fromRow(Map<String, dynamic> row) => DeliveryAddress(
        fullName: row['full_name'] as String,
        phone: row['phone'] as String,
        line: row['line'] as String,
        city: row['city'] as String,
      );

  Map<String, dynamic> toRow() => {
        'full_name': fullName,
        'phone': phone,
        'line': line,
        'city': city,
      };

  @override
  List<Object?> get props => [fullName, phone, line, city];
}

/// The same rules the server checks. Each returns an error or null.
abstract final class AddressRules {
  static String? name(String? v) =>
      (v ?? '').trim().length < 2 ? 'Enter the name for the delivery' : null;

  static String? phone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length < 10 || digits.length > 13 ? 'Enter a phone number, like 0300 1234567' : null;
  }

  static String? line(String? v) =>
      (v ?? '').trim().length < 5 ? 'Enter house, street and area' : null;

  static String? city(String? v) => (v ?? '').trim().length < 2 ? 'Enter your city' : null;
}
