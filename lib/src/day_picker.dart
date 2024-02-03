import 'package:flutter/material.dart';

import 'date_picker_keys.dart';
import 'day_based_changable_picker.dart';
import 'day_picker_selection.dart';
import 'i_selectable_picker.dart';
import 'styles/date_picker_styles.dart';
import 'styles/event_decoration.dart';
import 'styles/layout_settings.dart';
import 'utils.dart';

/// Date picker for selection one day.
class DayPicker<T extends Object> extends StatelessWidget {
  DayPicker._({
    Key? key,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.selectionLogic,
    required this.selection,
    this.initiallyShowDate,
    this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
    this.datePickerStyles,
    this.datePickerKeys,
    this.selectableDayPredicate,
    this.eventDecorationBuilder,
    this.onMonthChanged,
    this.monthTitleMargin,
    this.monthTitlePadding,
    this.navigationMonthMainAxisAlignment,
    this.navigationMonthTitleDecoration,
  }) : super(key: key);

  /// Creates a day picker where only one single day can be selected.
  ///
  /// See also:
  /// * [DayPicker.multi] - day picker where many single days can be selected.
  static DayPicker<DateTime> single(
      {Key? key,
      BoxDecoration? navigationMonthTitleDecoration,
      EdgeInsetsGeometry? monthTitleMargin,
      EdgeInsetsGeometry? monthTitlePadding,
      MainAxisAlignment? navigationMonthMainAxisAlignment,
      required DateTime selectedDate,
      required ValueChanged<DateTime> onChanged,
      required DateTime firstDate,
      required DateTime lastDate,
      DatePickerLayoutSettings datePickerLayoutSettings =
          const DatePickerLayoutSettings(),
      DateTime? initiallyShowDate,
      DatePickerRangeStyles? datePickerStyles,
      DatePickerKeys? datePickerKeys,
      SelectableDayPredicate? selectableDayPredicate,
      EventDecorationBuilder? eventDecorationBuilder,
      ValueChanged<DateTime>? onMonthChanged}) {
    final startOfTheFirstDate = DatePickerUtils.startOfTheDay(firstDate);
    final endOfTheLastDate = DatePickerUtils.endOfTheDay(lastDate);
    final startOfTheSelectedDate = DatePickerUtils.startOfTheDay(selectedDate);
    final startOfTheInitiallyShowDate = initiallyShowDate == null
        ? null
        : DatePickerUtils.startOfTheDay(initiallyShowDate);

    assert(!startOfTheFirstDate.isAfter(endOfTheLastDate));
    assert(!endOfTheLastDate.isBefore(startOfTheFirstDate));
    assert(!startOfTheSelectedDate.isBefore(startOfTheFirstDate));
    assert(!startOfTheSelectedDate.isAfter(endOfTheLastDate));
    assert(startOfTheInitiallyShowDate == null ||
        !startOfTheInitiallyShowDate.isAfter(endOfTheLastDate));
    assert(startOfTheInitiallyShowDate == null ||
        !startOfTheInitiallyShowDate.isBefore(startOfTheFirstDate));

    final selection = DayPickerSingleSelection(startOfTheSelectedDate);
    final selectionLogic = DaySelectable(
      startOfTheSelectedDate,
      startOfTheFirstDate,
      endOfTheLastDate,
      selectableDayPredicate: selectableDayPredicate,
    );

    return DayPicker<DateTime>._(
      onChanged: onChanged,
      firstDate: startOfTheFirstDate,
      lastDate: endOfTheLastDate,
      initiallyShowDate: startOfTheInitiallyShowDate,
      selectionLogic: selectionLogic,
      selection: selection,
      eventDecorationBuilder: eventDecorationBuilder,
      onMonthChanged: onMonthChanged,
      selectableDayPredicate: selectableDayPredicate,
      datePickerKeys: datePickerKeys,
      datePickerStyles: datePickerStyles,
      datePickerLayoutSettings: datePickerLayoutSettings,
      navigationMonthMainAxisAlignment: navigationMonthMainAxisAlignment,
      monthTitlePadding: monthTitlePadding,
      monthTitleMargin: monthTitleMargin,
      navigationMonthTitleDecoration: navigationMonthTitleDecoration,
    );
  }

  /// Creates a day picker  where many single days can be selected.
  ///
  /// See also:
  /// * [DayPicker.single] - day picker where only one single day
  /// can be selected.
  static DayPicker<List<DateTime>> multi({
    Key? key,
    required List<DateTime> selectedDates,
    required ValueChanged<List<DateTime>> onChanged,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerLayoutSettings datePickerLayoutSettings =
        const DatePickerLayoutSettings(),
    DateTime? initiallyShowDate,
    DatePickerRangeStyles? datePickerStyles,
    DatePickerKeys? datePickerKeys,
    SelectableDayPredicate? selectableDayPredicate,
    EventDecorationBuilder? eventDecorationBuilder,
    ValueChanged<DateTime>? onMonthChanged,
    EdgeInsetsGeometry? monthTitleMargin,
    EdgeInsetsGeometry? monthTitlePadding,
    MainAxisAlignment? navigationMonthMainAxisAlignment,
    BoxDecoration? navigationMonthTitleDecoration,
  }) {
    final startOfTheFirstDate = DatePickerUtils.startOfTheDay(firstDate);
    final endOfTheLastDate = DatePickerUtils.endOfTheDay(lastDate);
    final startOfTheInitiallyShowDate = initiallyShowDate == null
        ? null
        : DatePickerUtils.startOfTheDay(initiallyShowDate);
    final selectedDaysStarts =
        selectedDates.map(DatePickerUtils.startOfTheDay).toList();

    assert(!startOfTheFirstDate.isAfter(endOfTheLastDate));
    assert(!endOfTheLastDate.isBefore(startOfTheFirstDate));
    assert(startOfTheInitiallyShowDate == null ||
        !startOfTheInitiallyShowDate.isAfter(endOfTheLastDate));
    assert(startOfTheInitiallyShowDate == null ||
        !startOfTheInitiallyShowDate.isBefore(startOfTheFirstDate));

    final selection = DayPickerMultiSelection(selectedDaysStarts);
    final selectionLogic = DayMultiSelectable(
      selectedDaysStarts,
      startOfTheFirstDate,
      endOfTheLastDate,
      selectableDayPredicate: selectableDayPredicate,
    );

    return DayPicker<List<DateTime>>._(
      onChanged: onChanged,
      firstDate: startOfTheFirstDate,
      lastDate: endOfTheLastDate,
      initiallyShowDate: startOfTheInitiallyShowDate,
      selectionLogic: selectionLogic,
      selection: selection,
      eventDecorationBuilder: eventDecorationBuilder,
      onMonthChanged: onMonthChanged,
      selectableDayPredicate: selectableDayPredicate,
      datePickerKeys: datePickerKeys,
      datePickerStyles: datePickerStyles,
      datePickerLayoutSettings: datePickerLayoutSettings,
      monthTitlePadding: monthTitlePadding,
      monthTitleMargin: monthTitleMargin,
      navigationMonthMainAxisAlignment: navigationMonthMainAxisAlignment,
      navigationMonthTitleDecoration: navigationMonthTitleDecoration,
    );
  }

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

  /// Date for defining what month should be shown initially.
  ///
  /// In case of null earliest of the [selection] will be shown.
  final DateTime? initiallyShowDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Styles what can be customized by user
  final DatePickerRangeStyles? datePickerStyles;

  /// Some keys useful for integration tests
  final DatePickerKeys? datePickerKeys;

  /// Function returns if day can be selected or not.
  ///
  /// If null
  final SelectableDayPredicate? selectableDayPredicate;

  /// Builder to get event decoration for each date.
  ///
  /// For selected days all event styles are overridden by selected styles.
  final EventDecorationBuilder? eventDecorationBuilder;

  // Called when the user changes the month.
  /// New DateTime object represents first day of new month and 00:00 time.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Logic to handle user's selections.
  final ISelectablePicker<T> selectionLogic;

  /// Margin for title.
  final EdgeInsetsGeometry? monthTitleMargin;

  /// Padding for title.
  final EdgeInsetsGeometry? monthTitlePadding;

  /// Month Navigation Row Main AxisAlignment.
  final MainAxisAlignment? navigationMonthMainAxisAlignment;

  /// Month Navigation Title Container decoration.
  final BoxDecoration? navigationMonthTitleDecoration;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DayBasedChangeablePicker<T>(
      selectablePicker: selectionLogic,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
      initiallyShownDate: initiallyShowDate,
      onChanged: onChanged,
      datePickerLayoutSettings: datePickerLayoutSettings,
      datePickerStyles: datePickerStyles ?? DatePickerRangeStyles(),
      datePickerKeys: datePickerKeys,
      eventDecorationBuilder: eventDecorationBuilder,
      onMonthChanged: onMonthChanged,
      monthTitleMargin: monthTitleMargin,
      monthTitlePadding: monthTitlePadding,
      navigationMonthMainAxisAlignment: navigationMonthMainAxisAlignment,
      navigationMonthTitleDecoration: navigationMonthTitleDecoration,
    );
  }
}
