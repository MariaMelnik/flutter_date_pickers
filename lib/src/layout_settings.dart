import 'package:flutter/rendering.dart';
import 'dart:math' as math;

// layout defaults
const Duration _kPageScrollDuration = const Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
const double _kMonthPickerPortraitWidth = 330.0;


class DatePickerLayoutSettings {
  // Duration for scroll to previous or next page
  final Duration pagesScrollDuration;
  final double dayPickerRowHeight;
  final double monthPickerPortraitWidth;
  final int mxDayPickerRowCount;


  _DayPickerGridDelegate get dayPickerGridDelegate =>
      _DayPickerGridDelegate(dayPickerRowHeight, mxDayPickerRowCount);


  // Two extra rows: one for the day-of-week header and one for the month header.
  double get maxDayPickerHeight =>
      dayPickerRowHeight * (mxDayPickerRowCount + 2);


  const DatePickerLayoutSettings(
      {this.pagesScrollDuration = _kPageScrollDuration,
      this.dayPickerRowHeight = _kDayPickerRowHeight,
      this.monthPickerPortraitWidth = _kMonthPickerPortraitWidth,
      this.mxDayPickerRowCount = _kMaxDayPickerRowCount})
      : assert(pagesScrollDuration != null),
        assert(dayPickerRowHeight != null),
        assert(monthPickerPortraitWidth != null),
        assert(mxDayPickerRowCount != null);
}


class _DayPickerGridDelegate extends SliverGridDelegate {
  final double dayPickerRowHeight;
  final int maxDayPickerRowCount;


  const _DayPickerGridDelegate(
      this.dayPickerRowHeight, this.maxDayPickerRowCount);


  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(dayPickerRowHeight,
        constraints.viewportMainAxisExtent / (maxDayPickerRowCount + 1));
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
