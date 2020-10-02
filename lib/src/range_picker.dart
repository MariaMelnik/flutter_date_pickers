import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'date_period.dart';
import 'date_picker_keys.dart';
import 'date_picker_styles.dart';
import 'day_based_changable_picker.dart';
import 'day_picker_selection.dart';
import 'day_type.dart';
import 'event_decoration.dart';
import 'i_selectable_picker.dart';
import 'layout_settings.dart';
import 'typedefs.dart';

/// Date picker for range selection.
class RangePicker extends StatelessWidget {
  /// Creates a month picker.
  RangePicker(
      {Key key,
      @required this.selectedPeriod,
      @required this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
      this.datePickerStyles,
      this.datePickerKeys,
      this.selectableDayPredicate,
      this.onSelectionError,
      this.eventDecorationBuilder,
      this.onMonthChanged})
      : assert(selectedPeriod != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!lastDate.isBefore(firstDate)),
        assert(!selectedPeriod.start.isBefore(firstDate)),
        assert(!selectedPeriod.end.isAfter(lastDate)),
        super(key: key);

  /// The currently selected period.
  ///
  /// This date is highlighted in the picker.
  final DatePeriod selectedPeriod;

  /// Called when the user picks a week.
  final ValueChanged<DatePeriod> onChanged;

  /// Called when the error was thrown after user selection.
  /// (e.g. when user selected a range with one or more days
  /// that can't be selected)
  final OnSelectionError onSelectionError;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Some keys useful for integration tests
  final DatePickerKeys datePickerKeys;

  /// Styles what can be customized by user
  final DatePickerRangeStyles datePickerStyles;

  /// Function returns if day can be selected or not.
  final SelectableDayPredicate selectableDayPredicate;

  /// Builder to get event decoration for each date.
  ///
  /// All event styles are overridden by selected styles
  /// except days with dayType is [DayType.notSelected].
  final EventDecorationBuilder eventDecorationBuilder;

  /// Called when the user changes the month.
  /// New DateTime object represents first day of new month and 00:00 time.
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    ISelectablePicker<DatePeriod> rangeSelectablePicker = RangeSelectable(
        selectedPeriod, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return DayBasedChangeablePicker<DatePeriod>(
      selectablePicker: rangeSelectablePicker,
      selection: DayPickerRangeSelection(selectedPeriod),
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      onSelectionError: onSelectionError,
      datePickerLayoutSettings: datePickerLayoutSettings,
      datePickerStyles: datePickerStyles ?? DatePickerRangeStyles(),
      datePickerKeys: datePickerKeys,
      eventDecorationBuilder: eventDecorationBuilder,
      onMonthChanged: onMonthChanged,
    );
  }
}
