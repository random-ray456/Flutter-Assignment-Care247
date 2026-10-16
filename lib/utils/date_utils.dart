const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date as yyyy-MM-dd, the same format used by the API.
String toApiDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Turns "1985-03-15" into "15 Mar 1985".
/// If the text is not a valid date it is returned as it is.
String toDisplayDate(String apiDate) {
  final date = DateTime.tryParse(apiDate);
  if (date == null) return apiDate;
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}
