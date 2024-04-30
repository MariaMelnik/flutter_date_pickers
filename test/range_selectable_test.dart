import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/day_type.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("RangeSelectable test.", () {
    test("getDayType() returns correct type for different dates", () {
      final now = DateTime.now();
      final startPeriod = now.subtract(const Duration(days: 3));
      final endPeriod = now.add(const Duration(days: 3));
      final selectedPeriod = DatePeriod(startPeriod, endPeriod);

      final firstDate = now.subtract(const Duration(days: 10));
      final lastDate = now.add(const Duration(days: 10));
      final disabledDate = now.subtract(const Duration(days: 5));

      // ignore: prefer_function_declarations_over_variables
      final selectablePredicate =
          (d) => !DatePickerUtils.sameDate(d, disabledDate);

      final selectableLogic = RangeSelectable(
          selectedPeriod, firstDate, lastDate,
          selectableDayPredicate: selectablePredicate);

      final notSelectedEnabledDateType = selectableLogic.getDayType(firstDate);
      expect(notSelectedEnabledDateType, DayType.notSelected);

      final disabledDateType = selectableLogic.getDayType(disabledDate);
      expect(disabledDateType, DayType.disabled);

      final startPeriodDateType = selectableLogic.getDayType(startPeriod);
      expect(startPeriodDateType, DayType.start);

      final endPeriodDateType = selectableLogic.getDayType(endPeriod);
      expect(endPeriodDateType, DayType.end);

      final periodDays = endPeriod.difference(startPeriod).inDays;

      // Count of the day period which is not start and not end.
      final middleDaysCount = periodDays - 2;
      final middleDates = List.generate(
          middleDaysCount, (i) => startPeriod.add(Duration(days: i + 1)));

      for (DateTime date in middleDates) {
        final middlePeriodDateType = selectableLogic.getDayType(date);
        expect(middlePeriodDateType, DayType.middle,
            reason: "Incorrect DayType for the date ${date.toString()} "
                "in period ${startPeriod.toString()} "
                "- ${endPeriod.toString()}");
      }
    });
  });

  test(
      "firstDate's time is midnight "
      "and lastDate's time is millisecond before the next day midnight", () {
    final now = DateTime.now();
    final startPeriod = now.subtract(const Duration(days: 3));
    final endPeriod = now.add(const Duration(days: 3));
    final selectedPeriod = DatePeriod(startPeriod, endPeriod);

    final firstDate = now.subtract(const Duration(days: 10));
    final lastDate = now.add(const Duration(days: 10));

    final startOfTheFirstDate =
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    final endOfTheLastDate =
        DateTime(lastDate.year, lastDate.month, lastDate.day, 23, 59, 59, 999);

    final selectableLogic = RangeSelectable(
      selectedPeriod,
      firstDate,
      lastDate,
    );

    expect(selectableLogic.firstDate, startOfTheFirstDate);
    expect(selectableLogic.lastDate, endOfTheLastDate);
  });
}
