import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;


class MonthPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MonthPickerPageState();
}

class _MonthPickerPageState extends State<MonthPickerPage> {
  DateTime _firstDate;
  DateTime _lastDate;
  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.now().subtract(Duration(days: 350));
    _lastDate = DateTime.now().add(Duration(days: 350));

    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
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
              lastDate: _lastDate),
        ),
        Text("Selected date: $_selectedDate")
      ],
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }
}
