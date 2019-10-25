import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/day_type.dart';
import 'package:flutter_date_pickers/src/unselectable_period_error.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Interface for selection logic of the different date pickers.
abstract class ISelectablePicker<T> {
  /// The earliest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime lastDate;

  /// Function returns if day can be selected or not.
  final SelectableDayPredicate _selectableDayPredicate;

  @protected
  StreamController<T> onUpdateController = StreamController<T>.broadcast();

  /// Stream with new selected (T) event.
  ///
  /// Throws [UnselectablePeriodException] if there is any custom disabled date in selected.
  Stream<T> get onUpdate => onUpdateController.stream;

  ISelectablePicker(this.firstDate, this.lastDate, this._selectableDayPredicate);

  DayType getDayType(DateTime day);

  /// Call when user tap on the day cell.
  void onDayTapped(DateTime selectedDate);

  /// Returns if given day is disabled.
  ///
  /// Returns weather given day before the beginning of the [firstDay] or after the end of the [lastDay].
  /// If [_selectableDayPredicate] is set checks it as well.
  @protected
  bool isDisabled(DateTime day) {
    final DateTime beginOfTheFirstDay = DatePickerUtils.startOfTheDay(firstDate);
    final DateTime endOfTheLastDay = DatePickerUtils.endOfTheDay(lastDate);
    final bool customDisabled = _selectableDayPredicate != null
      ? !_selectableDayPredicate(day)
      : false;

    return day.isAfter(endOfTheLastDay) || day.isBefore(beginOfTheFirstDay) || customDisabled;
  }

  void dispose(){
    onUpdateController.close();
  }
}



class WeekSelectable extends ISelectablePicker<DatePeriod> {
  DateTime _firstDayOfSelectedWeek;
  DateTime _lastDayOfSelectedWeek;

  // It is int from 0 to 6 where 0 points to Sunday and 6 points to Saturday.
  // According to MaterialLocalization.firstDayOfWeekIndex.
  final int _firstDayOfWeekIndex;

  WeekSelectable(
      DateTime selectedDate,
      this._firstDayOfWeekIndex,
      DateTime firstDate,
      DateTime lastDate,
      {SelectableDayPredicate selectableDayPredicate}
    ) : super(firstDate, lastDate, selectableDayPredicate)
  {
    DatePeriod selectedWeek = _getNewSelectedPeriod(selectedDate);
    _firstDayOfSelectedWeek = selectedWeek.start;
    _lastDayOfSelectedWeek = selectedWeek.end;
  }

  @override
  DayType getDayType(DateTime date) {
    DayType result;

    if (isDisabled(date)) {
      result = DayType.disabled;
    } else if (_isDaySelected(date)) {
      DateTime firstNotDisabledDayOfSelectedWeek = _firstDayOfSelectedWeek.isBefore(firstDate)
          ? firstDate
          : _firstDayOfSelectedWeek;

      DateTime lastNotDisabledDayOfSelectedWeek = _lastDayOfSelectedWeek.isAfter(lastDate)
          ? lastDate
          : _lastDayOfSelectedWeek;

      if (DatePickerUtils.sameDate(date, firstNotDisabledDayOfSelectedWeek) &&
          DatePickerUtils.sameDate(date, lastNotDisabledDayOfSelectedWeek)) {
        result = DayType.single;
      } else if (DatePickerUtils.sameDate(date, _firstDayOfSelectedWeek) ||
          DatePickerUtils.sameDate(date, firstDate)) {
        result = DayType.start;
      } else if (DatePickerUtils.sameDate(date, _lastDayOfSelectedWeek) ||
          DatePickerUtils.sameDate(date, lastDate)) {
        result = DayType.end;
      } else {
        result = DayType.middle;
      }
    } else {
      result = DayType.notSelected;
    }

    return result;
  }


  @override
  void onDayTapped(DateTime selectedDate) {
    DatePeriod newPeriod = _getNewSelectedPeriod(selectedDate);
    List<DateTime> customDisabledDays = _disabledDatesInPeriod(newPeriod);

    customDisabledDays.isEmpty
      ? onUpdateController.add(newPeriod)
      : onUpdateController.addError(UnselectablePeriodException(customDisabledDays));
  }

  // Returns new selected period according to tapped date.
  // Doesn't check custom disabled days. You have to check it separately if it needs.
  DatePeriod _getNewSelectedPeriod(DateTime tappedDay) {
    DatePeriod newPeriod;

    DateTime firstDayOfTappedWeek = DatePickerUtils.getFirstDayOfWeek(tappedDay, _firstDayOfWeekIndex);
    DateTime lastDayOfTappedWeek = DatePickerUtils.getLastDayOfWeek(tappedDay, _firstDayOfWeekIndex);

    DateTime firstNotDisabledDayOfSelectedWeek = firstDayOfTappedWeek.isBefore(firstDate)
        ? firstDate
        : firstDayOfTappedWeek;

    DateTime lastNotDisabledDayOfSelectedWeek = lastDayOfTappedWeek.isAfter(lastDate)
        ? lastDate
        : lastDayOfTappedWeek;

    newPeriod = DatePeriod(
        firstNotDisabledDayOfSelectedWeek, lastNotDisabledDayOfSelectedWeek);
    return newPeriod;
  }


  bool _isDaySelected(DateTime date) {
    return !(date.isBefore(_firstDayOfSelectedWeek) ||
        date.isAfter(_lastDayOfSelectedWeek));
  }

  List<DateTime> _disabledDatesInPeriod(DatePeriod period) {
    List<DateTime> result = List<DateTime>();

    var date = period.start;

    while(!date.isAfter(period.end)) {
      if (isDisabled(date)) result.add(date);

      date = date.add(Duration(days: 1));
    }

    return result;
  }
}


class DaySelectable extends ISelectablePicker<DateTime> {
  DateTime selectedDate;

  DaySelectable(
      this.selectedDate,
      DateTime firstDate,
      DateTime lastDate,
      {SelectableDayPredicate selectableDayPredicate}
  ) : super(firstDate, lastDate, selectableDayPredicate);

  @override
  DayType getDayType(DateTime date) {
    DayType result;

    if (isDisabled(date)) {
      result = DayType.disabled;
    } else if (_isDaySelected(date)) {
      result = DayType.single;
    } else {
      result = DayType.notSelected;
    }

    return result;
  }

  bool _isDaySelected(DateTime date) {
    return DatePickerUtils.sameDate(date, selectedDate);
  }

  @override
  void onDayTapped(DateTime selectedDate) {
    DateTime newSelected = DatePickerUtils.sameDate(firstDate, selectedDate)
        ? selectedDate
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return onUpdateController.add(newSelected);
  }
}


class RangeSelectable extends ISelectablePicker<DatePeriod>{
  DatePeriod selectedPeriod;

  RangeSelectable(
      this.selectedPeriod,
      DateTime firstDate,
      DateTime lastDate,
      {SelectableDayPredicate selectableDayPredicate}
   ) : super(firstDate, lastDate, selectableDayPredicate);

  @override
  DayType getDayType(DateTime date) {
    DayType result;

    if (isDisabled(date)) {
      result = DayType.disabled;
    } else if (_isDaySelected(date)) {
      if (DatePickerUtils.sameDate(date, selectedPeriod.start) &&
          DatePickerUtils.sameDate(date, selectedPeriod.end)) {
        result = DayType.single;
      } else if (DatePickerUtils.sameDate(date, selectedPeriod.start) ||
          DatePickerUtils.sameDate(date, firstDate)) {
        result = DayType.start;
      } else if (DatePickerUtils.sameDate(date, selectedPeriod.end) ||
          DatePickerUtils.sameDate(date, lastDate)) {
        result = DayType.end;
      } else {
        result = DayType.middle;
      }
    } else {
      result = DayType.notSelected;
    }

    return result;
  }

  bool _isDaySelected(DateTime date) {
    return !(date.isBefore(selectedPeriod.start) ||
        date.isAfter(selectedPeriod.end));
  }

  @override
  void onDayTapped(DateTime selectedDate) {
    DatePeriod newPeriod =  _getNewSelectedPeriod(selectedDate);

    return onUpdateController.add(newPeriod);
  }

  // Returns new selected period according to tapped date.
  DatePeriod _getNewSelectedPeriod(DateTime tappedDate) {
    // check if was selected only one date and we should generate period
    bool sameDate = DatePickerUtils.sameDate(selectedPeriod.start, selectedPeriod.end);
    DatePeriod newPeriod;

    // Was selected one-day-period.
    // With new user tap will be generated 2 dates as a period.
    if (sameDate) {
      // if user tap on the already selected single day
      bool selectedAlreadySelectedDay = DatePickerUtils.sameDate(tappedDate, selectedPeriod.end);
      bool isSelectedFirstDay = DatePickerUtils.sameDate(tappedDate, firstDate);
      bool isSelectedLastDay = DatePickerUtils.sameDate(tappedDate, lastDate);

      if (selectedAlreadySelectedDay) {
        if (isSelectedFirstDay && isSelectedLastDay)
          newPeriod = DatePeriod(firstDate, lastDate);
        else if (isSelectedFirstDay)
          newPeriod = DatePeriod(firstDate, DatePickerUtils.endOfTheDay(firstDate));
        else if (isSelectedLastDay)
          newPeriod = DatePeriod(DatePickerUtils.startOfTheDay(lastDate), lastDate);
        else
          newPeriod = DatePeriod(DatePickerUtils.startOfTheDay(tappedDate), DatePickerUtils.endOfTheDay(tappedDate));
      } else {
        DateTime startOfTheSelectedDay = DatePickerUtils.startOfTheDay(selectedPeriod.start);

        if (!tappedDate.isAfter(startOfTheSelectedDay)) {
          newPeriod = DatePickerUtils.sameDate(tappedDate, firstDate)
              ? DatePeriod(firstDate, selectedPeriod.end)
              : DatePeriod(DatePickerUtils.startOfTheDay(tappedDate), selectedPeriod.end);
        } else {
          newPeriod = DatePickerUtils.sameDate(tappedDate, lastDate)
              ? DatePeriod(selectedPeriod.start, lastDate)
              : DatePeriod(selectedPeriod.start,  DatePickerUtils.endOfTheDay(tappedDate));
        }
      }

      // Was selected 2 dates as a period.
      // With new user tap new one-day-period will be generated.
    } else {
      bool sameAsFirst = DatePickerUtils.sameDate(tappedDate, firstDate);
      bool sameAsLast = DatePickerUtils.sameDate(tappedDate, lastDate);

      if (sameAsFirst && sameAsLast)
        newPeriod = DatePeriod(firstDate, lastDate);
      else if (sameAsFirst)
        newPeriod = DatePeriod(firstDate, DatePickerUtils.endOfTheDay(firstDate));
      else if (sameAsLast)
        newPeriod = DatePeriod(DatePickerUtils.startOfTheDay(tappedDate), lastDate);
      else
        newPeriod = DatePeriod(DatePickerUtils.startOfTheDay(tappedDate), DatePickerUtils.endOfTheDay(tappedDate));
    }

    return newPeriod;
  }
}

