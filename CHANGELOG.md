## [0.0.6] - 21 November 2019
Added support for custom day decoration.\
Added support for custom disabled days.

## [0.1.0] - 31 May 2020
Fixed i18n issue for MonthPicker in case no locale was set.\
Fixed selection periods with unselectable dates issue in RangePicker.\
Minor changes and fixes.

## [0.1.1] - 20 June 2020
Added scrollPhysics property to DatePickerLayoutSettings.

## [0.1.3] - 23 June 2020
Added day headers style customization.\
Added prev/next icon customization.\
Added selected period text styles customization.

## [0.1.4] - 2 July 2020
Added firstDayOfWeekIndex customization.

## [0.1.5] - 29 July 2020
Added support of the CupertinoApp ancestor (fixed #29).

## [0.1.6] - 21 August 2020
Added two customizable fields to DatePickerLayoutSettings: showNextMonthStart, showPrevMonthEnd (implemented #28).

## [0.1.7] - 25 August 2020
Added onMonthChange callback for all day based pickers.\
Added newPeriod field to UnselectablePeriodError class.

## [0.1.8] - 26 October 2020
Fixed selection in RangePicker which is on the edge of date when time changes (#44).

## [0.1.9] - 23 December 2020
Increased intl dependency version.\
Minor changes.

## [0.1.10] - 23 December 2020
Increased intl dependency version according to one used on pub.dev.

## [0.2.0] - 7 March 2021
Migrated to null-safety.\
Added DatePickerLayoutSettings.hideMonthNavigationRow option.

## [0.2.1] - 16 March 2021
Used intl for getting short month name for MonthPicker (fixed #54)

## [0.2.2] - 20 March 2021
Added **initiallyShowDate** optional property for DayPicker, WeekPicker and RangePicker.

## [0.2.3] - 05 April 2021
Fixed nextTooltip initializing (#57).

## [0.2.3+1] - 11 April 2021
Fixed defining DayHeaderStyle in DatePickerStyles.fulfillWithTheme.

## [0.2.4] - 29 April 2021
Fixed incorrect new month calculations (#56).

## [0.2.5] - 9 October 2021
Added dayHeaderTitleBuilder to DatePickerStyles (#64).

## [0.2.6] - 16 October 2021
Fixed MonthPicker (#70).\
Changed way to instantiate MonthPicker. Now you need to use **MonthPicker.single** instead of **MonthPicker**.

## [0.2.7] - 21 November 2021
Handled Daylight Savings Time during defining firstDayOfWeek and lastDayOfTheWeek (#79).

## [0.2.8] - 13 January 2022
Fixed getting month type for month picker (#87).
Fixed deprecated styles (#83).

## [0.2.9] - 13 February 2022
Improved RangePicker performance.
Changed selection time for day-based pickers:
 For single date is midnight (00:00:00.000).
 For start of the range is midnight (00:00:00.000).
 For end of the range is millisecond before the next day midnight (23:59:59.999).

## [0.3.0] - 22 March 2022
Added YearPicker.

## [0.3.1] - 22 May 2022
Fixed Flutter 3 warning (#93).

## [0.4.0] - 30 May 2022
Made eventDecorationBuilder applicable for disabled dates (#62).

## [0.4.1] - 26 Jan 2023
Added DatePickerLayoutSettings.cellContentMargin for ability to margin decorations inside cell.

## [0.4.2] - 13 Apr 2023
Used Material.maybeOf instead of Material.of to fix error.

## [0.4.3] - 31 May 2024
Supported Flutter 3.22 changes.