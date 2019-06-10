import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/day_type.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Interface for selection logic of the different date pickers.
abstract class ISelectablePicker<T> {
  /// The earliest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime lastDate;

  @protected
  StreamController<T> onUpdateController = StreamController<T>.broadcast();
  Stream<T> get onUpdate => onUpdateController.stream;

  ISelectablePicker(this.firstDate, this.lastDate);
  
  DayType getDayType(DateTime day);

  /// Call when user tap on the day cell.
  void onDayTapped(DateTime selectedDate);

  // returns weather passed day before the beginning of the [firstDay] or after the end of the [lastDay]
  @protected
  bool isDisabled(DateTime day) {
    final DateTime beginOfTheFirstDay =
    DateTime(firstDate.year, firstDate.month, firstDate.day);
    final DateTime endOfTheLastDay =
    DateTime(lastDate.year, lastDate.month, lastDate.day + 1)
        .subtract(Duration(microseconds: 1));

    return day.isAfter(endOfTheLastDay) || day.isBefore(beginOfTheFirstDay);
  }

  void dispose(){
    onUpdateController.close();
  }
}



class WeekSelectable extends ISelectablePicker<DatePeriod> {
  DateTime firstDayOfSelectedWeek;
  DateTime lastDayOfSelectedWeek;

  // according to MaterialLocalization.firstDayOfWeekIndex
  final int firstDayOfWeekIndex;

  WeekSelectable(DateTime selectedDate, this.firstDayOfWeekIndex, DateTime firstDate, DateTime lastDate) : super(firstDate, lastDate) {
    DatePeriod selectedWeek = _getNewSelectedPeriod(selectedDate);
    firstDayOfSelectedWeek = selectedWeek.start;
    lastDayOfSelectedWeek = selectedWeek.end;
  }
  
  @override
  DayType getDayType(DateTime date) {
    DayType result;
    
    if (isDisabled(date)) {
      result = DayType.disabled;
    } else if (_isDaySelected(date)) {
      DateTime firstNotDisabledDayOfSelectedWeek =
      firstDayOfSelectedWeek.isBefore(firstDate)
          ? firstDate
          : firstDayOfSelectedWeek;

      DateTime lastNotDisabledDayOfSelectedWeek =
      lastDayOfSelectedWeek.isAfter(lastDate)
          ? lastDate
          : lastDayOfSelectedWeek;

      if (DatePickerUtils.sameDate(date, firstNotDisabledDayOfSelectedWeek) &&
          DatePickerUtils.sameDate(date, lastNotDisabledDayOfSelectedWeek)) {
        result = DayType.single;
      } else if (DatePickerUtils.sameDate(date, firstDayOfSelectedWeek) ||
          DatePickerUtils.sameDate(date, firstDate)) {
        result = DayType.start;
      } else if (DatePickerUtils.sameDate(date, lastDayOfSelectedWeek) ||
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

    return onUpdateController.add(newPeriod);
  }

  // returns new selected period according to tapped date
  DatePeriod _getNewSelectedPeriod(DateTime tappedDay) {
    DatePeriod newPeriod;

    DateTime firstDayOfTappedWeek =
    DatePickerUtils.getFirstDayOfWeek(tappedDay, firstDayOfWeekIndex);
    DateTime lastDayOfTappedWeek =
    DatePickerUtils.getLastDayOfWeek(tappedDay, firstDayOfWeekIndex);

    DateTime firstNotDisabledDayOfSelectedWeek =
    firstDayOfTappedWeek.isBefore(firstDate)
        ? firstDate
        : firstDayOfTappedWeek;

    DateTime lastNotDisabledDayOfSelectedWeek =
    lastDayOfTappedWeek.isAfter(lastDate) ? lastDate : lastDayOfTappedWeek;

    newPeriod = DatePeriod(
        firstNotDisabledDayOfSelectedWeek, lastNotDisabledDayOfSelectedWeek);
    return newPeriod;
  }


  bool _isDaySelected(DateTime date) {
    return !(date.isBefore(firstDayOfSelectedWeek) ||
        date.isAfter(lastDayOfSelectedWeek));
  }
}


class DaySelectable extends ISelectablePicker<DateTime> {
  DateTime selectedDate;

  DaySelectable(this.selectedDate, DateTime firstDate, DateTime lastDate) : super(firstDate, lastDate);

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

  RangeSelectable(this.selectedPeriod, DateTime firstDate, DateTime lastDate) : super(firstDate, lastDate);

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

  // return new selected period according to tapped date
  DatePeriod _getNewSelectedPeriod(DateTime tappedDate) {
    // check if was selected only one date and we should generate period
    bool sameDate =
    DatePickerUtils.sameDate(selectedPeriod.start, selectedPeriod.end);
    DatePeriod newPeriod;

    if (sameDate) {
      // if user tap on the already selected single day
      bool selectedAlreadySelectedDay =
      DatePickerUtils.sameDate(tappedDate, selectedPeriod.end);
      bool isSelectedFirstDay = DatePickerUtils.sameDate(tappedDate, firstDate);
      bool isSelectedLastDay = DatePickerUtils.sameDate(tappedDate, lastDate);

      if (selectedAlreadySelectedDay) {
        if (isSelectedFirstDay && isSelectedLastDay)
          newPeriod = DatePeriod(firstDate, lastDate);
        else if (isSelectedFirstDay)
          newPeriod = DatePeriod(firstDate, firstDate);
        else if (isSelectedLastDay)
          newPeriod = DatePeriod(tappedDate, lastDate);
        else
          newPeriod = DatePeriod(tappedDate, tappedDate);
      } else {
        DateTime startOfTheSelectedDay = DateTime(selectedPeriod.start.year,
            selectedPeriod.start.month, selectedPeriod.start.day);

        if (!tappedDate.isAfter(startOfTheSelectedDay)) {
          newPeriod = DatePickerUtils.sameDate(tappedDate, firstDate)
              ? DatePeriod(firstDate, selectedPeriod.end)
              : DatePeriod(tappedDate, selectedPeriod.end);
        } else {
          newPeriod = DatePickerUtils.sameDate(tappedDate, lastDate)
              ? DatePeriod(selectedPeriod.start, lastDate)
              : DatePeriod(selectedPeriod.start, tappedDate);
        }
      }
    } else {
      bool sameAsFirst = DatePickerUtils.sameDate(tappedDate, firstDate);
      bool sameAsLast = DatePickerUtils.sameDate(tappedDate, lastDate);

      if (sameAsFirst && sameAsLast)
        newPeriod = DatePeriod(firstDate, lastDate);
      else if (sameAsFirst)
        newPeriod = DatePeriod(firstDate, firstDate);
      else if (sameAsLast)
        newPeriod = DatePeriod(tappedDate, lastDate);
      else
        newPeriod = DatePeriod(tappedDate, tappedDate);
    }

    return newPeriod;
  }

}

