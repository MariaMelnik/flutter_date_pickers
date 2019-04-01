import 'package:flutter/rendering.dart';
import 'dart:math' as math;

// layout defaults
const Duration _kPageScrollDuration = const Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight = _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);
const double _kMonthPickerPortraitWidth = 330.0;
const _DayPickerGridDelegate _kDayPickerGridDelegate = const _DayPickerGridDelegate(_kDayPickerRowHeight, _kMaxDayPickerRowCount);



class DatePickerLayoutSettings {
  // Duration for scroll to previous or next page
  final Duration pagesScrollDuration;
  final double dayPickerRowHeight;
  final double maxDayPickerHeight;
  final double monthPickerPortraitWidth;
  final _DayPickerGridDelegate dayPickerGridDelegate;

  const DatePickerLayoutSettings({
    this.pagesScrollDuration = _kPageScrollDuration, 
    this.dayPickerRowHeight = _kDayPickerRowHeight, 
    this.maxDayPickerHeight = _kMaxDayPickerHeight, 
    this.monthPickerPortraitWidth = _kMonthPickerPortraitWidth, 
    this.dayPickerGridDelegate = _kDayPickerGridDelegate
  }) : assert (pagesScrollDuration != null),
       assert (dayPickerRowHeight != null),
       assert (maxDayPickerHeight != null),
       assert (monthPickerPortraitWidth != null),
       assert (dayPickerGridDelegate != null);
}


class _DayPickerGridDelegate extends SliverGridDelegate {
    final double dayPickerRowHeight;
    final int maxDayPickerRowCount;
    
    const _DayPickerGridDelegate(this.dayPickerRowHeight, this.maxDayPickerRowCount);

    @override
    SliverGridLayout getLayout(SliverConstraints constraints) {
      const int columnCount = DateTime.daysPerWeek;
      final double tileWidth = constraints.crossAxisExtent / columnCount;
      final double tileHeight = math.min(dayPickerRowHeight, constraints.viewportMainAxisExtent / (maxDayPickerRowCount + 1));
      return SliverGridRegularTileLayout(
        crossAxisCount: columnCount,
        mainAxisStride: tileHeight,
        crossAxisStride: tileWidth,
        childMainAxisExtent: tileHeight,
        childCrossAxisExtent: tileWidth,
        reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      );
    }

    @override
    bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

