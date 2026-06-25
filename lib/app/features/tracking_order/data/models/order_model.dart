enum OrderStatus {
  completed,
  current,
  pending,
}

class TrackingStep {
  final String title;
  final String date;
  final OrderStatus status;

  TrackingStep({
    required this.title,
    required this.date,
    required this.status,
  });
}
