import 'package:basketly/features/orders/domain/order.dart';

enum OrderStage { placed, packed, onTheWay, delivered, cancelled }

/// How long packing takes in the demo.
const packingTime = Duration(minutes: 10);

/// How long after the slot starts the rider arrives.
const rideTime = Duration(hours: 1);

/// There is no admin app to move orders along, so in this demo the stage
/// also moves with the clock. A status set by hand in the Supabase Table
/// Editor wins when it is further along.
/// [now] is passed in, so tests can pick any moment.
OrderStage stageOf(Order order, DateTime now) {
  if (order.status == 'cancelled') return OrderStage.cancelled;

  final saved = switch (order.status) {
    'packed' => OrderStage.packed,
    'on_the_way' => OrderStage.onTheWay,
    'delivered' => OrderStage.delivered,
    _ => OrderStage.placed,
  };

  final byClock = switch (now) {
    _ when !now.isBefore(order.slotStart.add(rideTime)) => OrderStage.delivered,
    _ when !now.isBefore(order.slotStart) => OrderStage.onTheWay,
    _ when now.difference(order.createdAt) >= packingTime => OrderStage.packed,
    _ => OrderStage.placed,
  };

  return saved.index > byClock.index ? saved : byClock;
}

/// When each stage happened (or is planned to).
DateTime stageTime(Order order, OrderStage stage) => switch (stage) {
      OrderStage.placed || OrderStage.cancelled => order.createdAt,
      OrderStage.packed => order.createdAt.add(packingTime),
      OrderStage.onTheWay => order.slotStart,
      OrderStage.delivered => order.slotStart.add(rideTime),
    };

/// How far along the hero bar is, 0 to 1.
double stageProgress(OrderStage stage) => switch (stage) {
      OrderStage.placed => 0.12,
      OrderStage.packed => 0.4,
      OrderStage.onTheWay => 0.66,
      OrderStage.delivered => 1,
      OrderStage.cancelled => 0,
    };

String stageName(OrderStage stage) => switch (stage) {
      OrderStage.placed => 'Placed',
      OrderStage.packed => 'Packed',
      OrderStage.onTheWay => 'On the way',
      OrderStage.delivered => 'Delivered',
      OrderStage.cancelled => 'Cancelled',
    };

/// 'today', 'tomorrow' or 'on Mon 16 Nov'.
String dayWord(DateTime day, DateTime now) {
  final a = DateTime(day.year, day.month, day.day);
  final b = DateTime(now.year, now.month, now.day);
  return switch (a.difference(b).inDays) {
    0 => 'today',
    1 => 'tomorrow',
    -1 => 'yesterday',
    _ => 'on ${_shortDate(day)}',
  };
}

String _shortDate(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
}

/// '5:42 PM'
String clockTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// '15 Nov' for the order list.
String listDate(DateTime d) => _shortDate(d).substring(4);
