import 'package:flutter/material.dart';
import 'package:flutter_date_picker/color_picker_dialog.dart';
import 'package:flutter_date_picker/color_selector_btn.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class MonthPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MonthPickerPageState();
}

class _MonthPickerPageState extends State<MonthPickerPage> {
  DateTime _firstDate;
  DateTime _lastDate;
  DateTime _selectedDate;

  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.now().subtract(Duration(days: 350));
    _lastDate = DateTime.now().add(Duration(days: 350));

    _selectedDate = DateTime.now();
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
    dp.DatePickerStyles styles = dp.DatePickerStyles(
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
          child: dp.MonthPicker(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
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
}
