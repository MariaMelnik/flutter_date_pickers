import 'utils.dart';

/// Base class for year based pickers selection.
abstract class YearPickerSelection {
  /// If this is before [dateTime].
  bool isBefore(DateTime dateTime);

  /// If this is after [dateTime].
  bool isAfter(DateTime dateTime);

  /// Returns earliest [DateTime] in this selection.
  DateTime get earliest;

  /// Returns latest [DateTime] in this selection.
  DateTime get latest;

  /// Constructor to allow children to have constant constructor.
  const YearPickerSelection();
}

/// Selection with only one selected Year.
///
/// See also:
/// * [YearPickerMultiSelection] - selection with one or many single dates.
class YearPickerSingleSelection extends YearPickerSelection {
  /// Selected date.
  final DateTime selectedDate;

  /// Creates selection with only one selected date.
  const YearPickerSingleSelection(this.selectedDate);

  @override
  bool isAfter(DateTime dateTime) => selectedDate.year > dateTime.year;

  @override
  bool isBefore(DateTime dateTime) => selectedDate.year < dateTime.year;

  @override
  DateTime get earliest => selectedDate;

  @override
  DateTime get latest => selectedDate;
}

/// Selection with one or many single years.
///
/// See also:
/// * [YearPickerSingleSelection] - selection with only one selected date.
class YearPickerMultiSelection extends YearPickerSelection {
  /// List of the selected dates.
  final List<DateTime> selectedDates;

  /// Selection with one or many single dates.
  YearPickerMultiSelection(this.selectedDates);

  @override
  bool isAfter(DateTime dateTime) =>
      selectedDates.every((d) => d.year > dateTime.year);

  @override
  bool isBefore(DateTime dateTime) =>
      selectedDates.every((d) => d.year < dateTime.year);

  @override
  DateTime get earliest => DatePickerUtils.getEarliestFromList(selectedDates);

  @override
  DateTime get latest => DatePickerUtils.getLatestFromList(selectedDates);
}
