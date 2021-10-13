import 'utils.dart';

/// Base class for month based pickers selection.
abstract class MonthPickerSelection {

  /// If this is before [dateTime].
  bool isBefore(DateTime dateTime);

  /// If this is after [dateTime].
  bool isAfter(DateTime dateTime);

  /// Returns earliest [DateTime] in this selection.
  DateTime get earliest;

  /// Returns latest [DateTime] in this selection.
  DateTime get latest;

  /// If this selection is empty.
  bool get isEmpty;

  /// If this selection is not empty.
  bool get isNotEmpty;

  /// Constructor to allow children to have constant constructor.
  const MonthPickerSelection();
}

/// Selection with only one selected month.
///
/// See also:
/// * [MonthPickerMultiSelection] - selection with one or many single dates.
class MonthPickerSingleSelection extends MonthPickerSelection {

  /// Selected date.
  final DateTime selectedDate;

  /// Creates selection with only one selected date.
  const MonthPickerSingleSelection(this.selectedDate)
      : assert(selectedDate != null);

  @override
  bool isAfter(DateTime dateTime) => selectedDate.isAfter(dateTime);

  @override
  bool isBefore(DateTime dateTime) => selectedDate.isBefore(dateTime);

  @override
  DateTime get earliest => selectedDate;

  @override
  DateTime get latest => selectedDate;

  @override
  bool get isEmpty => selectedDate == null;

  @override
  bool get isNotEmpty => selectedDate != null;
}


/// Selection with one or many single months.
///
/// See also:
/// * [MonthPickerSingleSelection] - selection with only one selected date.
class MonthPickerMultiSelection extends MonthPickerSelection {

  /// List of the selected dates.
  final List<DateTime> selectedDates;

  /// Selection with one or many single dates.
  MonthPickerMultiSelection(this.selectedDates)
      : assert(selectedDates != null);


  @override
  bool isAfter(DateTime dateTime)
  => selectedDates.every((d) => d.isAfter(dateTime));

  @override
  bool isBefore(DateTime dateTime)
  => selectedDates.every((d) => d.isBefore(dateTime));

  @override
  DateTime get earliest => DatePickerUtils.getEarliestFromList(selectedDates);

  @override
  DateTime get latest => DatePickerUtils.getLatestFromList(selectedDates);

  @override
  bool get isEmpty => selectedDates.isEmpty;

  @override
  bool get isNotEmpty => selectedDates.isNotEmpty;
}