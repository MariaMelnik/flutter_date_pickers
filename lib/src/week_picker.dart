import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_date_pickers/src/date_picker_styles.dart';
import 'package:flutter_date_pickers/src/layout_settings.dart';
import 'package:flutter_date_pickers/src/date_period.dart';
import 'package:flutter_date_pickers/src/date_picker_keys.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';
import 'package:flutter_date_pickers/src/utils.dart';

// Styles for current displayed period (month): Theme.of(context).textTheme.subhead
//
// Styles for date picker cell:
// current date: Theme.of(context).textTheme.body2.copyWith(color: themeData.accentColor)
// if date disabled: Theme.of(context).textTheme.body1.copyWith(color: themeData.disabledColor)
// if date selected:
//  text - Theme.of(context).accentTextTheme.body2
//  for box decoration - color is Theme.of(context).accentColor and box shape is circle

// selectedDate must be between firstDate and lastDate
class WeekPicker extends StatefulWidget {
  /// Creates a month picker.
  WeekPicker(
      {Key key,
      @required this.selectedDate,
      @required this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
      this.datePickerKeys,
      this.datePickerStyles})
      : assert(selectedDate != null),
        assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate)),
        assert(selectedDate.isBefore(lastDate) ||
            selectedDate.isAtSameMomentAs(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a week.
  final ValueChanged<DatePeriod> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Some keys useful for integration tests
  final DatePickerKeys datePickerKeys;

  /// Styles what can be customized by user
  final DatePickerRangeStyles datePickerStyles;

  @override
  _WeekPickerState createState() => _WeekPickerState();
}

class _WeekPickerState extends State<WeekPicker> {
  MaterialLocalizations localizations;
  TextDirection textDirection;
  DateTime _todayDate;
  DateTime _currentDisplayedMonthDate;
  DateTime _previousMonthDate;
  DateTime _nextMonthDate;

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth => !_currentDisplayedMonthDate
      .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth => !_currentDisplayedMonthDate
      .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  Timer _timer;
  PageController _dayPickerController;

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(WeekPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = _monthDelta(widget.firstDate, widget.selectedDate);
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

  static int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    // year is switched automatically if new month > 12
    return DateTime(monthDate.year, monthDate.month + monthsToAdd);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime targetDate = _addMonthsToMonthDate(widget.firstDate, index);
    return _WeekPicker(
      key: ValueKey<DateTime>(targetDate),
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayedMonth: targetDate,
      datePickerLayoutSettings: widget.datePickerLayoutSettings,
      selectedPeriodKey: widget.datePickerKeys?.selectedPeriodKeys,
      firstDayOfWeekIndex: localizations.firstDayOfWeekIndex,
      datePickerStyles: widget.datePickerStyles,
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
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
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
              itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
              itemBuilder: _buildItems,
              onPageChanged: _handleMonthPageChanged,
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: MonthPickerSortKey.previousMonth,
              child: IconButton(
                key: widget.datePickerKeys?.previousPageIconKey,
                icon: const Icon(Icons.chevron_left),
                tooltip: _isDisplayingFirstMonth
                    ? null
                    : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                onPressed:
                    _isDisplayingFirstMonth ? null : _handlePreviousMonth,
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: MonthPickerSortKey.nextMonth,
              child: IconButton(
                key: widget.datePickerKeys?.nextPageIconKey,
                icon: const Icon(Icons.chevron_right),
                tooltip: _isDisplayingLastMonth
                    ? null
                    : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
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
}

class _WeekPicker extends StatelessWidget {
  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime selectedDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final ValueChanged<DatePeriod> onChanged;

  /// The earliest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  /// (only year, month and day matter, time doesn't matter)
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  ///  Key fo selected month (useful for integration tests)
  final Key selectedPeriodKey;

  // according to MaterialLocalization.firstDayOfWeekIndex
  final int firstDayOfWeekIndex;

  /// Styles what can be customized by user
  final DatePickerRangeStyles datePickerStyles;

  final DateTime firstDayOfSelectedWeek;
  final DateTime lastDayOfSelectedWeek;

  /// Creates a week picker.
  _WeekPicker(
      {Key key,
      @required this.selectedDate,
      @required this.currentDate,
      @required this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      @required this.displayedMonth,
      @required this.datePickerLayoutSettings,
      @required this.firstDayOfWeekIndex,
      @required this.selectedPeriodKey,
      @required this.datePickerStyles})
      : assert(selectedDate != null),
        assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(datePickerLayoutSettings != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate)),
        firstDayOfSelectedWeek =
            _getFirstDayOfWeek(selectedDate, firstDayOfWeekIndex),
        lastDayOfSelectedWeek =
            _getLastDayOfWeek(selectedDate, firstDayOfWeekIndex),
        super(key: key);

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(new ExcludeSemantics(
        child: new Center(child: new Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  // firstDayIndex is from 0 to 6 where 0 points to Sunday and 6 points to Saturday
  // (according to MaterialLocalization.firstDayIfWeekIndex)
  static DateTime _getFirstDayOfWeek(DateTime day, int firstDayIndex) {
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
  static DateTime _getLastDayOfWeek(DateTime day, int firstDayIndex) {
    // from 1 to 7 where 1 points to Monday and 7 points to Sunday
    int weekday = day.weekday;

    // to match weekdays where Sunday is 7 not 0
    if (firstDayIndex == 0) firstDayIndex = 7;

    int lastDayIndex = firstDayIndex - 1;
    if (lastDayIndex == 0) lastDayIndex = 7;

    int diff = lastDayIndex - weekday;
    if (diff < 0) diff = 7 + diff;

    DateTime lastDayOfWeek = day.add(Duration(days: diff));
    lastDayOfWeek =
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day);
    return lastDayOfWeek;
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

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = new DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  bool _isDayOfSelectedWeek(DateTime date) {
    return !(date.isBefore(firstDayOfSelectedWeek) ||
        date.isAfter(lastDayOfSelectedWeek));
  }

  // returns decoration for selected date with applied border radius if it needs for passed date
  BoxDecoration _getSelectedDecoration(
      DateTime date, Color defaultAccentColor) {
    assert(_isDayOfSelectedWeek(date));

    BoxDecoration result;

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
      result = datePickerStyles.selectedSingleDateDecoration ??
          BoxDecoration(
            color: defaultAccentColor,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          );
    } else if (DatePickerUtils.sameDate(date, firstDayOfSelectedWeek) ||
        DatePickerUtils.sameDate(date, firstDate)) {
      result = datePickerStyles.selectedPeriodStartDecoration ??
          BoxDecoration(
            color: defaultAccentColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0)),
          );
    } else if (DatePickerUtils.sameDate(date, lastDayOfSelectedWeek) ||
        DatePickerUtils.sameDate(date, lastDate)) {
      result = datePickerStyles.selectedPeriodLastDecoration ??
          BoxDecoration(
            color: defaultAccentColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
          );
    } else {
      result = datePickerStyles.selectedPeriodMiddleDecoration ??
          BoxDecoration(
            color: defaultAccentColor,
            shape: BoxShape.rectangle,
          );
    }

    return result;
  }

// returns new selected period according to tapped date
  DatePeriod _getNewSelectedPeriod(DateTime tappedDay) {
    DatePeriod newPeriod;

    DateTime firstDayOfTappedWeek =
        _getFirstDayOfWeek(tappedDay, firstDayOfWeekIndex);
    DateTime lastDayOfTappedWeek =
        _getLastDayOfWeek(tappedDay, firstDayOfWeekIndex);

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

// returns weather passed day before the beginning of the [firstDay] or after the end of the [lastDay]
  bool _isDisabled(DateTime day) {
    final DateTime beginOfTheFirstDay =
        DateTime(firstDate.year, firstDate.month, firstDate.day);
    final DateTime endOfTheLastDay =
        DateTime(lastDate.year, lastDate.month, lastDate.day + 1)
            .subtract(Duration(microseconds: 1));

    return day.isAfter(endOfTheLastDay) || day.isBefore(beginOfTheFirstDay);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = getDaysInMonth(year, month);
    final int firstDayOffset =
        _computeFirstDayOffset(year, month, localizations);

    final List<Widget> labels = <Widget>[];
    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));

    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        // offset for the first day of month
        labels.add(Container());
      } else {
        DateTime dayToBuild = DateTime(year, month, day);

        // if dayToBuild is the first day we need to save original time for it
        if (DatePickerUtils.sameDate(dayToBuild, firstDate))
          dayToBuild = firstDate;

        // if dayToBuild is the last day we need to save original time for it
        if (DatePickerUtils.sameDate(dayToBuild, lastDate))
          dayToBuild = lastDate;

        final bool disabled = _isDisabled(dayToBuild);
        final bool isSelectedDay =
            _isDayOfSelectedWeek(DateTime(year, month, day)) && !disabled;

        BoxDecoration decoration;
        TextStyle itemStyle;

        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = datePickerStyles?.selectedDateStyle ??
              themeData.accentTextTheme.body2;
          decoration = _getSelectedDecoration(
              DateTime(year, month, day), themeData.accentColor);
        } else if (disabled) {
          itemStyle = datePickerStyles?.disabledDateStyle ??
              themeData.textTheme.body1
                  .copyWith(color: themeData.disabledColor);
        } else if (currentDate.year == year &&
            currentDate.month == month &&
            currentDate.day == day) {
          // The current day gets a different text color.
          itemStyle = datePickerStyles?.currentDateStyle ??
              themeData.textTheme.body2.copyWith(color: themeData.accentColor);
        } else {
          itemStyle = themeData.textTheme.body1;
        }

        Widget dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              child: ExcludeSemantics(
                child: Text(localizations.formatDecimal(day), style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              DatePeriod newPeriod = _getNewSelectedPeriod(dayToBuild);
              onChanged(newPeriod);
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }

    return Padding(
      padding: datePickerLayoutSettings.contentPadding,
      child: Column(
        children: <Widget>[
          Container(
            height: datePickerLayoutSettings.dayPickerRowHeight,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  localizations.formatMonthYear(displayedMonth),
                  key: selectedPeriodKey,
                  style: datePickerStyles?.displayedPeriodTitle ??
                      themeData.textTheme.subhead,
                ),
              ),
            ),
          ),
          Flexible(
            child: GridView.custom(
              gridDelegate: datePickerLayoutSettings.dayPickerGridDelegate,
              childrenDelegate:
                  SliverChildListDelegate(labels, addRepaintBoundaries: false),
            ),
          ),
        ],
      ),
    );
  }
}
