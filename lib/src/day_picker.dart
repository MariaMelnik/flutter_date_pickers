import 'package:flutter/material.dart';

import 'date_picker_keys.dart';
import 'date_picker_styles.dart';
import 'day_based_changable_picker.dart';
import 'day_picker_selection.dart';
import 'day_type.dart';
import 'event_decoration.dart';
import 'i_selectable_picker.dart';
import 'layout_settings.dart';

/// Date picker for selection one day.
class DayPicker<T> extends StatelessWidget {

  /// Creates a day picker where only one single day can be selected.
  ///
  /// See also:
  /// * [DayPicker.multi] - day picker where many single days can be selected.
  DayPicker.single({Key key,
    @required DateTime selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
    this.datePickerStyles,
    this.datePickerKeys,
    this.selectableDayPredicate,
    this.eventDecorationBuilder,
    this.onMonthChanged}) :
        selection = DayPickerSingleSelection(selectedDate),
        selectionLogic =  DaySelectable(
            selectedDate, firstDate, lastDate,
            selectableDayPredicate: selectableDayPredicate),
        assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!lastDate.isBefore(firstDate)),
        assert(!selectedDate.isBefore(firstDate)),
        assert(!selectedDate.isAfter(lastDate)),
        super(key: key);


  /// Creates a day picker  where many single days can be selected.
  ///
  /// See also:
  /// * [DayPicker.single] - day picker where only one single day
  /// can be selected.
  DayPicker.multi({Key key,
    @required List<DateTime> selectedDates,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
    this.datePickerStyles,
    this.datePickerKeys,
    this.selectableDayPredicate,
    this.eventDecorationBuilder,
    this.onMonthChanged}) :
        selection = DayPickerMultiSelection(selectedDates),
        selectionLogic =  DayMultiSelectable(
            selectedDates, firstDate, lastDate,
            selectableDayPredicate: selectableDayPredicate),
        assert(selectedDates != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(!lastDate.isBefore(firstDate)),
        // assert(!selection.isBefore(firstDate)),
        // assert(!selection.isAfter(lastDate)),
        super(key: key);


  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DayPickerSelection selection;

  /// Called when the user picks a day.
  final ValueChanged<T> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;

  /// Some keys useful for integration tests
  final DatePickerKeys datePickerKeys;

  /// Function returns if day can be selected or not.
  final SelectableDayPredicate selectableDayPredicate;

  /// Builder to get event decoration for each date.
  ///
  /// All event styles are overriden by selected styles
  /// except days with dayType is [DayType.notSelected].
  final EventDecorationBuilder eventDecorationBuilder;

  // Called when the user changes the month.
  /// New DateTime object represents first day of new month and 00:00 time.
  final ValueChanged<DateTime> onMonthChanged;

  /// Logic to handle user's selections.
  final ISelectablePicker selectionLogic;
  
  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DayBasedChangeablePicker<T>(
      selectablePicker: selectionLogic,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
      onChanged: onChanged,
      datePickerLayoutSettings: datePickerLayoutSettings,
      datePickerStyles: datePickerStyles ?? DatePickerStyles(),
      datePickerKeys: datePickerKeys,
      eventDecorationBuilder: eventDecorationBuilder,
      onMonthChanged: onMonthChanged,
    );
  }
}