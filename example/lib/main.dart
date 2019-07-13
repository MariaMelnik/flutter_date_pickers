import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'DatePickersWidgets/month_picker_page.dart';
import 'DatePickersWidgets/day_picker_page.dart';
import 'DatePickersWidgets/range_picker_page.dart';
import 'DatePickersWidgets/week_picker_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
         supportedLocales: [
           const Locale('en', 'US'), // American English
           const Locale('ru', 'RU'), // Russian
      ],
      debugShowCheckedModeBanner: false,
      title: 'Date pickers demo',
//      theme: ThemeData(
//        primarySwatch: Colors.blueGrey,
//      ),
      home: MyHomePage(title: 'flutter_date_pickers Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime startOfPeriod;
  DateTime endOfPeriod;
  DateTime firstDate;
  DateTime lastDate;

  int _selectedTab;

  final List<Widget> datePickers = <Widget>[
    DayPickerPage(),
    WeekPickerPage(),
    RangePickerPage(),
    MonthPickerPage()
  ];

  @override
  void initState() {
    super.initState();

    _selectedTab = 0;

    DateTime now = DateTime.now();

    firstDate = now.subtract(Duration(days: 10));
    lastDate = now.add(Duration(minutes: 10));

    startOfPeriod = firstDate;
    endOfPeriod = lastDate;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        resizeToAvoidBottomInset: false,
        tabBar: CupertinoTabBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.date_range), title: Text("Day")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.date_range), title: Text("Week")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.date_range), title: Text("Range")),
            ],
          currentIndex: _selectedTab,
          onTap: (newIndex) {
            setState(() {
              _selectedTab = newIndex;
            });
          },
        ),
      tabBuilder: (_, index) => datePickers[_selectedTab],
    );
  }
}
