import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Presenter for [DayBasedChangeablePicker] to handle month changes.
class DayBasedChangeablePickerPresenter {
  final DateTime firstDate;
  final DateTime lastDate;
  final MaterialLocalizations localizations;
  final bool showPrevMonthDates;
  final bool showNextMonthDates;
  final int firstDayOfWeekIndex;

  Stream<DayBasedChangeablePickerState> get data => _controller.stream;
  DayBasedChangeablePickerState get lastVal => _lastVal;

  DayBasedChangeablePickerPresenter(
      this.firstDate,
      this.lastDate,
      this.localizations,
      this.showPrevMonthDates,
      this.showNextMonthDates,
      int firstDayOfWeekIndex
      ): this.firstDayOfWeekIndex = firstDayOfWeekIndex ?? localizations.firstDayOfWeekIndex;

  void setSelectedData(DateTime selectedDate) {
    bool firstAndLastNotNull = _firstShownDate != null && _lastShownDate != null;
    bool selectedOnCurPage =  firstAndLastNotNull && !selectedDate.isBefore(_firstShownDate)
        && !selectedDate.isAfter(_lastShownDate);
    if (selectedOnCurPage) return;

    changeMonth(selectedDate);
  }

  void gotoPrevMonth() {
    DateTime oldCur = _lastVal.currentMonth;
    DateTime newCurDate = DateTime(oldCur.year, oldCur.month - 1, oldCur.day);
    changeMonth(newCurDate);
  }

  void gotoNextMonth() {
    DateTime oldCur = _lastVal.currentMonth;
    DateTime newCurDate = DateTime(oldCur.year, oldCur.month + 1, oldCur.day);
    changeMonth(newCurDate);
  }

  void changeMonth(DateTime newMonth) {
    bool sameMonth = _lastVal != null
        && DatePickerUtils.sameMonth(_lastVal.currentMonth, newMonth);
    if (sameMonth) return;

    int monthPage = DatePickerUtils.monthDelta(firstDate, newMonth);
    DateTime prevMonth = DatePickerUtils.addMonthsToMonthDate(firstDate, monthPage - 1);
    DateTime curMonth = DatePickerUtils.addMonthsToMonthDate(firstDate, monthPage);
    DateTime nextMonth = DatePickerUtils.addMonthsToMonthDate(firstDate, monthPage + 1);
    _setLastAndFirst(curMonth);

    String prevMonthStr = localizations.formatMonthYear(prevMonth);
    String curMonthStr = localizations.formatMonthYear(curMonth);
    String nextMonthStr = localizations.formatMonthYear(nextMonth);

    bool isFirstMonth = DatePickerUtils.sameMonth(curMonth, firstDate);
    bool isLastMonth = DatePickerUtils.sameMonth(curMonth, lastDate);

    String prevTooltip = isFirstMonth
        ? null
        : "${localizations.previousMonthTooltip} $prevMonthStr";

    String nextTooltip = isLastMonth
        ? null
        : "${localizations.nextMonthTooltip} $nextMonth";

    DayBasedChangeablePickerState newState = DayBasedChangeablePickerState(
        currentMonth: curMonth,
        curMonthDis: curMonthStr,
        prevMonthDis: prevMonthStr,
        nextMonthDis: nextMonthStr,
        prevTooltip: prevTooltip,
        nextTooltip: nextTooltip,
        isFirstMonth: isFirstMonth,
        isLastMonth: isLastMonth
    );

    _updateState(newState);
  }
  
  void dispose () {
    _controller.close();
  }

  void _updateState(DayBasedChangeablePickerState newState) {
    _lastVal = newState;
    _controller.add(newState);
  }

  void _setLastAndFirst(DateTime curMonth) {
    _firstShownDate = DatePickerUtils.firstShownDate(
        curMonth,
        showPrevMonthDates,
        firstDayOfWeekIndex
    );

    _lastShownDate = DatePickerUtils.lastShownDate(
        curMonth,
        showNextMonthDates,
        firstDayOfWeekIndex
    );
  }

  StreamController<DayBasedChangeablePickerState> _controller = StreamController.broadcast();
  DayBasedChangeablePickerState _lastVal;

  // First date currently displayed.
  // If picker shows the end of the previous month it will be date from the last week of the previous month.
  // Otherwise - 1st day of the current month.
  DateTime _firstShownDate;

  // Last date currently displayed.
  // If picker shows the start of the next month it will be date from the first week of the next month.
  // Otherwise - last day of the current month.
  DateTime _lastShownDate;
}


class DayBasedChangeablePickerState {
  final String curMonthDis;
  final String prevMonthDis;
  final String nextMonthDis;

  final String prevTooltip;
  final String nextTooltip;

  final DateTime currentMonth;

  final bool isLastMonth;
  final bool isFirstMonth;

  DayBasedChangeablePickerState({
    @required this.curMonthDis,
    @required this.prevMonthDis,
    @required this.nextMonthDis,
    @required this.prevTooltip,
    @required this.nextTooltip,
    @required this.currentMonth,
    @required this.isLastMonth,
    @required this.isFirstMonth
  });
}