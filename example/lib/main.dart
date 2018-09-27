import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Date Picker Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _datetime = '';
  int year = 2018;
  int month = 1;
  int date = 1;
  int hour = 0;
  int minutes = 0;
  int second = 0;

  /// Display date picker.
  void _showDatePicker() {
    //show title 显示标题
    final bool showTitleActions = true;
    DatePicker.showDatePicker(
      context,
      showTitleActions: showTitleActions,
      minYear: 2000,
      maxYear: 2025,
      initialYear: year,
      initialMonth: month,
      initialDate: date,
      initialHour: hour,
      initialMinutes: minutes,
      initialSeconds: second,
      locale: 'zh',
      dateFormat: 'yyyy-MM-dd HH:mm:ss',
      onChanged: (year, month, date,hour,minutes,seconds) {
        print('onChanged date: $year-$month-$date $hour:$minutes:$seconds');

        if (!showTitleActions) {
          settingDatetime(year, month, date,hour,minutes,seconds);
        }
      },
      onConfirm: (year, month, date,hour,minutes,seconds) {
        print("onConfirm date: $year-$month-$date $hour:$minutes:$seconds");
        settingDatetime(year, month, date,hour,minutes,seconds);
      },
    );
  }

  void settingDatetime(int year, int month, int date,int hour,int minutes,int seconds) {
    setState(() {
      this.year = year;
      this.month = month;
      this.date = date;
      this.hour = hour;
      this.minutes = minutes;
      this.second = seconds;
      _datetime = '$year-$month-$date $hour:$minutes:$seconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Date Picker Demo'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Selected Date:',
              style: Theme.of(context).textTheme.subhead,
            ),
            new Text(
              '$_datetime',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _showDatePicker,
        tooltip: 'DatePicker',
        child: new Icon(Icons.date_range),
      ),
    );
  }
}
