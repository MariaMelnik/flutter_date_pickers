import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'date_picker_keys.dart';
import 'day_type.dart';
import 'i_selectable_picker.dart';
import 'month_picker_selection.dart';
import 'semantic_sorting.dart';
import 'styles/date_picker_styles.dart';
import 'styles/layout_settings.dart';
import 'utils.dart';

const Locale _defaultLocale = Locale('en', 'US');

/// Month picker widget.
class MonthPicker<T extends Object> extends StatefulWidget {
  MonthPicker._({
    Key? key,
    required this.selectionLogic,
    required this.selection,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.datePickerLayoutSettings = const DatePickerLayoutSettings(),
    this.datePickerKeys,
    required this.datePickerStyles,
  })  : assert(!firstDate.isAfter(lastDate)),
        assert(
            selection.isEmpty || !selection.isBefore(firstDate),
            'Selection must not be before first date. '
            'Earliest selection is: ${selection.earliest}. '
            'First date is: $firstDate'),
        assert(
            selection.isEmpty || !selection.isAfter(lastDate),
            'Selection must not be after last date. '
            'Latest selection is: ${selection.latest}. '
            'First date is: $lastDate'),
        super(key: key);

  /// Creates a month picker where only one single month can be selected.
  ///
  /// See also:
  /// * [MonthPicker.multi] - month picker where many single months
  ///   can be selected.
  static MonthPicker<DateTime> single(
      {Key? key,
      required DateTime selectedDate,
      required ValueChanged<DateTime> onChanged,
      required DateTime firstDate,
      required DateTime lastDate,
      DatePickerLayoutSettings datePickerLayoutSettings =
          const DatePickerLayoutSettings(),
      DatePickerStyles? datePickerStyles,
      DatePickerKeys? datePickerKeys,
      SelectableDayPredicate? selectableDayPredicate,
      ValueChanged<DateTime>? onMonthChanged}) {
    assert(!firstDate.isAfter(lastDate));
    assert(!lastDate.isBefore(firstDate));
    assert(!selectedDate.isBefore(firstDate));
    assert(!selectedDate.isAfter(lastDate));

    final selection = MonthPickerSingleSelection(selectedDate);
    final selectionLogic = MonthSelectable(selectedDate, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return MonthPicker<DateTime>._(
      onChanged: onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      selectionLogic: selectionLogic,
      selection: selection,
      datePickerKeys: datePickerKeys,
      datePickerStyles: datePickerStyles ?? DatePickerRangeStyles(),
      datePickerLayoutSettings: datePickerLayoutSettings,
    );
  }

  /// Creates a month picker where many single months can be selected.
  ///
  /// See also:
  /// * [MonthPicker.single] - month picker where only one single month
  /// can be selected.
  static MonthPicker<List<DateTime>> multi(
      {Key? key,
      required List<DateTime> selectedDates,
      required ValueChanged<List<DateTime>> onChanged,
      required DateTime firstDate,
      required DateTime lastDate,
      DatePickerLayoutSettings datePickerLayoutSettings =
          const DatePickerLayoutSettings(),
      DatePickerStyles? datePickerStyles,
      DatePickerKeys? datePickerKeys,
      SelectableDayPredicate? selectableDayPredicate,
      ValueChanged<DateTime>? onMonthChanged}) {
    assert(!firstDate.isAfter(lastDate));
    assert(!lastDate.isBefore(firstDate));

    final selection = MonthPickerMultiSelection(selectedDates);
    final selectionLogic = MonthMultiSelectable(
        selectedDates, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return MonthPicker<List<DateTime>>._(
      onChanged: onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      selectionLogic: selectionLogic,
      selection: selection,
      datePickerKeys: datePickerKeys,
      datePickerStyles: datePickerStyles ?? DatePickerStyles(),
      datePickerLayoutSettings: datePickerLayoutSettings,
    );
  }

  /// The currently selected date or dates.
  ///
  /// This date or dates are highlighted in the picker.
  final MonthPickerSelection selection;

  /// Called when the user picks a month.
  final ValueChanged<T> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Some keys useful for integration tests
  final DatePickerKeys? datePickerKeys;

  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;

  /// Logic to handle user's selections.
  final ISelectablePicker<T> selectionLogic;

  @override
  State<StatefulWidget> createState() => _MonthPickerState<T>();
}

class _MonthPickerState<T extends Object> extends State<MonthPicker<T>> {
  PageController _monthPickerController = PageController();

  Locale locale = _defaultLocale;
  MaterialLocalizations localizations = _defaultLocalizations;

  TextDirection textDirection = TextDirection.ltr;

  DateTime _todayDate = DateTime.now();
  DateTime _previousYearDate = DateTime(DateTime.now().year - 1);
  DateTime _nextYearDate = DateTime(DateTime.now().year + 1);

  DateTime _currentDisplayedYearDate = DateTime.now();

  Timer? _timer;
  StreamSubscription<T>? _changesSubscription;

  /// True if the earliest allowable year is displayed.
  bool get _isDisplayingFirstYear =>
      !_currentDisplayedYearDate.isAfter(DateTime(widget.firstDate.year));

  /// True if the latest allowable year is displayed.
  bool get _isDisplayingLastYear =>
      !_currentDisplayedYearDate.isBefore(DateTime(widget.lastDate.year));

  @override
  void initState() {
    super.initState();
    _initWidgetData();
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(MonthPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection != oldWidget.selection ||
        widget.selectionLogic != oldWidget.selectionLogic) {
      _initWidgetData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      locale = Localizations.localeOf(context);

      MaterialLocalizations? curLocalizations =
          Localizations.of<MaterialLocalizations>(
              context, MaterialLocalizations);
      if (curLocalizations != null && localizations != curLocalizations) {
        localizations = curLocalizations;
      }

      textDirection = Directionality.of(context);

      // No MaterialLocalizations or Directionality or Locale was found
      // and ".of" method throws error
      // trying to cast null to MaterialLocalizations.
    } on TypeError catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    int yearsCount =
        DatePickerUtils.yearDelta(widget.firstDate, widget.lastDate) + 1;

    return SizedBox(
      width: widget.datePickerLayoutSettings.monthPickerPortraitWidth,
      height: widget.datePickerLayoutSettings.maxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: YearPickerSortKey.calendar,
            child: PageView.builder(
              // key: ValueKey<DateTime>(widget.selection),
              controller: _monthPickerController,
              scrollDirection: Axis.horizontal,
              itemCount: yearsCount,
              itemBuilder: _buildItems,
              onPageChanged: _handleYearPageChanged,
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: YearPickerSortKey.previousYear,
              child: IconButton(
                key: widget.datePickerKeys?.previousPageIconKey,
                icon: widget.datePickerStyles.prevIcon,
                tooltip: _isDisplayingFirstYear
                    ? null
                    : '${localizations.formatYear(_previousYearDate)}',
                onPressed: _isDisplayingFirstYear ? null : _handlePreviousYear,
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: YearPickerSortKey.nextYear,
              child: IconButton(
                key: widget.datePickerKeys?.nextPageIconKey,
                icon: widget.datePickerStyles.nextIcon,
                tooltip: _isDisplayingLastYear
                    ? null
                    : '${localizations.formatYear(_nextYearDate)}',
                onPressed: _isDisplayingLastYear ? null : _handleNextYear,
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
    _changesSubscription?.cancel();
    super.dispose();
  }

  void _initWidgetData() {
    final initiallyShowDate =
        widget.selection.isEmpty ? DateTime.now() : widget.selection.earliest;

    // Initially display the pre-selected date.
    final int yearPage =
        DatePickerUtils.yearDelta(widget.firstDate, initiallyShowDate);

    _changesSubscription?.cancel();
    _changesSubscription = widget.selectionLogic.onUpdate
        .listen((newSelectedDate) => widget.onChanged(newSelectedDate))
      ..onError((e) => print(e.toString()));

    _monthPickerController.dispose();
    _monthPickerController = PageController(initialPage: yearPage);
    _handleYearPageChanged(yearPage);
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
      setState(_updateCurrentDate);
    });
  }

  /// Add years to a year truncated date.
  DateTime _addYearsToYearDate(DateTime yearDate, int yearsToAdd) =>
      DateTime(yearDate.year + yearsToAdd);

  Widget _buildItems(BuildContext context, int index) {
    final DateTime year = _addYearsToYearDate(widget.firstDate, index);

    final ThemeData theme = Theme.of(context);
    DatePickerStyles styles = widget.datePickerStyles;
    styles = styles.fulfillWithTheme(theme);

    return _MonthPicker<T>(
      key: ValueKey<DateTime>(year),
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      datePickerLayoutSettings: widget.datePickerLayoutSettings,
      displayedYear: year,
      selectedPeriodKey: widget.datePickerKeys?.selectedPeriodKeys,
      datePickerStyles: styles,
      locale: locale,
      localizations: localizations,
      selectionLogic: widget.selectionLogic,
    );
  }

  void _handleNextYear() {
    if (!_isDisplayingLastYear) {
      String yearStr = localizations.formatYear(_nextYearDate);
      SemanticsService.announce(yearStr, textDirection);
      _monthPickerController.nextPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handlePreviousYear() {
    if (!_isDisplayingFirstYear) {
      String yearStr = localizations.formatYear(_previousYearDate);
      SemanticsService.announce(yearStr, textDirection);
      _monthPickerController.previousPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handleYearPageChanged(int yearPage) {
    setState(() {
      _previousYearDate = _addYearsToYearDate(widget.firstDate, yearPage - 1);
      _currentDisplayedYearDate =
          _addYearsToYearDate(widget.firstDate, yearPage);
      _nextYearDate = _addYearsToYearDate(widget.firstDate, yearPage + 1);
    });
  }

  static MaterialLocalizations get _defaultLocalizations =>
      MaterialLocalizationEn(
        twoDigitZeroPaddedFormat:
            intl.NumberFormat('00', _defaultLocale.toString()),
        fullYearFormat: intl.DateFormat.y(_defaultLocale.toString()),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(_defaultLocale.toString()),
        shortMonthDayFormat: intl.DateFormat.MMMd(_defaultLocale.toString()),
        decimalFormat:
            intl.NumberFormat.decimalPattern(_defaultLocale.toString()),
        shortDateFormat: intl.DateFormat.yMMMd(_defaultLocale.toString()),
        mediumDateFormat: intl.DateFormat.MMMEd(_defaultLocale.toString()),
        compactDateFormat: intl.DateFormat.yMd(_defaultLocale.toString()),
        yearMonthFormat: intl.DateFormat.yMMMM(_defaultLocale.toString()),
      );
}

class _MonthPicker<T> extends StatelessWidget {
  /// The month whose days are displayed by this picker.
  final DateTime displayedYear;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Layout settings what can be customized by user
  final DatePickerLayoutSettings datePickerLayoutSettings;

  /// Called when the user picks a day.
  final ValueChanged<T> onChanged;

  ///  Key fo selected month (useful for integration tests)
  final Key? selectedPeriodKey;

  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;

  final MaterialLocalizations localizations;

  final ISelectablePicker<T> selectionLogic;

  final Locale locale;

  _MonthPicker(
      {required this.displayedYear,
      required this.firstDate,
      required this.lastDate,
      required this.currentDate,
      required this.onChanged,
      required this.datePickerLayoutSettings,
      required this.datePickerStyles,
      required this.selectionLogic,
      required this.localizations,
      required this.locale,
      this.selectedPeriodKey,
      Key? key})
      : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final int monthsInYear = 12;
    final int year = displayedYear.year;
    final int day = 1;

    final List<Widget> labels = <Widget>[];

    for (int month = 1; month <= monthsInYear; month += 1) {
      DateTime monthToBuild = DateTime(year, month, day);
      DayType monthType = selectionLogic.getDayType(monthToBuild);

      Widget monthWidget = _MonthCell(
        monthToBuild: monthToBuild,
        currentDate: currentDate,
        selectionLogic: selectionLogic,
        datePickerStyles: datePickerStyles,
        localizations: localizations,
        locale: locale,
      );

      if (monthType != DayType.disabled) {
        monthWidget = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            DatePickerUtils.sameMonth(firstDate, monthToBuild)
                ? selectionLogic.onDayTapped(firstDate)
                : selectionLogic.onDayTapped(monthToBuild);
          },
          child: monthWidget,
        );
      }

      labels.add(monthWidget);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Container(
            height: datePickerLayoutSettings.dayPickerRowHeight,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  localizations.formatYear(displayedYear),
                  key: selectedPeriodKey,
                  style: datePickerStyles.displayedPeriodTitle,
                ),
              ),
            ),
          ),
          Flexible(
            child: GridView.count(
              physics: datePickerLayoutSettings.scrollPhysics,
              crossAxisCount: 4,
              children: labels,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCell<T> extends StatelessWidget {
  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;
  final Locale locale;
  final MaterialLocalizations localizations;
  final ISelectablePicker<T> selectionLogic;
  final DateTime monthToBuild;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  const _MonthCell({
    required this.monthToBuild,
    required this.currentDate,
    required this.selectionLogic,
    required this.datePickerStyles,
    required this.locale,
    required this.localizations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DayType monthType = selectionLogic.getDayType(monthToBuild);

    BoxDecoration? decoration;
    TextStyle? itemStyle;

    if (monthType != DayType.disabled && monthType != DayType.notSelected) {
      itemStyle = datePickerStyles.selectedDateStyle;
      decoration = datePickerStyles.selectedSingleDateDecoration;
    } else if (monthType == DayType.disabled) {
      itemStyle = datePickerStyles.disabledDateStyle;
    } else if (DatePickerUtils.sameMonth(currentDate, monthToBuild)) {
      itemStyle = datePickerStyles.currentDateStyle;
    } else {
      itemStyle = datePickerStyles.defaultDateTextStyle;
    }

    String semanticLabel =
        '${localizations.formatDecimal(monthToBuild.month)}, '
        '${localizations.formatFullDate(monthToBuild)}';

    bool isSelectedMonth =
        monthType != DayType.disabled && monthType != DayType.notSelected;

    String monthStr = _getMonthStr(monthToBuild);

    Widget monthWidget = Container(
      decoration: decoration,
      child: Center(
        child: Semantics(
          // We want the day of month to be spoken first irrespective of the
          // locale-specific preferences or TextDirection. This is because
          // an accessibility user is more likely to be interested in the
          // day of month before the rest of the date, as they are looking
          // for the day of month. To do that we prepend day of month to the
          // formatted full date.
          label: semanticLabel,
          selected: isSelectedMonth,
          child: ExcludeSemantics(
            child: Text(monthStr, style: itemStyle),
          ),
        ),
      ),
    );

    return monthWidget;
  }

  // Returns only month made with intl.DateFormat.MMM() for current [locale].
  // We can'r use [localizations] here because MaterialLocalizations doesn't
  // provide short month string.
  String _getMonthStr(DateTime date) {
    String month = intl.DateFormat.MMM(locale.toString()).format(date);
    return month;
  }
}
