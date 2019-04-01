# flutter_date_pickers

A set of date pickers:
   * `DayPicker` for separete day selection
   * `WeekPicker` for whole week selection
   * `RangePicker` for random range selection
   * `MonthPicker` for month selection

![](demoDatePickers.gif)

## Usage

```dart
// Create week date picker with passed parameters
Widget buildWeekDatePicker (DateTime selectedDate, DateTime firstAllowedDate, DateTime lastAllowedDate, ValueChanged<DatePeriod> onNewSelected) {
  return WeekPicker(
      selectedDate: selectedDate,
      onChanged: onNewSelected,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate
  );
}
```

For help getting started with Flutter, view our
[online documentation](https://flutter.io/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.