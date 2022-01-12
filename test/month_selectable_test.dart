import 'package:flutter_date_pickers/src/day_type.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group("MonthSelectable test.", () {
    test("getDayType() returns correct type for different dates", () {
      final firstDate = DateTime(2020, 1, 10);
      final lastDate = DateTime(2021, 1, 11, 23, 59, 59);

      final selectedDate = DateTime(2021, 1, 10);
      final dayAfterLastDate = DateTime(2021, 2, 1);

      final selectableLogic = MonthSelectable(
        selectedDate,
        firstDate,
        lastDate,
      );

      final selectedDateType = selectableLogic.getDayType(selectedDate);
      final notSelectedEnabledDateType = selectableLogic.getDayType(firstDate);
      final disabledDateType = selectableLogic.getDayType(dayAfterLastDate);

      expect(selectedDateType, DayType.single);
      expect(notSelectedEnabledDateType, DayType.notSelected);
      expect(disabledDateType, DayType.disabled);
    });
  });
}
