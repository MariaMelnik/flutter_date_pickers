import 'package:flutter/material.dart';

import 'date_period.dart';
import 'date_picker_keys.dart';
import 'day_based_changable_picker.dart';
import 'day_picker_selection.dart';
import 'i_selectable_picker.dart';
import 'styles/date_picker_styles.dart';
import 'styles/event_decoration.dart';
import 'styles/layout_settings.dart';
import 'typedefs.dart';
import 'utils.dart';

/// Date picker for selection a week.
class WeekPicker extends StatelessWidget {
  /// Creates a month picker.
  WeekPicker({
    Key? key,
    required DateTime selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required this.onChanged,
    DateTime? initiallyShowDate,
    this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
    this.datePickerStyles,
    this.datePickerKeys,
    this.selectableDayPredicate,
    this.onSelectionError,
    this.eventDecorationBuilder,
    this.onMonthChanged,
  })  : firstDate = DatePickerUtils.startOfTheDay(firstDate),
        lastDate = DatePickerUtils.endOfTheDay(lastDate),
        selectedDate = DatePickerUtils.startOfTheDay(selectedDate),
        initiallyShowDate = initiallyShowDate == null
            ? null
            : DatePickerUtils.startOfTheDay(initiallyShowDate),
        super(key: key) {
    assert(!this.firstDate.isAfter(this.lastDate));
    assert(!this.lastDate.isBefore(this.firstDate));
    assert(!this.selectedDate.isBefore(this.firstDate));
    assert(!this.selectedDate.isAfter(this.lastDate));
    assert(this.initiallyShowDate == null ||
        !this.initiallyShowDate!.isAfter(this.lastDate));
    assert(this.initiallyShowDate == null ||
        !this.initiallyShowDate!.isBefore(this.firstDate));
  }

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a week.
  final ValueChanged<DatePeriod> onChanged;

  /// Called when the error was thrown after user selection.
  /// (e.g. when user selected a week with one or more days
  /// what can't be selected)
  final OnSelectionError? onSelectionError;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Date for defining what month should be shown initially.
  ///
  /// In case of null month with earliest date of the selected week
  /// will be shown.
  final DateTime? initiallyShowDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Some keys useful for integration tests
  final DatePickerKeys? datePickerKeys;

  /// Styles what can be customized by user
  final DatePickerRangeStyles? datePickerStyles;

  /// Function returns if day can be selected or not.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Builder to get event decoration for each date.
  ///
  /// For selected days all event styles are overridden by selected styles.
  final EventDecorationBuilder? eventDecorationBuilder;

  /// Called when the user changes the month.
  /// New DateTime object represents first day of new month and 00:00 time.
  final ValueChanged<DateTime>? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);

    int firstDayOfWeekIndex = datePickerStyles?.firstDayOfeWeekIndex ??
        localizations.firstDayOfWeekIndex;

    ISelectablePicker<DatePeriod> weekSelectablePicker = WeekSelectable(
        selectedDate, firstDayOfWeekIndex, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return DayBasedChangeablePicker<DatePeriod>(
      selectablePicker: weekSelectablePicker,
      // todo: maybe create selection for week
      // todo: and change logic here to work with it
      selection: DayPickerSingleSelection(selectedDate),
      firstDate: firstDate,
      lastDate: lastDate,
      initiallyShownDate: initiallyShowDate,
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