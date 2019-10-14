import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/date_picker_styles.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/layout_settings.dart';
import 'package:flutter_date_pickers/src/date_picker_keys.dart';
import 'package:flutter_date_pickers/src/day_based_changable_picker.dart';


// Styles for current displayed period (month) title: Theme.of(context).textTheme.subhead
//
// Styles for date picker cell:
// current date: Theme.of(context).textTheme.body2.copyWith(color: themeData.accentColor)
// if date disabled: Theme.of(context).textTheme.body1.copyWith(color: themeData.disabledColor)
// if date selected:
//  text - Theme.of(context).accentTextTheme.body2
//  for box decoration - color is Theme.of(context).accentColor and box shape is circle

// selectedDate must be between firstDate and lastDate

class DayPicker extends StatelessWidget {
  /// Creates a day picker.
  DayPicker(
      {Key key,
      @required this.selectedDate,
      @required this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
      this.datePickerKeys,
      this.datePickerStyles,
      this.selectableDayPredicate})
      : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Styles what can be customized by user
  final DatePickerRangeStyles datePickerStyles;

  /// Some keys useful for integration tests
  final DatePickerKeys datePickerKeys;

  /// Function returns if day can be selected or not.
  final SelectableDayPredicate selectableDayPredicate;

  @override
  Widget build(BuildContext context){
    ISelectablePicker<DateTime> daySelectablePicker = DaySelectable(
      selectedDate,
      firstDate,
      lastDate,
      selectableDayPredicate: selectableDayPredicate
    );

    return DayBasedChangablePicker<DateTime>(
      selectablePicker: daySelectablePicker,
      selectedDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      datePickerLayoutSettings: datePickerLayoutSettings,
      datePickerStyles: datePickerStyles,
      datePickerKeys: datePickerKeys,
    );
  }
}