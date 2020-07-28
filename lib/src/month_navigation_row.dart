import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/src/icon_btn.dart';
import 'package:flutter_date_pickers/src/semantic_sorting.dart';

class MonthNavigationRow extends StatelessWidget {
  final Key previousPageIconKey;
  final Key nextPageIconKey;
  final VoidCallback onNextMonthTapped;
  final VoidCallback onPreviousMonthTapped;
  final String nextMonthTooltip;
  final String previousMonthTooltip;
  final Widget nextIcon;
  final Widget prevIcon;

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
    this.title,
    @required this.nextIcon,
    @required this.prevIcon
  }) : assert(nextIcon != null),
        assert(prevIcon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Semantics(
          sortKey: MonthPickerSortKey.previousMonth,
          child: IconBtn(
            key: previousPageIconKey,
            icon: prevIcon,
            tooltip: previousMonthTooltip,
            onTap: onPreviousMonthTapped,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Center(
              child: ExcludeSemantics(
                child: title,
              ),
            ),
          ),
        ),
        Semantics(
          sortKey: MonthPickerSortKey.nextMonth,
          child: IconBtn(
            key: nextPageIconKey,
            icon: nextIcon,
            tooltip: nextMonthTooltip,
            onTap: onNextMonthTapped,
          ),
        ),
      ],
    );
  }
}
