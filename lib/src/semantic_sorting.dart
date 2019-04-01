// Defines semantic traversal order of the top-level widgets inside the day or week
// picker.
import 'package:flutter/semantics.dart';

class MonthPickerSortKey extends OrdinalSortKey {
  static const MonthPickerSortKey previousMonth = const MonthPickerSortKey(1.0);
  static const MonthPickerSortKey nextMonth = const MonthPickerSortKey(2.0);
  static const MonthPickerSortKey calendar = const MonthPickerSortKey(3.0);

  const MonthPickerSortKey(double order) : super(order);
}



// Defines semantic traversal order of the top-level widgets inside the month
// picker.
class YearPickerSortKey extends OrdinalSortKey {
  static const YearPickerSortKey previousYear = const YearPickerSortKey(1.0);
  static const YearPickerSortKey nextYear = const YearPickerSortKey(2.0);
  static const YearPickerSortKey calendar = const YearPickerSortKey(3.0);

  const YearPickerSortKey(double order) : super(order);
}
