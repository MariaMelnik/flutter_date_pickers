import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/date_pickers.dart' as dp;

class DayPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

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
          child: dp.DayPicker(
              selectedDate: _selectedDate,
              onChanged: _onSelectedDateChanged,
              firstDate: _firstDate,
              lastDate: _lastDate),
        ),
        Text("Selected: $_selectedDate")
      ],
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }
}
