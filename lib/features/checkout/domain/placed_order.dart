typedef PlacedOrder = ({
  String id,
  String number,
  int total,
  String slotLabel,
  String paymentMethod,
});

PlacedOrder placedOrderFromJson(Map<String, dynamic> json) => (
      id: json['id'] as String,
      number: json['number'] as String,
      total: json['total'] as int,
      slotLabel: json['slot_label'] as String,
      paymentMethod: json['payment_method'] as String,
    );
