class DatePickerUtils {
// returns if two objects have same year, month and day
// time doesn't matter
  static bool sameDate(DateTime dateTimeOne, DateTime dateTimeTwo) {
    return dateTimeOne.year == dateTimeTwo.year &&
        dateTimeOne.month == dateTimeTwo.month &&
        dateTimeOne.day == dateTimeTwo.day;
  }

// returns if two objects have same year and month
// day and time don't matter
  static bool sameMonth(DateTime dateTimeOne, DateTime dateTimeTwo) {
    return dateTimeOne.year == dateTimeTwo.year &&
        dateTimeOne.month == dateTimeTwo.month;
  }


  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _daysInMonth = const <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];


  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    return _daysInMonth[month - 1];
  }


  /// Returns number of months between [startDate] and [endDate]
  static int monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }


  /// Add months to a month truncated date.
  static DateTime addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    // year is switched automatically if new month > 12
    return DateTime(monthDate.year, monthDate.month + monthsToAdd);
  }


  /// Returns number of years between [startDate] and [endDate]
  static int yearDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year);
  }


  // firstDayIndex is from 0 to 6 where 0 points to Sunday and 6 points to Saturday
  // (according to MaterialLocalization.firstDayIfWeekIndex)
  static DateTime getFirstDayOfWeek(DateTime day, int firstDayIndex) {
    // from 1 to 7 where 1 points to Monday and 7 points to Sunday
    int weekday = day.weekday;

    // to match weekdays where Sunday is 7 not 0
    if (firstDayIndex == 0) firstDayIndex = 7;

    int diff = weekday - firstDayIndex;
    if (diff < 0) diff = 7 + diff;

    DateTime firstDayOfWeek = day.subtract(Duration(days: diff));
    firstDayOfWeek =
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
    return firstDayOfWeek;
  }

  // firstDayIndex is from 0 to 6 where 0 points to Sunday and 6 points to Saturday
  // (according to MaterialLocalization.firstDayIfWeekIndex)
  static DateTime getLastDayOfWeek(DateTime day, int firstDayIndex) {
    // from 1 to 7 where 1 points to Monday and 7 points to Sunday
    int weekday = day.weekday;

    // to match weekdays where Sunday is 7 not 0
    if (firstDayIndex == 0) firstDayIndex = 7;

    int lastDayIndex = firstDayIndex - 1;
    if (lastDayIndex == 0) lastDayIndex = 7;

    int diff = lastDayIndex - weekday;
    if (diff < 0) diff = 7 + diff;

    DateTime lastDayOfWeek = day.add(Duration(days: diff));
    lastDayOfWeek = DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day + 1).subtract(Duration(milliseconds: 1));
    return lastDayOfWeek;
  }

}
