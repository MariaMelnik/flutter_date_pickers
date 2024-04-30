import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'date_picker_keys.dart';
import 'day_type.dart';
import 'i_selectable_picker.dart';
import 'semantic_sorting.dart';
import 'styles/date_picker_styles.dart';
import 'styles/layout_settings.dart';
import 'utils.dart';
import 'year_picker_selection.dart';

const Locale _defaultLocale = Locale('en', 'US');

/// Year picker widget.
class YearPicker<T extends Object> extends StatefulWidget {
  YearPicker._({
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
            !selection.isBefore(firstDate),
            'Selection must not be before first date. '
            'Earliest selection is: ${selection.earliest}. '
            'First date is: $firstDate'),
        assert(
            !selection.isAfter(lastDate),
            'Selection must not be after last date. '
            'Latest selection is: ${selection.latest}. '
            'First date is: $lastDate'),
        super(key: key);

  /// Creates a year picker where only one single year can be selected.
  ///
  /// See also:
  /// * [YearPicker.multi] - year picker where many single years
  ///   can be selected.
  static YearPicker<DateTime> single(
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
      ValueChanged<DateTime>? onYearChanged}) {
    assert(!firstDate.isAfter(lastDate));
    assert(!lastDate.isBefore(firstDate));
    assert(selectedDate.year >= firstDate.year);
    assert(selectedDate.year <= lastDate.year);

    selectedDate = selectedDate.toFirstOfYear();
    firstDate = firstDate.toFirstOfYear();
    lastDate = lastDate.toFirstOfYear();

    final selection = YearPickerSingleSelection(selectedDate);
    final selectionLogic = MonthSelectable(
        selectedDate, firstDate.toFirstOfYear(), lastDate.toFirstOfYear(),
        selectableDayPredicate: selectableDayPredicate);

    return YearPicker<DateTime>._(
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

  /// Creates a year picker where many single years can be selected.
  ///
  /// See also:
  /// * [YearPicker.single] - year picker where only one single year
  /// can be selected.
  static YearPicker<List<DateTime>> multi(
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
      ValueChanged<DateTime>? onYearChanged}) {
    assert(!firstDate.isAfter(lastDate));
    assert(!lastDate.isBefore(firstDate));

    firstDate = firstDate.toFirstOfYear();
    lastDate = lastDate.toFirstOfYear();
    selectedDates = selectedDates.map((e) => e.toFirstOfYear()).toList();

    final selection = YearPickerMultiSelection(selectedDates);
    final selectionLogic = MonthMultiSelectable(
        selectedDates, firstDate, lastDate,
        selectableDayPredicate: selectableDayPredicate);

    return YearPicker<List<DateTime>>._(
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
  final YearPickerSelection selection;

  /// Called when the user picks a year.
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
  State<StatefulWidget> createState() => _YearPickerState<T>();
}

class _YearPickerState<T extends Object> extends State<YearPicker<T>> {
  PageController _yearPickerController = PageController();

  Locale locale = _defaultLocale;
  MaterialLocalizations localizations = _defaultLocalizations;

  TextDirection textDirection = TextDirection.ltr;

  DateTime _todayDate = DateTime.now();

  DateTimeRange? _previousYearRange;
  DateTimeRange? _nextYearRange;
  late DateTimeRange _currentDisplayedYearRange;

  final List<DateTimeRange> _yearRanges = [];

  Timer? _timer;
  StreamSubscription<T>? _changesSubscription;

  /// True if the earliest allowable year is displayed.
  bool get _isDisplayingFirstYearRange =>
      _currentDisplayedYearRange == _yearRanges.first;

  /// True if the latest allowable year is displayed.
  bool get _isDisplayingLastYearRange =>
      _currentDisplayedYearRange == _yearRanges.last;

  @override
  void initState() {
    super.initState();
    _initWidgetData();
    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(YearPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection != oldWidget.selection ||
        widget.selectionLogic != oldWidget.selectionLogic) {
      _initWidgetData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    locale = Localizations.localeOf(context);

    MaterialLocalizations? curLocalizations =
        Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
    if (curLocalizations != null && localizations != curLocalizations) {
      localizations = curLocalizations;
    }

    textDirection = Directionality.of(context);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.datePickerLayoutSettings.yearPickerPortraitWidth,
        height: widget.datePickerLayoutSettings.maxDayPickerHeight,
        child: Stack(
          children: <Widget>[
            Semantics(
              sortKey: YearPickerSortKey.calendar,
              child: PageView.builder(
                // key: ValueKey<DateTime>(widget.selection),
                controller: _yearPickerController,
                scrollDirection: Axis.horizontal,
                itemCount: _yearRanges.length,
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
                  tooltip: _isDisplayingFirstYearRange
                      ? null
                      : localizations.getRangeYearText(_previousYearRange!),
                  onPressed:
                      _isDisplayingFirstYearRange ? null : _handlePreviousYears,
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
                  tooltip: _isDisplayingLastYearRange
                      ? null
                      : localizations.getRangeYearText(_nextYearRange!),
                  onPressed:
                      _isDisplayingLastYearRange ? null : _handleNextYears,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _timer?.cancel();
    _changesSubscription?.cancel();
    super.dispose();
  }

  void _initWidgetData() {
    final initiallyShowDate = widget.selection.earliest;

    // calculate year per page 12
    int yearsCount =
        DatePickerUtils.yearDelta(widget.firstDate, widget.lastDate);
    const int yearsPerPage = 12;
    int pageCount = (yearsCount / yearsPerPage).ceil();
    for (int i = 0; i < pageCount; i++) {
      final DateTime fromDate =
          DateTime(widget.firstDate.year + i * (yearsPerPage - 1));
      DateTime toDate = DateTime(fromDate.year + (yearsPerPage - 1));

      _yearRanges.add(DateTimeRange(
        start: fromDate,
        end: toDate,
      ));
    }

    final int initialPage = _yearRanges.indexWhere((range) =>
        range.start.year <= initiallyShowDate.year &&
        range.end.year >= initiallyShowDate.year);

    _changesSubscription?.cancel();
    _changesSubscription = widget.selectionLogic.onUpdate
        .listen((newSelectedDate) => widget.onChanged(newSelectedDate))
      ..onError((e) => print(e.toString()));

    _yearPickerController.dispose();
    _yearPickerController = PageController(initialPage: initialPage);
    _handleYearPageChanged(initialPage);
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

  Widget _buildItems(BuildContext context, int index) {
    final DateTimeRange yearRange = _yearRanges[index];

    final ThemeData theme = Theme.of(context);
    DatePickerStyles styles = widget.datePickerStyles;
    styles = styles.fulfillWithTheme(theme);

    return _YearPicker<T>(
      key: ValueKey<DateTime>(yearRange.start),
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: yearRange.start,
      lastDate: yearRange.end,
      datePickerLayoutSettings: widget.datePickerLayoutSettings,
      selectedPeriodKey: widget.datePickerKeys?.selectedPeriodKeys,
      datePickerStyles: styles,
      locale: locale,
      localizations: localizations,
      selectionLogic: widget.selectionLogic,
    );
  }

  void _handleNextYears() {
    if (!_isDisplayingLastYearRange) {
      String yearStr = localizations.getRangeYearText(_nextYearRange!);
      SemanticsService.announce(yearStr, textDirection);
      _yearPickerController.nextPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handlePreviousYears() {
    if (!_isDisplayingFirstYearRange) {
      String yearStr = localizations.getRangeYearText(_previousYearRange!);
      SemanticsService.announce(yearStr, textDirection);
      _yearPickerController.previousPage(
          duration: widget.datePickerLayoutSettings.pagesScrollDuration,
          curve: Curves.ease);
    }
  }

  void _handleYearPageChanged(int yearPage) {
    setState(() {
      _previousYearRange = yearPage == 0 ? null : _yearRanges[yearPage - 1];
      _currentDisplayedYearRange = _yearRanges[yearPage];
      _nextYearRange =
          _yearRanges.length > yearPage + 1 ? _yearRanges[yearPage + 1] : null;
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

class _YearPicker<T> extends StatelessWidget {
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

  ///  Key fo selected year (useful for integration tests)
  final Key? selectedPeriodKey;

  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;

  final MaterialLocalizations localizations;

  final ISelectablePicker<T> selectionLogic;

  final Locale locale;

  _YearPicker(
      {required this.firstDate,
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
    int yearsCount = DatePickerUtils.yearDelta(firstDate, lastDate);

    final List<Widget> labels = <Widget>[];

    for (int year = 0; year <= yearsCount; year += 1) {
      DateTime yearToBuild = DateTime(firstDate.year + year, 1, 1);
      DayType monthType = selectionLogic.getDayType(yearToBuild);

      Widget monthWidget = _YearCell(
        yearToBuild: yearToBuild,
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
            DatePickerUtils.sameMonth(firstDate, yearToBuild)
                ? selectionLogic.onDayTapped(firstDate)
                : selectionLogic.onDayTapped(yearToBuild);
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
          SizedBox(
            height: datePickerLayoutSettings.dayPickerRowHeight,
            child: Center(
              child: ExcludeSemantics(
                child: Text(
                  localizations.getRangeYearText(
                    DateTimeRange(start: firstDate, end: lastDate),
                  ),
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

/// Returns 2021 - 2022
extension FormatYearDateRange on MaterialLocalizations {
  /// extension method for formatting date range
  String getRangeYearText(DateTimeRange dateRange) =>
      "${formatYear(dateRange.start)} - ${formatYear(dateRange.end)}";
}

/// Extension for DateTime
extension FirstDayOfYear on DateTime {
  /// Return 1 January of the year
  DateTime toFirstOfYear() => DateTime(year);
}

class _YearCell<T> extends StatelessWidget {
  /// Styles what can be customized by user
  final DatePickerStyles datePickerStyles;
  final Locale locale;
  final MaterialLocalizations localizations;
  final ISelectablePicker<T> selectionLogic;
  final DateTime yearToBuild;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  const _YearCell({
    required this.yearToBuild,
    required this.currentDate,
    required this.selectionLogic,
    required this.datePickerStyles,
    required this.locale,
    required this.localizations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DayType yearType = selectionLogic.getDayType(yearToBuild);

    BoxDecoration? decoration;
    TextStyle? itemStyle;

    if (yearType != DayType.disabled && yearType != DayType.notSelected) {
      itemStyle = datePickerStyles.selectedDateStyle;
      decoration = datePickerStyles.selectedSingleDateDecoration;
    } else if (yearType == DayType.disabled) {
      itemStyle = datePickerStyles.disabledDateStyle;
    } else if (DatePickerUtils.sameMonth(currentDate, yearToBuild)) {
      itemStyle = datePickerStyles.currentDateStyle;
    } else {
      itemStyle = datePickerStyles.defaultDateTextStyle;
    }

    String semanticLabel = '${localizations.formatDecimal(yearToBuild.month)}, '
        '${localizations.formatFullDate(yearToBuild)}';

    bool isSelectedYear =
        yearType != DayType.disabled && yearType != DayType.notSelected;

    String yearStr = _getYearStr(yearToBuild);

    Widget yearWidget = Container(
      decoration: decoration,
      child: Center(
        child: Semantics(
          // We want the day of year to be spoken first irrespective of the
          // locale-specific preferences or TextDirection. This is because
          // an accessibility user is more likely to be interested in the
          // day of year before the rest of the date, as they are looking
          // for the day of year. To do that we prepend day of year to the
          // formatted full date.
          label: semanticLabel,
          selected: isSelectedYear,
          child: ExcludeSemantics(
            child: Text(yearStr, style: itemStyle),
          ),
        ),
      ),
    );

    return yearWidget;
  }

  // Returns only year made with intl.DateFormat.MMM() for current [locale].
  // We can'r use [localizations] here because MaterialLocalizations doesn't
  // provide short year string.
  String _getYearStr(DateTime date) => localizations.formatYear(date);
}
