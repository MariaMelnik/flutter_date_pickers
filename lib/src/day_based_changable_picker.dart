import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/basic_day_based_widget.dart';
import 'package:flutter_date_pickers/src/day_based_changeable_picker_presenter.dart';
import 'package:flutter_date_pickers/src/event_decoration.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/month_navigation_row.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';
import 'package:flutter_date_pickers/src/typedefs.dart';
import 'package:flutter_date_pickers/src/utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils.dart';

/// Date picker based on [DayBasedPicker] picker (for days, weeks, ranges).
/// Allows select previous/next month.
class DayBasedChangeablePicker<T> extends StatefulWidget {
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
  final ISelectablePicker<T> selectablePicker;

  /// Builder to get event decoration for each date.
  ///
  /// All event styles are overridden by selected styles
  /// except days with dayType is [DayType.notSelected].
  final EventDecorationBuilder eventDecorationBuilder;

  /// Called when the user changes the month
  final ValueChanged<DateTime> onMonthChanged;

  const DayBasedChangeablePicker(
      {Key key,
      this.selectedDate,
      this.onChanged,
      @required this.firstDate,
      @required this.lastDate,
      @required this.datePickerLayoutSettings,
      @required this.datePickerStyles,
      @required this.selectablePicker,
      this.datePickerKeys,
      this.onSelectionError,
      this.eventDecorationBuilder,
      this.onMonthChanged})
      : assert(datePickerLayoutSettings != null),
        assert(datePickerStyles != null),
        super(key: key);

  @override
  State<DayBasedChangeablePicker<T>> createState() =>
      _DayBasedChangeablePickerState<T>();
}

// todo: Check initial selection and call onSelectionError in case it has error (ISelectablePicker.curSelectionIsCorrupted);
class _DayBasedChangeablePickerState<T>
    extends State<DayBasedChangeablePicker<T>> {
  MaterialLocalizations localizations;
  Locale curLocale;
  TextDirection textDirection;

  DateTime _todayDate;

  // Styles from widget fulfilled with current Theme.
  DatePickerStyles _resultStyles;
  Timer _timer;
  PageController _dayPickerController;
  StreamSubscription<T> _changesSubscription;
  DayBasedChangeablePickerPresenter _presenter;

  @override
  void initState() {
    super.initState();

    // Initially display the pre-selected date.
    final int monthPage =
        DatePickerUtils.monthDelta(widget.firstDate, widget.selectedDate);
    _dayPickerController = PageController(initialPage: monthPage);

    _dayPickerController.addListener(() {
      if (widget.onMonthChanged != null) {
        if (_dayPickerController.page.round() == _dayPickerController.page) {
          widget.onMonthChanged(
            DatePickerUtils.addMonthsToMonthDate(
              DateTime(widget.firstDate.year, widget.firstDate.month),
              _dayPickerController.page.round(),
            ),
          );
        }
      }
    });

    _changesSubscription = widget.selectablePicker.onUpdate
        .listen((newSelectedDate) => widget.onChanged?.call(newSelectedDate))
          ..onError((e) => widget.onSelectionError != null
              ? widget.onSelectionError(e)
              : print(e.toString()));

    // Give information about initial selection to presenter.
    // It should be done after first frame when PageView is already created.
    // Otherwise event from presenter will cause a error.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _presenter.setSelectedData(widget.selectedDate);
    });

    _updateCurrentDate();
  }

  @override
  void didUpdateWidget(DayBasedChangeablePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != oldWidget.selectedDate) {
      _presenter.setSelectedData(widget.selectedDate);
    }

    if (widget.datePickerStyles != oldWidget.datePickerStyles) {
      final ThemeData theme = Theme.of(context);
      _resultStyles = widget.datePickerStyles.fulfillWithTheme(theme);
    }

    if (widget.selectablePicker != oldWidget.selectablePicker) {
      _changesSubscription = widget.selectablePicker.onUpdate
          .listen((newSelectedDate) => widget.onChanged?.call(newSelectedDate))
            ..onError((e) => widget.onSelectionError != null
                ? widget.onSelectionError(e)
                : print(e.toString()));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    curLocale = Localizations.localeOf(context);
    textDirection = Directionality.of(context);

    MaterialLocalizations newLocalizations = MaterialLocalizations.of(context);
    if (newLocalizations != localizations) {
      localizations = newLocalizations;
      _initPresenter();
    }

    final ThemeData theme = Theme.of(context);
    _resultStyles = widget.datePickerStyles.fulfillWithTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: curLocale,
      delegates: GlobalMaterialLocalizations.delegates,
      child: Builder(
        builder: (c) {
          localizations = MaterialLocalizations.of(c);
          return SizedBox(
            width: widget.datePickerLayoutSettings.monthPickerPortraitWidth,
            height: widget.datePickerLayoutSettings.maxDayPickerHeight,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: widget.datePickerLayoutSettings.dayPickerRowHeight,
                  child: Padding(
                      padding: widget.datePickerLayoutSettings
                          .contentPadding, //match _DayPicker main layout padding
                      child: _buildMonthNavigationRow()),
                ),
                Expanded(
                  child: Semantics(
                    sortKey: MonthPickerSortKey.calendar,
                    child: _buildDayPickerPageView(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    _changesSubscription.cancel();
    widget.selectablePicker.dispose();
    super.dispose();
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

  Widget _buildMonthNavigationRow() {
    return StreamBuilder<DayBasedChangeablePickerState>(
        stream: _presenter.data,
        initialData: _presenter.lastVal,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          DayBasedChangeablePickerState state = snapshot.data;

          return MonthNavigationRow(
            previousPageIconKey: widget.datePickerKeys?.previousPageIconKey,
            nextPageIconKey: widget.datePickerKeys?.nextPageIconKey,
            previousMonthTooltip: state.prevTooltip,
            nextMonthTooltip: state.nextTooltip,
            onPreviousMonthTapped:
                state.isFirstMonth ? null : _presenter.gotoPrevMonth,
            onNextMonthTapped:
                state.isLastMonth ? null : _presenter.gotoNextMonth,
            title: Text(
              state.curMonthDis,
              key: widget.datePickerKeys?.selectedPeriodKeys,
              style: _resultStyles.displayedPeriodTitle,
            ),
            nextIcon: widget.datePickerStyles.nextIcon,
            prevIcon: widget.datePickerStyles.prevIcon,
          );
        });
  }

  Widget _buildDayPickerPageView() {
    return PageView.builder(
      controller: _dayPickerController,
      scrollDirection: Axis.horizontal,
      itemCount:
          DatePickerUtils.monthDelta(widget.firstDate, widget.lastDate) + 1,
      itemBuilder: _buildCalendar,
      onPageChanged: _handleMonthPageChanged,
    );
  }

  Widget _buildCalendar(BuildContext context, int index) {
    final DateTime targetDate =
        DatePickerUtils.addMonthsToMonthDate(widget.firstDate, index);

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

  void _initPresenter() {
    _presenter = DayBasedChangeablePickerPresenter(
        widget.firstDate,
        widget.lastDate,
        localizations,
        widget.datePickerLayoutSettings.showPrevMonthEnd,
        widget.datePickerLayoutSettings.showNextMonthStart,
        widget.datePickerStyles.firstDayOfeWeekIndex);
    _presenter.data.listen(_onStateChanged);
//    _presenter.setSelectedData(widget.selectedDate);
  }

  void _onStateChanged(DayBasedChangeablePickerState newState) {
    DateTime newMonth = newState.currentMonth;
    final int monthPage =
        DatePickerUtils.monthDelta(widget.firstDate, newMonth);
    _dayPickerController.animateToPage(monthPage,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void _handleMonthPageChanged(int monthPage) {
    DateTime firstMonth = widget.firstDate;
    DateTime newMonth =
        DateTime(firstMonth.year, firstMonth.month + monthPage, firstMonth.day);
    _presenter?.changeMonth(newMonth);
  }
}
