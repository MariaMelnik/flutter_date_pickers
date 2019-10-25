import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/basic_day_based_widget.dart';
import 'package:flutter_date_pickers/src/event_decoration.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/month_navigation_row.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';
import 'package:flutter_date_pickers/src/typedefs.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Date picker based on [DayBasedPicker] picker (for days, weeks, ranges).
/// Allows select previous/next month.
class DayBasedChangablePicker<T> extends StatefulWidget {
  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a new T.
  final ValueChanged<T> onChanged;

  /// Called when the error was thrown after user selection.
  final OnSelectionError onSelectionError;

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

  /// Logic for date selections.
  final ISelectablePicker selectablePicker;

  /// Builder to get event decoration for each date.
  ///
  /// All event styles are overriden by selected styles
  /// except days with dayType is [DayType.notSelected].
  final EventDecorationBuilder eventDecorationBuilder;

  const DayBasedChangablePicker({
    Key key,
    this.selectedDate,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    @required this.datePickerLayoutSettings,
    @required this.datePickerStyles,
    this.datePickerKeys,
    this.selectablePicker,
    this.onSelectionError,
    this.eventDecorationBuilder
  }) : assert(datePickerLayoutSettings != null),
       assert(datePickerStyles != null),
       super(key: key);

  @override
  State<DayBasedChangablePicker<T>> createState() => _DayBasedChangablePickerState<T>();
}


class _DayBasedChangablePickerState<T> extends State<DayBasedChangablePicker<T>> {
  MaterialLocalizations localizations;
  TextDirection textDirection;

  DateTime _todayDate;
  DateTime _currentDisplayedMonthDate;
  DateTime _previousMonthDate;
  DateTime _nextMonthDate;

  // Styles from widget fulfilled with current Theme.
  DatePickerStyles _resultStyles;

  Timer _timer;
  PageController _dayPickerController;

  /// True if the first permitted month is displayed.
  bool get _isDisplayingFirstMonth => !_currentDisplayedMonthDate
      .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

  /// True if the last permitted month is displayed.
  bool get _isDisplayingLastMonth => !_currentDisplayedMonthDate
      .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = DatePickerUtils.monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(DayBasedChangablePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = DatePickerUtils.monthDelta(widget.firstDate, widget.selectedDate);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }

    if (widget.datePickerStyles != oldWidget.datePickerStyles) {
      final ThemeData theme = Theme.of(context);
      _resultStyles = widget.datePickerStyles.fulfillWithTheme(theme);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);

    final ThemeData theme = Theme.of(context);
    _resultStyles = widget.datePickerStyles.fulfillWithTheme(theme);
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.datePickerLayoutSettings.monthPickerPortraitWidth,
      height: widget.datePickerLayoutSettings.maxDayPickerHeight,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: widget.datePickerLayoutSettings.dayPickerRowHeight,
            child: Padding(
              padding: widget.datePickerLayoutSettings.contentPadding, //match _DayPicker main layout padding
              child: MonthNavigationRow(
                previousPageIconKey: widget.datePickerKeys?.previousPageIconKey,
                nextPageIconKey: widget.datePickerKeys?.nextPageIconKey,
                previousMonthTooltip: _isDisplayingFirstMonth
                    ? null
                    : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                nextMonthTooltip: _isDisplayingLastMonth
                    ? null
                    : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                onPreviousMonthTapped: _handlePreviousMonth,
                onNextMonthTapped: _handleNextMonth,
                title: Text(
                  localizations.formatMonthYear(_currentDisplayedMonthDate),
                  key: widget.datePickerKeys?.selectedPeriodKeys,
                  style: _resultStyles.displayedPeriodTitle,
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              sortKey: MonthPickerSortKey.calendar,
              child: PageView.builder(
                key: ValueKey<DateTime>(widget.selectedDate),
                controller: _dayPickerController,
                scrollDirection: Axis.horizontal,
                itemCount: DatePickerUtils.monthDelta(widget.firstDate, widget.lastDate) + 1,
                itemBuilder: _buildCalendar,
                onPageChanged: _handleMonthPageChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow = DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow += const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  Widget _buildCalendar(BuildContext context, int index) {
    final DateTime targetDate = DatePickerUtils.addMonthsToMonthDate(widget.firstDate, index);

    widget.selectablePicker.onUpdate
        .listen((newSelectedDate) => widget.onChanged(newSelectedDate))
        .onError((e) => widget.onSelectionError != null
          ? widget.onSelectionError(e)
          : print(e.toString()));

    return DayBasedPicker(
      key: ValueKey<DateTime>(targetDate),
      selectablePicker: widget.selectablePicker,
      currentDate: _todayDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: targetDate,
      datePickerLayoutSettings: widget.datePickerLayoutSettings,
      selectedPeriodKey: widget.datePickerKeys?.selectedPeriodKeys,
      datePickerStyles: _resultStyles,
      eventDecorationBuilder: widget.eventDecorationBuilder,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_nextMonthDate), textDirection);
      _dayPickerController.nextPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_previousMonthDate), textDirection);
      _dayPickerController.previousPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          DatePickerUtils.addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          DatePickerUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = DatePickerUtils.addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }
}
