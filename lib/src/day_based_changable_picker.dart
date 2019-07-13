import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/basic_day_based_widget.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Date picker based on [DayBasedPicker] picker (for days, weeks, ranges).
/// Allows select previous/next month.
class DayBasedChangablePicker<T> extends StatefulWidget {
  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a week.
  final ValueChanged<T> onChanged;

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

  const DayBasedChangablePicker({Key key, this.selectedDate, this.onChanged, this.firstDate, this.lastDate, this.datePickerLayoutSettings, this.datePickerStyles, this.datePickerKeys, this.selectablePicker}) : super(key: key);

  @override
  State<DayBasedChangablePicker<T>> createState() => _DayBasedChangablePicker<T>();
}


class _DayBasedChangablePicker<T> extends State<DayBasedChangablePicker<T>> {
  MaterialLocalizations localizations;
  TextDirection textDirection;

  DateTime _todayDate;
  DateTime _currentDisplayedMonthDate;
  DateTime _previousMonthDate;
  DateTime _nextMonthDate;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow =
    DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
    const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime targetDate = DatePickerUtils.addMonthsToMonthDate(widget.firstDate, index);

    final ThemeData theme = Theme.of(context);
    DatePickerStyles styles = widget.datePickerStyles ?? DatePickerStyles();
    styles = styles.fulfillWithTheme(theme);


    widget.selectablePicker.onUpdate.listen((newSelectedDate) => widget.onChanged(newSelectedDate));

    return DayBasedPicker(
      key: ValueKey<DateTime>(targetDate),
      selectablePicker: widget.selectablePicker,
      currentDate: _todayDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: targetDate,
      datePickerLayoutSettings: widget.datePickerLayoutSettings,
      selectedPeriodKey: widget.datePickerKeys?.selectedPeriodKeys,
      datePickerStyles: styles,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.datePickerLayoutSettings.monthPickerPortraitWidth,
      height: widget.datePickerLayoutSettings.maxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: MonthPickerSortKey.calendar,
            child: PageView.builder(
              key: ValueKey<DateTime>(widget.selectedDate),
              controller: _dayPickerController,
              scrollDirection: Axis.horizontal,
              itemCount: DatePickerUtils.monthDelta(widget.firstDate, widget.lastDate) + 1,
              itemBuilder: _buildItems,
              onPageChanged: _handleMonthPageChanged,
            ),
          ),
          SizedBox(
            height: widget.datePickerLayoutSettings.dayPickerRowHeight,
            child: Padding(
              padding: widget.datePickerLayoutSettings.contentPadding, //match _DayPicker main layout padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Semantics(
                    sortKey: MonthPickerSortKey.previousMonth,
//                    child: IconButton(
//                      key: widget.datePickerKeys?.previousPageIconKey,
//                      icon: const Icon(Icons.chevron_left),
//                      tooltip: _isDisplayingFirstMonth
//                          ? null
//                          : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
//                      onPressed:
//                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
//                    ),
                    child: CupertinoButton(
                      key: widget.datePickerKeys?.previousPageIconKey,
                      child: const Icon(Icons.chevron_left),
//                      tooltip: _isDisplayingFirstMonth
//                          ? null
//                          : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                      onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                    ),
                  ),
                  Semantics(
                    sortKey: MonthPickerSortKey.nextMonth,
//                    child: IconButton(
//                      key: widget.datePickerKeys?.nextPageIconKey,
//                      icon: const Icon(Icons.chevron_right),
//                      tooltip: _isDisplayingLastMonth
//                          ? null
//                          : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
//                      onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
//                    ),
                    child: CupertinoButton(
                      key: widget.datePickerKeys?.nextPageIconKey,
                      child: const Icon(Icons.chevron_right),
//                      tooltip: _isDisplayingLastMonth
//                          ? null
//                          : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                      onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                    ),
                  ),
                ],
              ),
            ),
          )
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
}
