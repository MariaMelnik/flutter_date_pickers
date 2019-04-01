import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/date_pickers.dart';

class RangePickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RangePickerPageState();
}

class _RangePickerPageState extends State<RangePickerPage> {
  DateTime _firstDate;
  DateTime _lastDate;
  DatePeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.now().subtract(Duration(days: 45));
    _lastDate = DateTime.now().add(Duration(days: 45));

    DateTime selectedPeriodStart = DateTime.now().subtract(Duration(days: 4));
    DateTime selectedPeriodEnd = DateTime.now().add(Duration(days: 8));
    _selectedPeriod = DatePeriod(selectedPeriodStart, selectedPeriodEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: RangePicker(
              selectedPeriod: _selectedPeriod,
              onChanged: _onSelectedDateChanged,
              firstDate: _firstDate,
              lastDate: _lastDate),
        ),
        Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text("Selected period boundaries:"),
          ),
          Text(_selectedPeriod.start.toString()),
          Text(_selectedPeriod.end.toString()),
        ])
      ],
    );
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedPeriod = newPeriod;
    });
  }
}
