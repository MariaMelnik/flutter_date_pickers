import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';

class MonthNavigationRow extends StatelessWidget {
  final Key previousPageIconKey;
  final Key nextPageIconKey;
  final VoidCallback onNextMonthTapped;
  final VoidCallback onPreviousMonthTapped;
  final String nextMonthTooltip;
  final String previousMonthTooltip;

  /// Usually [Text] widget.
  final Widget title;

  const MonthNavigationRow({
    Key key,
    this.previousPageIconKey,
    this.nextPageIconKey,
    this.onNextMonthTapped,
    this.onPreviousMonthTapped,
    this.nextMonthTooltip,
    this.previousMonthTooltip,
    this.title
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Semantics(
          sortKey: MonthPickerSortKey.previousMonth,
          child: IconButton(
            key: previousPageIconKey,
            icon: const Icon(Icons.chevron_left),
            tooltip: previousMonthTooltip,
            onPressed: onPreviousMonthTapped,
          ),
        ),
        Expanded(
          child: Container(
            child: Center(
              child: ExcludeSemantics(
                child: title,
              ),
            ),
          ),
        ),
        Semantics(
          sortKey: MonthPickerSortKey.nextMonth,
          child: IconButton(
            key: nextPageIconKey,
            icon: const Icon(Icons.chevron_right),
            tooltip: nextMonthTooltip,
            onPressed: onNextMonthTapped,
          ),
        ),
      ],
    );
  }
}
