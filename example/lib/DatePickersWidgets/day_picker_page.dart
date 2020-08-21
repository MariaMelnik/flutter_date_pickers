import 'package:flutter/material.dart';
import 'package:flutter_date_picker/event.dart';
import 'package:flutter_date_picker/color_picker_dialog.dart';
import 'package:flutter_date_picker/color_selector_btn.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class DayPickerPage extends StatefulWidget {
  final List<Event> events;

  const DayPickerPage({Key key, this.events}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;
  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime.now().add(Duration(days: 45));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedDateStyleColor = Theme.of(context).accentTextTheme.bodyText1.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText1
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle));

    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: dp.DayPicker(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
            datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                maxDayPickerRowCount: 2,
                showPrevMonthEnd: true,
                showNextMonthStart: true
            ),
            selectableDayPredicate: _isSelectableCustom,
            eventDecorationBuilder: _eventDecorationBuilder,
          ),
        ),
        Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Selected date styles",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ColorSelectorBtn(
                        title: "Text",
                        color: selectedDateStyleColor,
                        showDialogFunction: _showSelectedDateDialog,
                        colorBtnSize: 42.0,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      ColorSelectorBtn(
                        title: "Background",
                        color: selectedSingleDateDecorationColor,
                        showDialogFunction: _showSelectedBackgroundColorDialog,
                        colorBtnSize: 42.0,
                      ),
                    ],
                  ),
                ),
                Text("Selected: $_selectedDate")
              ],
            ),
          ),
        ),
      ],
    );
  }

  // select text color of the selected date
  void _showSelectedDateDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedDateStyleColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedDateStyleColor = newSelectedColor;
      });
  }

  // select background color of the selected date
  void _showSelectedBackgroundColorDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedSingleDateDecorationColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedSingleDateDecorationColor = newSelectedColor;
      });
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  bool _isSelectableCustom (DateTime day) {
    return day.weekday < 6;
  }

  dp.EventDecoration _eventDecorationBuilder(DateTime date) {
    List<DateTime> eventsDates = widget.events?.map<DateTime>((Event e) => e.date)?.toList();
    bool isEventDate = eventsDates?.any((DateTime d) => date.year == d.year && date.month == d.month && d.day == date.day) ?? false;

    BoxDecoration roundedBorder = BoxDecoration(
        border: Border.all(
          color: Colors.deepOrange,
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.0))
    );

    return isEventDate
        ? dp.EventDecoration(boxDecoration: roundedBorder)
        : null;
  }
}
