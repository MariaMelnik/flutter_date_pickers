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

/// Date picker for range selection.
class RangePicker extends StatelessWidget {
  /// Creates a range picker.
  RangePicker({
    Key? key,
    required DatePeriod selectedPeriod,
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
        selectedPeriod = DatePeriod(
            DatePickerUtils.startOfTheDay(selectedPeriod.start),
            DatePickerUtils.endOfTheDay(selectedPeriod.end)),
        initiallyShowDate = initiallyShowDate == null
            ? null
            : DatePickerUtils.startOfTheDay(initiallyShowDate),
        super(key: key) {
    assert(!this.firstDate.isAfter(this.lastDate));
    assert(!this.lastDate.isBefore(this.firstDate));
    assert(!this.selectedPeriod.start.isBefore(this.firstDate));
    assert(!this.selectedPeriod.end.isAfter(this.lastDate));
    assert(this.initiallyShowDate == null ||
        !this.initiallyShowDate!.isAfter(this.lastDate));
    assert(this.initiallyShowDate == null ||
        !this.initiallyShowDate!.isBefore(this.firstDate));
  }

  /// The currently selected period.
  ///
  /// This date is highlighted in the picker.
  final DatePeriod selectedPeriod;

  /// Called when the user picks a week.
  final ValueChanged<DatePeriod> onChanged;

  /// Called when the error was thrown after user selection.
  /// (e.g. when user selected a range with one or more days
  /// that can't be selected)
  final OnSelectionError? onSelectionError;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Date for defining what month should be shown initially.
  ///
  /// In case of null start of the [selectedPeriod] will be shown.
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
    ISelectablePicker<DatePeriod> rangeSelectablePicker = RangeSelectable(
        selectedPeriod, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return DayBasedChangeablePicker<DatePeriod>(
      selectablePicker: rangeSelectablePicker,
      selection: DayPickerRangeSelection(selectedPeriod),
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