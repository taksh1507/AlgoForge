import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatTime(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  return '${hours}h ${mins}m';
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}

double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
