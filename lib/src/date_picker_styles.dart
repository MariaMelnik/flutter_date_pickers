import 'package:flutter/rendering.dart';

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
