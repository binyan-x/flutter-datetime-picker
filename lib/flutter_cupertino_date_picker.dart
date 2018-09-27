
///
/// author: binyan
/// since: 2018/09/27
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DateChangedCallback(int year, int month, int date, int hour,int minutes,int seconds);

const double _kDatePickerHeight = 210.0;
const double _kDatePickerTitleHeight = 44.0;
const double _kDatePickerItemHeight = 36.0;
const double _kDatePickerFontSize = 18.0;

const int _kDefaultMinYear = 2000;
const int _kDefaultMaxYear = 2025;

const List<String> monthNames = const <String>[
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
];

const List<int> leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

class DatePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  static void showDatePicker(
    BuildContext context, {
    bool showTitleActions: true,
    int minYear: _kDefaultMinYear,
    int maxYear: _kDefaultMaxYear,
    int initialYear: _kDefaultMinYear,
    int initialMonth: 1,
    int initialDate: 1,
    int initialHour: 0,
    int initialMinutes: 0,
    int initialSeconds: 0,
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
    locale: 'zh',
    dateFormat: "yyyy-MM-dd HH:mm:ss",
  }) {
    Navigator.push(
        context,
        new _DatePickerRoute(
          showTitleActions: showTitleActions,
          minYear: minYear,
          maxYear: maxYear,
          initialYear: initialYear,
          initialMonth: initialMonth,
          initialDate: initialDate,
          initialHour: initialHour,
          initMinutes: initialMinutes,
          initSeconds: initialSeconds,
          onChanged: onChanged,
          onConfirm: onConfirm,
          locale: locale,
          dateFormat: dateFormat,
          theme: Theme.of(context, shadowThemeOnly: true),
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
        ));
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    this.minYear,
    this.maxYear,
    this.initialYear,
    this.initialMonth,
    this.initialDate,
    this.initialHour,
    this.initMinutes,
    this.initSeconds,
    this.onChanged,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    this.locale,
    this.dateFormat,
    RouteSettings settings,
  }) : super(settings: settings);

  final bool showTitleActions;
  final int minYear,
      maxYear,
      initialYear,
      initialMonth,
      initialDate,
      initialHour,
      initMinutes,
      initSeconds;
  final DateChangedCallback onChanged;
  final DateChangedCallback onConfirm;
  final ThemeData theme;
  final String locale;
  final String dateFormat;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        minYear: minYear,
        maxYear: maxYear,
        initialYear: initialYear,
        initialMonth: initialMonth,
        initialDate: initialDate,
        initialHour: initialHour,
        initialMinutes: initMinutes,
        initialSeconds: initSeconds,
        onChanged: onChanged,
        locale: locale,
        dateFormat: dateFormat,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = new Theme(data: theme, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class _DatePickerComponent extends StatefulWidget {
  _DatePickerComponent(
      {Key key,
      @required this.route,
      this.minYear: _kDefaultMinYear,
      this.maxYear: _kDefaultMaxYear,
      this.initialYear: -1,
      this.initialMonth: 1,
      this.initialDate: 1,
      this.initialHour: 0,
      this.initialMinutes: 0,
      this.initialSeconds: 00,
      this.onChanged,
      this.locale,
      this.dateFormat});

  final DateChangedCallback onChanged;
  final int minYear,
      maxYear,
      initialYear,
      initialMonth,
      initialDate,
      initialHour,
      initialMinutes,
      initialSeconds;

  final _DatePickerRoute route;

  final String locale;
  final String dateFormat;

  @override
  State<StatefulWidget> createState() => _DatePickerState(
      this.minYear,
      this.maxYear,
      this.initialYear,
      this.initialMonth,
      this.initialDate,
      this.initialHour,
      this.initialMinutes,
      this.initialSeconds);
}

class _DatePickerState extends State<_DatePickerComponent> {
  final int minYear, maxYear;
  int _currentYear,
      _currentMonth,
      _currentDate,
      _currentHour,
      _currentMinutes,
      _currentSeconds;
  int _dateCountOfMonth,_dateCountOfHour,_dateCountOfMinutes,_dateCountOfSeconds;
  FixedExtentScrollController yearScrollCtrl, monthScrollCtrl, dateScrollCtrl,hourScrollCtrl,minutesScrollCtrl,secondsScrollCtrl;

  _DatePickerState(
      this.minYear,
      this.maxYear,
      this._currentYear,
      this._currentMonth,
      this._currentDate,
      this._currentHour,
      this._currentMinutes,
      this._currentSeconds) {
    if (this._currentYear == -1) {
      this._currentYear = this.minYear;
    }
    if (this._currentYear < this.minYear) {
      this._currentYear = this.minYear;
    }
    if (this._currentYear > this.maxYear) {
      this._currentYear = this.maxYear;
    }

    if (this._currentMonth < 1) {
      this._currentMonth = 1;
    }
    if (this._currentMonth > 12) {
      this._currentMonth = 12;
    }

    if (this._currentDate < 1) {
      this._currentDate = 1;
    }
    if (this._currentDate > 31) {
      this._currentDate = 31;
    }

    if (this._currentHour < 0) {
      this._currentHour = 0;
    }
    if (this._currentHour > 23) {
      this._currentHour = 23;
    }

    if (this._currentMinutes < 0) {
      this._currentMinutes = 0;
    }
    if (this._currentMinutes > 59) {
      this._currentMinutes = 59;
    }

    if (this._currentSeconds < 0) {
      this._currentSeconds = 0;
    }
    if (this._currentSeconds > 59) {
      this._currentSeconds = 59;
    }

    yearScrollCtrl = new FixedExtentScrollController(
        initialItem: _currentYear - this.minYear);
    monthScrollCtrl =
        new FixedExtentScrollController(initialItem: _currentMonth - 1);
    dateScrollCtrl =
        new FixedExtentScrollController(initialItem: _currentDate - 1);
    hourScrollCtrl =
        new FixedExtentScrollController(initialItem: _currentHour );
    minutesScrollCtrl =
        new FixedExtentScrollController(initialItem: _currentMinutes );
    secondsScrollCtrl =
        new FixedExtentScrollController(initialItem: _currentSeconds );
    //计算 每月有多少天
    _dateCountOfMonth = _calcDateCount();
    //设置一天 24 小时
    _dateCountOfHour = 24;
    _dateCountOfMinutes = 60;
    _dateCountOfSeconds= 60;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          return new ClipRect(
            child: new CustomSingleChildLayout(
              delegate: new _BottomPickerLayout(widget.route.animation.value,
                  showTitleActions: widget.route.showTitleActions),
              child: new GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
//set 年月日 时分秒
  void _setYear(int index) {
    int year = widget.minYear + index;
    if (_currentYear != year) {
      _currentYear = year;
      _notifyDateChanged();
    }
  }

  void _setMonth(int index) {
    int month = index + 1;
    if (_currentMonth != month) {
      _currentMonth = month;
      int dateCount = _calcDateCount();
      if (_dateCountOfMonth != dateCount) {
        setState(() {
          _dateCountOfMonth = dateCount;
        });
      }
      if (_currentDate > dateCount) {
        _currentDate = dateCount;
      }
      _notifyDateChanged();
    }
  }

  void _setHour(int index) {
    int hour = index;
    if (_currentHour != hour) {
      _currentHour = hour;
      _notifyDateChanged();
    }
  }

  void _setDate(int index) {
    int date = index + 1;
    if (_currentDate != date) {
      _currentDate = date;
      _notifyDateChanged();
    }
  }
  void _setMinutes(int index) {
    int minutes = index ;
    if (_currentMinutes != minutes) {
      _currentMinutes = minutes;
      _notifyDateChanged();
    }
  }
  void _setSeconds(int index) {
    int seconds = index;
    if (_currentSeconds != seconds) {
      _currentSeconds = seconds;
      _notifyDateChanged();
    }
  }

  /// @author binyan
  /// @Description: 计算每个月份的天数
  /// @Param
  /// @return
  /// @Date 2018/9/26 17:55
  int _calcDateCount() {
    if (leapYearMonths.contains(_currentMonth)) {
      return 31;
    } else if (_currentMonth == 2) {
      if ((_currentYear % 4 == 0 && _currentYear % 100 != 0) ||
          _currentYear % 400 == 0) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged(_currentYear, _currentMonth, _currentDate, _currentHour,_currentMinutes,_currentSeconds);
    }
  }

  ///渲染选择器
  Widget _renderPickerView() {
    Widget itemView = _renderItemView();
    if (widget.route.showTitleActions) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(),
          itemView,
        ],
      );
    }
    return itemView;
  }

  ///渲染年份
  Widget _renderYearsPickerComponent(String yearAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: _kDatePickerHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          scrollController: yearScrollCtrl,
          itemExtent: _kDatePickerItemHeight,
          onSelectedItemChanged: (int index) {
            _setYear(index);
          },
          children:
              List.generate(widget.maxYear - widget.minYear + 1, (int index) {
            return Container(
              height: _kDatePickerItemHeight,
              alignment: Alignment.center,
              child: Text(
                '${widget.minYear + index}$yearAppend',
                style: TextStyle(
                    color: Color(0xFF000046), fontSize: _kDatePickerFontSize),
                textAlign: TextAlign.start,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _renderMonthsPickerComponent(String monthAppend, {String format}) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: monthScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setMonth(index);
            },
            children: List.generate(monthNames.length, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    new Expanded(
                        child: Text(
                      (format == null)
                          ? '${monthNames[index]}$monthAppend'
                          : '${_formatMonthComplex(
                              index, format)}$monthAppend',
                      style: TextStyle(
                          color: Color(0xFF000046),
                          fontSize: _kDatePickerFontSize),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ))
                  ],
                ),
              );
            }),
          )),
    );
  }

  Widget _renderDaysPickerComponent(String dayAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: dateScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setDate(index);
            },
            children: List.generate(_dateCountOfMonth, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}$dayAppend",
                  style: TextStyle(
                      color: Color(0xFF000046), fontSize: _kDatePickerFontSize),
                  textAlign: TextAlign.start,
                ),
              );
            }),
          )),
    );
  }

  Widget _renderHoursPickerComponent(String hourAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: hourScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setHour(index);
            },
            children: List.generate(_dateCountOfHour, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Text(
                  "${index}$hourAppend",
                  style: TextStyle(
                      color: Color(0xFF000046), fontSize: _kDatePickerFontSize),
                  textAlign: TextAlign.start,
                ),
              );
            }),
          )),
    );
  }

  Widget _renderMinutesPickerComponent(String minutesAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: minutesScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setMinutes(index);
            },
            children: List.generate(_dateCountOfMinutes, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Text(
                  "${index}$minutesAppend",
                  style: TextStyle(
                      color: Color(0xFF000046), fontSize: _kDatePickerFontSize),
                  textAlign: TextAlign.start,
                ),
              );
            }),
          )),
    );
  }

  Widget _renderSecondsPickerComponent(String secondsAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            scrollController: secondsScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setSeconds(index);
            },
            children: List.generate(_dateCountOfSeconds, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Text(
                  "${index}$secondsAppend",
                  style: TextStyle(
                      color: Color(0xFF000046), fontSize: _kDatePickerFontSize),
                  textAlign: TextAlign.start,
                ),
              );
            }),
          )),
    );
  }

  Widget _renderItemView() {
    String yearAppend = _localeYear();
    String monthAppend = _localeMonth();
    String dayAppend = _localeDay();
    String hourAppend = _localeHour();
    String minutesAppend = _localeMinutes();
    String secondsAppend = _localeSeconds();

    List<Widget> pickers = new List<Widget>();
    //先按照空格分隔
    List<String> formatters = widget.dateFormat.split(' ');
    String date = formatters[0];
    String time = formatters[1];
    //按照-分割
    List<String> formatters2 = date.split('-');
    //按照 ： 分割
    List<String> formatters3 = time.split(':');
    // 添加到 pickers
    for (int i = 0; i < formatters2.length; i++) {
      var format = formatters2[i];
      if (format.contains("yy")) {
        pickers.add(_renderYearsPickerComponent(yearAppend));
      } else if (format.contains("MM")) {
        pickers.add(_renderMonthsPickerComponent(monthAppend, format: format));
      } else if (format.contains("dd")) {
        pickers.add(_renderDaysPickerComponent(dayAppend));
      }
    }
    for (int i = 0; i < formatters3.length; i++) {
      var format = formatters3[i];
      if (format.contains("HH")) {
        pickers.add(_renderHoursPickerComponent(hourAppend));
      } else if (format.contains("mm")) {
        pickers.add(_renderMinutesPickerComponent(minutesAppend));
      } else if (format.contains("ss")) {
        pickers.add(_renderSecondsPickerComponent(secondsAppend));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: pickers,
    );
  }

  // Title View 上方标题，确定 取消   done cancel
  Widget _renderTitleActionsView() {
    String done = _localeDone();
    String cancel = _localeCancel();

    return Container(
      height: _kDatePickerTitleHeight,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _kDatePickerTitleHeight,
            child: FlatButton(
              child: Text(
                '$cancel',
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            height: _kDatePickerTitleHeight,
            child: FlatButton(
              child: Text(
                '$done',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () {
                if (widget.route.onConfirm != null) {
                  widget.route.onConfirm(
                      _currentYear, _currentMonth, _currentDate, _currentHour,_currentMinutes,_currentSeconds);
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  ///done  确定
  String _localeDone() {
    if (widget.locale == null) {
      return 'Done';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'en':
        return 'Done';
        break;

      case 'zh':
        return '确定';
        break;

      default:
        return '';
        break;
    }
  }

  ///cancel 取消
  String _localeCancel() {
    if (widget.locale == null) {
      return 'Cancel';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'en':
        return 'Cancel';
        break;

      case 'zh':
        return '取消';
        break;

      default:
        return '';
        break;
    }
  }

  ///年 月 日 时分秒 的后缀单位
  String _localeYear() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'zh':
        return '';
        break;

      default:
        return '';
        break;
    }
  }

  String _localeMonth() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'zh':
        return '月';
        break;

      default:
        return '';
        break;
    }
  }

  String _formatMonthComplex(int month, String format) {
    if (widget.locale == null) {
      return (month + 1).toString();
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'en':
        const months = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        if (format.length <= 2) {
          print(format + ', ' + month.toString());
          return (month + 1).toString();
        } else if (format.length <= 3) {
          return months[month].substring(0, 3);
        } else {
          return months[month];
        }
        break;

      default:
        return (month + 1).toString();
        break;
    }
  }

  String _localeDay() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'zh':
        return '日';
        break;

      default:
        return '';
        break;
    }
  }

  String _localeHour() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'zh':
        return '';
        break;

      default:
        return '';
        break;
    }
  }

  String _localeMinutes() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;

    switch (lang) {
      case 'zh':
        return '';
        break;

      default:
        return '';
        break;
    }
  }

  String _localeSeconds() {
    if (widget.locale == null) {
      return '';
    }

    String lang = widget.locale.split('_').first;
    //如果是中文可追加单位 秒
    switch (lang) {
      case 'zh':
        return '';
        break;

      default:
        return '';
        break;
    }
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {this.itemCount, this.showTitleActions});

  final double progress;
  final int itemCount;
  final bool showTitleActions;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = _kDatePickerHeight;
    if (showTitleActions) {
      maxHeight += _kDatePickerTitleHeight;
    }

    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
