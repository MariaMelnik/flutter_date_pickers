import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/date_pickers.dart';

class WeekPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPickerPageState();
}

class _WeekPickerPageState extends State<WeekPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;
  DatePeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime.now().add(Duration(days: 45));
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: WeekPicker(
              selectedDate: _selectedDate,
              onChanged: _onSelectedDateChanged,
              firstDate: _firstDate,
              lastDate: _lastDate),
        ),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Selected: $_selectedDate"),
            ),
            _selectedPeriod != null
                ? Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text("Selected period boundaries:"),
                    ),
                    Text(_selectedPeriod.start.toString()),
                    Text(_selectedPeriod.end.toString()),
                  ])
                : Container()
          ],
        )
      ],
    );
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedDate = newPeriod.start;
      _selectedPeriod = newPeriod;
    });
  }
}


Widget buildWeekDatePicker (DateTime selectedDate, DateTime firstAllowedDate, DateTime lastAllowedDate, ValueChanged<DatePeriod> onNewSelected) {
  return WeekPicker(
      selectedDate: selectedDate,
      onChanged: onNewSelected,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate
  );
}