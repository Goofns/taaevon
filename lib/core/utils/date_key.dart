/// The local calendar day of [d] as a sortable `'YYYY-MM-DD'` string.
///
/// Shared by the streak and review schedulers, which both key on the calendar
/// day (not the instant). Kept Flutter-free so it stays unit-testable.
String isoDateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
