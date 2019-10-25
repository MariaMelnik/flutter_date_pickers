import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_date_pickers/src/date_picker_mixin.dart';
import 'package:flutter_date_pickers/src/day_type.dart';
import 'package:flutter_date_pickers/src/event_decoration.dart';
import 'package:flutter_date_pickers/src/i_selectable_picker.dart';
import 'package:flutter_date_pickers/src/utils.dart';

/// Widget for date pickers based on days and cover entire month.
/// Each cell of this picker is day.
class DayBasedPicker<T> extends StatelessWidget with CommonDatePickerFunctions{
  final ISelectablePicker selectablePicker;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

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

  /// Styles what can be customized by user
  final DatePickerRangeStyles datePickerStyles;

  /// Builder to get event decoration for each date.
  ///
  /// All event styles are overriden by selected styles
  /// except days with dayType is [DayType.notSelected].
  final EventDecorationBuilder eventDecorationBuilder;

  /// Creates a week picker.
  DayBasedPicker(
      {Key key,
        @required this.currentDate,
        @required this.firstDate,
        @required this.lastDate,
        @required this.displayedMonth,
        @required this.datePickerLayoutSettings,
        @required this.selectedPeriodKey,
        @required this.datePickerStyles,
        @required this.selectablePicker,
        this.eventDecorationBuilder
      })
      : assert(currentDate != null),
        assert(displayedMonth != null),
        assert(datePickerLayoutSettings != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectablePicker != null),
        assert(datePickerLayoutSettings != null),
        assert(datePickerStyles != null),
        super(key: key);


  // returns decoration for selected date with applied border radius if it needs for passed date
  BoxDecoration _getSelectedDecoration(DayType dayType) {

    BoxDecoration result;

    if (dayType == DayType.single) {
      result = datePickerStyles.selectedSingleDateDecoration;
    } else if (dayType == DayType.start) {
      result = datePickerStyles.selectedPeriodStartDecoration;
    } else if (dayType == DayType.end) {
      result = datePickerStyles.selectedPeriodLastDecoration;
    } else {
      result = datePickerStyles.selectedPeriodMiddleDecoration;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = DatePickerUtils.getDaysInMonth(year, month);
    final int firstDayOffset = computeFirstDayOffset(year, month, localizations);

    final List<Widget> labels = <Widget>[];
    labels.addAll(getDayHeaders(themeData.textTheme.caption, localizations));

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

        DayType dayType = selectablePicker.getDayType(dayToBuild);

        BoxDecoration decoration;
        TextStyle itemStyle;

        if (dayType != DayType.disabled && dayType != DayType.notSelected) {
          // The selected day gets a circle background highlight, and a contrasting text color by default.
          itemStyle = datePickerStyles?.selectedDateStyle;
          decoration = _getSelectedDecoration(dayType);
        } else if (dayType == DayType.disabled) {
          itemStyle = datePickerStyles.disabledDateStyle;
        } else if (DatePickerUtils.sameDate(currentDate, dayToBuild)) {
          // The current day gets a different text color.
          itemStyle = datePickerStyles.currentDateStyle;
        } else {
          itemStyle = datePickerStyles.defaultDateTextStyle;
        }

        // Checks do we need to merge decoration and textStyle with [EventDecoration].
        // Merge only in cases if [dayType] is DayType.notSelected.
        // If day is current day it is also gets event decoration instead of decoration for current date.
        if (dayType == DayType.notSelected && eventDecorationBuilder != null) {
          EventDecoration eDecoration = eventDecorationBuilder(dayToBuild);
          decoration = eDecoration?.boxDecoration ?? decoration;
          itemStyle = eDecoration?.textStyle ?? itemStyle;
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
              selected: dayType != DayType.disabled && dayType != DayType.notSelected,
              child: ExcludeSemantics(
                child: Text(localizations.formatDecimal(day), style: itemStyle),
              ),
            ),
          ),
        );

        if (dayType != DayType.disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => selectablePicker.onDayTapped(dayToBuild),
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
