import 'package:flutter/material.dart';

// class to provide keys for date pickers
// useful for integration tests to find widgets
class DatePickerKeys {
  final Key previousPageIconKey;
  final Key nextPageIconKey;
  final Key selectedPeriodKeys;

  DatePickerKeys(
      this.previousPageIconKey, this.nextPageIconKey, this.selectedPeriodKeys);
}
