
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/utils.dart';

abstract class DayPickerSelection {
  bool isBefore(DateTime dateTime);
  bool isAfter(DateTime dateTime);
  DateTime get earliest;
  bool get isEmpty;
  bool get isNotEmpty;

  // This constructor allows children to have constant constructor.
  const DayPickerSelection();
}

class DayPickerSingleSelection extends DayPickerSelection {
  final DateTime selectedDate;

  const DayPickerSingleSelection(this.selectedDate)
      : assert(selectedDate != null);

  @override
  bool isAfter(DateTime dateTime) => selectedDate.isAfter(dateTime);

  @override
  bool isBefore(DateTime dateTime) => selectedDate.isAfter(dateTime);

  @override
  DateTime get earliest => selectedDate;

  @override
  bool get isEmpty => selectedDate == null;

  @override
  bool get isNotEmpty => selectedDate != null;
}

class DayPickerMultiSelection extends DayPickerSelection {
  final List<DateTime> selectedDates;

  DayPickerMultiSelection(this.selectedDates)
      : assert(selectedDates != null && selectedDates.isNotEmpty);


  @override
  bool isAfter(DateTime dateTime)
  => selectedDates.every((d) => d.isAfter(dateTime));

  @override
  bool isBefore(DateTime dateTime)
  => selectedDates.every((d) => d.isBefore(dateTime));

  @override
  DateTime get earliest => DatePickerUtils.getEarliestFromList(selectedDates);

  @override
  bool get isEmpty => selectedDates.isEmpty;

  @override
  bool get isNotEmpty => selectedDates.isNotEmpty;
}


class DayPickerRangeSelection extends DayPickerSelection {
  final DatePeriod selectedRange;

  const DayPickerRangeSelection(this.selectedRange)
      : assert(selectedRange != null);

  @override
  DateTime get earliest => selectedRange.start;

  @override
  bool isAfter(DateTime dateTime) => selectedRange.start.isAfter(dateTime);

  @override
  bool isBefore(DateTime dateTime) => selectedRange.end.isBefore(dateTime);

  @override
  bool get isEmpty => selectedRange == null;

  @override
  bool get isNotEmpty => selectedRange != null;
}