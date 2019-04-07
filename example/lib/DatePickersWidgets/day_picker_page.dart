import 'package:flutter/material.dart';
import 'package:flutter_date_picker/color_picker_dialog.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class DayPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  Color displayedPeriodTitleColor;
  Color currentDateStyleColor;
  Color disabledDateStyleColor;
  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;
  Color defaultDateStyleColor;

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
    displayedPeriodTitleColor = Theme.of(context).textTheme.subhead.color;
    currentDateStyleColor = Theme.of(context).accentColor;
    disabledDateStyleColor = Theme.of(context).disabledColor;
    selectedDateStyleColor = Theme.of(context).accentTextTheme.body2.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
    defaultDateStyleColor = DefaultTextStyle.of(context).style.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    dp.DatePickerStyles styles = dp.DatePickerStyles(
        displayedPeriodTitle: Theme.of(context)
            .textTheme
            .subhead
            .copyWith(color: displayedPeriodTitleColor),
        currentDateStyle: Theme.of(context)
            .textTheme
            .body2
            .copyWith(color: currentDateStyleColor),
        disabledDateStyle: Theme.of(context)
            .textTheme
            .body1
            .copyWith(color: disabledDateStyleColor),
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
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
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Selected date styles", style: Theme.of(context).textTheme.subhead,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(children: <Widget>[
                    _selectedTextRow(),
                    SizedBox(width: 12.0,),
                    _selectedBackground()
                  ],),
                )
              ],
            ),
          ),
        ),


        Text("Selected: $_selectedDate")
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


  Widget _selectedTextRow(){
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(child: Text(
            "Text",
            overflow: TextOverflow.ellipsis,
          )),
          GestureDetector(
            onTap: _showSelectedDateDialog,
            child: Container(
              height: 42.0,
              width: 42.0,
              decoration: BoxDecoration(
                  color: selectedDateStyleColor, shape: BoxShape.circle),
            ),
          )
        ],
      ),
    );
  }

  Widget _selectedBackground(){
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(
                "Background",
                overflow: TextOverflow.ellipsis,
              )),
          GestureDetector(
            onTap: _showSelectedBackgroundColorDialog,
            child: Container(
              height: 42.0,
              width: 42.0,
              decoration: BoxDecoration(
                  color: selectedSingleDateDecorationColor,
                  shape: BoxShape.circle),
            ),
          )
        ],
      ),
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }
}
