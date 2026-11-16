/// A two-hour delivery window, like (start: 18:00 today, label: 'Today, 6–8 PM').
typedef DeliverySlot = ({DateTime start, String label});

/// Slots run 10 AM to 10 PM. Today's slots need 90 minutes to pack.
/// [now] is passed in, so tests can pick any moment.
List<DeliverySlot> deliverySlots(DateTime now, {int limit = 6}) {
  const firstHour = 10, lastStartHour = 20, length = 2;
  final slots = <DeliverySlot>[];

  for (var day = 0; day < 3 && slots.length < limit; day++) {
    final date = DateTime(now.year, now.month, now.day + day);
    final dayName = switch (day) { 0 => 'Today', 1 => 'Tomorrow', _ => _weekday(date) };

    for (var hour = firstHour; hour <= lastStartHour && slots.length < limit; hour += length) {
      final start = DateTime(date.year, date.month, date.day, hour);
      if (start.difference(now) < const Duration(minutes: 90)) continue;
      slots.add((start: start, label: '$dayName, ${_hour(hour)}–${_hour(hour + length)}'));
    }
  }
  return slots;
}

String _hour(int h) {
  final suffix = h < 12 || h == 24 ? 'AM' : 'PM';
  final twelve = h % 12 == 0 ? 12 : h % 12;
  return '$twelve $suffix';
}

String _weekday(DateTime d) =>
    const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1];
