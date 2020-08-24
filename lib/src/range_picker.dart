import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/date_period.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/layout_settings.dart';
import 'package:flutter_date_pickers/src/date_picker_keys.dart';
import 'package:flutter_date_pickers/src/day_based_changable_picker.dart';
import 'package:flutter_date_pickers/src/typedefs.dart';

// Styles for current displayed period: Theme.of(context).textTheme.subhead
//
// Styles for date picker cell:
// current date: Theme.of(context).textTheme.body2.copyWith(color: themeData.accentColor)
// if date disabled: Theme.of(context).textTheme.body1.copyWith(color: themeData.disabledColor)
// if date selected:
//  text - Theme.of(context).accentTextTheme.body2
//  for box decoration - color is Theme.of(context).accentColor and box shape is circle

// selectedPeriod must be between firstDate and lastDate

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
  /// (e.g. when user selected a range with one or more days what can't be selected)
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
  /// All event styles are overriden by selected styles
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
      selectedDate: selectedPeriod.start,
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
