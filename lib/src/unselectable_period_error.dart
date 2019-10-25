/// Exception thrown when selected period contains custom disabled days.

class UnselectablePeriodException implements Exception {
  // Dates inside selected period what can't be selected according custom rules.
  final List<DateTime> customDisabledDates;

  UnselectablePeriodException(this.customDisabledDates);

  String toString() {
    return "UnselectablePeriodException: ${customDisabledDates.length} dates inside selected period "
        "can't be selected according custom rules (selectable pridicate). "
        "Check 'customDisabledDates' property to get full list of such dates.";
  }
}