import 'package:flutter/material.dart';

/// Common styles for date pickers.
///
/// To define more styles for date pickers which allow select some range (e.g. [RangePicker], [WeekPicker]) use [DatePickerRangeStyles].
class DatePickerStyles {
  /// Used for title of displayed period (e.g. month for day picker and year for month picker).
  final TextStyle displayedPeriodTitle;

  final TextStyle currentDateStyle;

  final TextStyle disabledDateStyle;

  final TextStyle selectedDateStyle;

  /// Used for date which is neither current nor disabled nor selected.
  final TextStyle defaultDateTextStyle;

  final BoxDecoration selectedSingleDateDecoration;

  const DatePickerStyles(
      {this.displayedPeriodTitle,
      this.currentDateStyle,
      this.disabledDateStyle,
      this.selectedDateStyle,
      this.selectedSingleDateDecoration,
      this.defaultDateTextStyle});

  /// Return new [DatePickerStyles] object where fields with null values set with defaults from passed theme
  DatePickerStyles fulfillWithTheme(ThemeData theme) {
    Color accentColor = theme.accentColor;

    TextStyle _displayedPeriodTitle =
        displayedPeriodTitle ?? theme.textTheme.subhead;
    TextStyle _currentDateStyle = currentDateStyle ??
        theme.textTheme.body2.copyWith(color: theme.accentColor);
    TextStyle _disabledDateStyle = disabledDateStyle ??
        theme.textTheme.body1.copyWith(color: theme.disabledColor);
    TextStyle _selectedDateStyle =
        selectedDateStyle ?? theme.accentTextTheme.body2;
    TextStyle _defaultDateTextStyle =
        defaultDateTextStyle ?? theme.textTheme.body1;
    BoxDecoration _selectedSingleDateDecoration =
        selectedSingleDateDecoration ??
            BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0)));

    return DatePickerStyles(
        disabledDateStyle: _disabledDateStyle,
        currentDateStyle: _currentDateStyle,
        displayedPeriodTitle: _displayedPeriodTitle,
        selectedDateStyle: _selectedDateStyle,
        selectedSingleDateDecoration: _selectedSingleDateDecoration,
        defaultDateTextStyle: _defaultDateTextStyle);
  }
}

/// Styles for date pickers which allow select some range (e.g. [RangePicker], [WeekPicker]).
class DatePickerRangeStyles extends DatePickerStyles {
  /// Decoration for the first date of the selected range.
  final BoxDecoration selectedPeriodStartDecoration;

  /// Decoration for the last date of the selected range.
  final BoxDecoration selectedPeriodLastDecoration;

  /// Decoration for the date of the selected range which is not first date and not end date of this range.
  ///
  /// If there is only one date selected [DatePickerStyles.selectedSingleDateDecoration] will be used.
  final BoxDecoration selectedPeriodMiddleDecoration;

  /// Return new [DatePickerRangeStyles] object where fields with null values set with defaults from passed theme
  DatePickerRangeStyles fulfillWithTheme(ThemeData theme) {
    Color accentColor = theme.accentColor;

    DatePickerStyles commonStyles = super.fulfillWithTheme(theme);

    final BoxDecoration _selectedPeriodStartDecoration =
        selectedPeriodStartDecoration ??
            BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0)),
            );

    final BoxDecoration _selectedPeriodLastDecoration =
        selectedPeriodLastDecoration ??
            BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
            );

    final BoxDecoration _selectedPeriodMiddleDecoration =
        selectedPeriodMiddleDecoration ??
            BoxDecoration(
              color: accentColor,
              shape: BoxShape.rectangle,
            );

    return DatePickerRangeStyles(
        disabledDateStyle: commonStyles.disabledDateStyle,
        currentDateStyle: commonStyles.currentDateStyle,
        displayedPeriodTitle: commonStyles.displayedPeriodTitle,
        selectedDateStyle: commonStyles.selectedDateStyle,
        selectedSingleDateDecoration: commonStyles.selectedSingleDateDecoration,
        defaultDateTextStyle: commonStyles.defaultDateTextStyle,
        selectedPeriodStartDecoration: _selectedPeriodStartDecoration,
        selectedPeriodMiddleDecoration: _selectedPeriodMiddleDecoration,
        selectedPeriodLastDecoration: _selectedPeriodLastDecoration);
  }

  const DatePickerRangeStyles(
      {displayedPeriodTitle,
      currentDateStyle,
      disabledDateStyle,
      selectedDateStyle,
      selectedSingleDateDecoration,
      defaultDateTextStyle,
      this.selectedPeriodLastDecoration,
      this.selectedPeriodMiddleDecoration,
      this.selectedPeriodStartDecoration})
      : super(
            displayedPeriodTitle: displayedPeriodTitle,
            currentDateStyle: currentDateStyle,
            disabledDateStyle: disabledDateStyle,
            selectedDateStyle: selectedDateStyle,
            selectedSingleDateDecoration: selectedSingleDateDecoration,
            defaultDateTextStyle: defaultDateTextStyle);
}
