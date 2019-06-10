import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/date_period.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/layout_settings.dart';
import 'package:flutter_date_pickers/src/date_picker_keys.dart';
import 'package:flutter_date_pickers/src/day_based_changable_picker.dart';


// Styles for current displayed period: Theme.of(context).textTheme.subhead
//
// Styles for date picker cell:
// current date: Theme.of(context).textTheme.body2.copyWith(color: themeData.accentColor)
// if date disabled: Theme.of(context).textTheme.body1.copyWith(color: themeData.disabledColor)
// if date selected:
//  text - Theme.of(context).accentTextTheme.body2
//  for box decoration - color is Theme.of(context).accentColor and box shape is circle

// selectedPeriod must be between firstDate and lastDate

class RangePicker extends StatelessWidget {
  /// Creates a month picker.
  RangePicker(
      {Key key,
      @required this.selectedPeriod,
      @required this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
      this.datePickerKeys,
      this.datePickerStyles})
      : assert(selectedPeriod != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedPeriod.start.isAfter(firstDate) ||
            selectedPeriod.start.isAtSameMomentAs(firstDate)),
        assert(selectedPeriod.end.isBefore(lastDate) ||
            selectedPeriod.end.isAtSameMomentAs(lastDate)),
        super(key: key);

  /// The currently selected period.
  ///
  /// This date is highlighted in the picker.
  final DatePeriod selectedPeriod;

  /// Called when the user picks a week.
  final ValueChanged<DatePeriod> onChanged;

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

  @override
  Widget build(BuildContext context){

    ISelectablePicker<DatePeriod> rangeSelectablePicker = RangeSelectable(
        selectedPeriod,
        firstDate,
        lastDate
    );

    return DayBasedChangablePicker<DatePeriod>(
      selectablePicker: rangeSelectablePicker,
      selectedDate: selectedPeriod.start,
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      datePickerLayoutSettings: datePickerLayoutSettings,
      datePickerStyles: datePickerStyles,
      datePickerKeys: datePickerKeys,
    );
  }
}
