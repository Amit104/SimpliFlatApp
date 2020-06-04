import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/tasks/view_task.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utility.dart';
import 'create_task.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';

typedef TaskItemBodyBuilder<T> = Widget Function(TaskItem<T> item);
typedef ValueToString<T> = String Function(T value);

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({this.name, this.value, this.hint, this.showHint});

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(children: <Widget>[
      Expanded(
        flex: 2,
        child: Container(
          margin: const EdgeInsets.only(left: 24.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: textTheme.body1.copyWith(fontSize: 15.0),
            ),
          ),
        ),
      ),
      Expanded(
          flex: 3,
          child: Container(
              margin: const EdgeInsets.only(left: 24.0),
              child: _crossFade(
                  Text(value,
                      style: textTheme.caption.copyWith(fontSize: 13.0)),
                  Text(hint, style: textTheme.caption.copyWith(fontSize: 13.0)),
                  showHint)))
    ]);
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({this.margin = EdgeInsets.zero, this.child});

  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          margin: const EdgeInsets.only(bottom: 2.0, right: 15.0, left: 15.0) -
              margin,
          child: Divider(
            height: 1.0,
            color: Colors.black,
          )),
      child,
    ]);
  }
}

class TaskItem<T> {
  TaskItem(
      {this.name,
      this.value,
      this.hint,
      this.builder,
      this.valueToString,
      this.isExpanded})
      : textController = TextEditingController(text: valueToString(value));

  final String name;
  final String hint;
  final TextEditingController textController;
  final TaskItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value;
  bool isExpanded;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(
          name: name,
          value: valueToString(value),
          hint: hint,
          showHint: isExpanded);
    };
  }

  Widget build() => builder(this);
}

class TaskList extends StatefulWidget {
  final flatId;

  TaskList(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return TaskListState(flatId);
  }
}

enum sortingValues { DUE_DATE, PRIORITY }

class TaskListState extends State<TaskList> {
  int count = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var _userId;
  var _userName;
  List<TaskItem<dynamic>> _taskItems;
  bool sortAscending = true;
  var sortBy = sortingValues.DUE_DATE;
  var peopleFilterAllSelected = true;
  int _radioValue1 = 1;
  static var _isResponsibility = true;
  static var _isIssue = true;
  bool initializedNotifications = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final flatId;

  TaskListState(this.flatId);

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  @override
  void initState() {
    super.initState();
    Utility.getUserId().then((userId){
      _userId = userId;
    });
    Utility.getUserName().then((userName){
      _userName = userName;
    });
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _taskItems = <TaskItem<dynamic>>[
      TaskItem<String>(
        name: 'To-Do',
        value: 'What you do',
        hint: 'Do these items',
        valueToString: (String value) => value,
        isExpanded: true,
        builder: (TaskItem<String> item) {
          return CollapsibleBody(
            child: getTaskListView(false),
          );
        },
      ),
      TaskItem<String>(
        name: 'Completed',
        value: 'These you did',
        hint: 'Items here are done',
        valueToString: (String value) => value,
        isExpanded: false,
        builder: (TaskItem<String> item) {
          return CollapsibleBody(
            child: getTaskListView(true),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          elevation: 0.0,
          centerTitle: true,
          //leading: IconButton(icon: Icon(Icons.search), onPressed: null),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  navigateToAddTask();
                })
          ],
        ),
        body: new SingleChildScrollView(
          child: Column(
            children: <Widget>[
              filterOptions(),
              SizedBox(
                height: 10.0,
              ),
              SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.all(1.0),
                  child: ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _taskItems[index].isExpanded = !isExpanded;
                        });
                      },
                      children: _taskItems
                          .map<ExpansionPanel>((TaskItem<dynamic> item) {
                        return ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: item.headerBuilder,
                            canTapOnHeader: true,
                            body: item.build());
                      }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTaskListView(bool isCompleted) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .collection(globals.tasks)
            .where("completed", isEqualTo: isCompleted)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
          if (!taskSnapshot.hasData) return LoadingContainerVertical(7);
          if (isCompleted == false)
            handleNotifications(taskSnapshot.data.documents);

          /// SORTING
          var sortField = getSortField();
          if (sortAscending) {
            taskSnapshot.data.documents.sort((DocumentSnapshot a,
                    DocumentSnapshot b) =>
                int.parse(a.data['due'].compareTo(b.data['due']).toString()));
            taskSnapshot.data.documents.sort(
                (DocumentSnapshot a, DocumentSnapshot b) => int.parse(
                    a.data[sortField].compareTo(b.data[sortField]).toString()));
          } else {
            taskSnapshot.data.documents.sort((DocumentSnapshot a,
                    DocumentSnapshot b) =>
                int.parse(b.data['due'].compareTo(a.data['due']).toString()));
            taskSnapshot.data.documents.sort(
                (DocumentSnapshot a, DocumentSnapshot b) => int.parse(
                    b.data[sortField].compareTo(a.data[sortField]).toString()));
          }

          if (!peopleFilterAllSelected) {
            taskSnapshot.data.documents.removeWhere(
                    (s) => !s.data['assignee'].toString().contains(_userId.trim()));
          }

          /// FILTERING
          if (!_isResponsibility) {
            debugPrint("Removing resp");
            taskSnapshot.data.documents.removeWhere((s) =>
                s.data['type'].toString().trim() == Strings.responsibility);
          }

          if (!_isIssue) {
            debugPrint("Removing resp");
            taskSnapshot.data.documents.removeWhere(
                (s) => s.data['type'].toString().trim() == Strings.issue);
          }

          /// TASK LIST VIEW
          var tooltipKey = new List();
          for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
            tooltipKey.add(GlobalKey());
          }

          return new ListView.builder(
            itemCount: taskSnapshot.data.documents.length,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int position) {

              var numToMonth = {1:'Jan', 2:'Feb', 3:'Mar', 4:'Apr', 5:'May', 6:'Jun',
                7:'Jul', 8:'Aug', 9:'Sep', 10:'Oct', 11:'Nov', 12:'Dec'};

              var datetime = (taskSnapshot.data.documents[position]["due"] as Timestamp).toDate();
              final f = new DateFormat.jm();
              var datetimeString = datetime.day.toString() + " "
                  + numToMonth[datetime.month.toInt()] + " "
                  + datetime.year.toString() + " - "
                  + f.format(datetime);
                  //+ datetime.hour.toString() + ":" + datetime.minute.toString();

              return Card(
                color: Colors.white,
                elevation: 2.0,
                child: Slidable(
                  key: new Key(position.toString()),
                  enabled: !isCompleted,
                  actionPane: SlidableDrawerActionPane(),
                  dismissal: SlidableDismissal(
                    child: SlidableDrawerDismissal(),
                    closeOnCanceled: true,
                    dismissThresholds: <SlideActionType, double>{
                      SlideActionType.primary: 1.0
                    },
                    onWillDismiss: (actionType) {
                      return showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return new AlertDialog(
                            title: new Text('Delete'),
                            content: new Text('Item will be deleted'),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text('Cancel'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              new FlatButton(
                                child: new Text('Ok'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (actionType) {
                      Firestore.instance
                          .collection(globals.flat)
                          .document(flatId)
                          .collection(globals.tasks)
                          .document(
                              taskSnapshot.data.documents[position].documentID)
                          .delete();
                    },
                  ),
                  actionExtentRatio: 0.25,
                  actions: <Widget>[
                    new IconSlideAction(
                      caption: 'Complete',
                      color: Colors.green,
                      icon: Icons.check,
                      onTap: () {
                        var _repeat =
                            taskSnapshot.data.documents[position]['repeat'];
                        var _due = DateTime.now();
                        if (_repeat != -1) {
                          if (_repeat == 0) {
                            _due = (taskSnapshot.data.documents[position]['due'] as Timestamp).toDate()
                                .add(new Duration(days: 1));
                          } else if (_repeat == 2) {
                            _due = (taskSnapshot.data.documents[position]['due'] as Timestamp).toDate()
                                .add(new Duration(days: 7));
                          }
                          else if (_repeat == 3) {
                            var _frequencyList = taskSnapshot
                                .data.documents[position]['frequency'];
                            int _length;
                            int _today = DateTime.now().weekday;
                            debugPrint(
                                "Value of today- $_today, length- $_length");
                            _frequencyList.add(_today);
                            _frequencyList.sort();
                            _length = _frequencyList.length;
                            int _nextDate = _frequencyList[
                                (_frequencyList.indexOf(_today) + 1) % _length];
                            int _duration = _nextDate > _today
                                ? _nextDate - _today
                                : _nextDate < _today
                                    ? 7 - (_today - _nextDate)
                                    : 7;
                            _due = taskSnapshot.data.documents[position]['due']
                                .add(new Duration(days: _duration));
                          }
                          else if (_repeat == 4) {
                            _due = taskSnapshot.data.documents[position]['due']
                                .add(new Duration(days: 28));
                          }
                          else if (_repeat == 5) {
                            var _frequencyList = taskSnapshot
                                .data.documents[position]['frequency'];
                            int _length;
                            int _today = int.parse(
                                DateTime.now().toString().substring(8, 10));
                            _frequencyList.add(_today);
                            _frequencyList.sort();
                            _length = _frequencyList.length;
                            int _nextDate = _frequencyList[
                                (_frequencyList.indexOf(_today) + 1) % _length];
                            int _duration = _nextDate > _today
                                ? _nextDate - _today
                                : _nextDate < _today
                                    ? 7 - (_today - _nextDate)
                                    : 28;
                            _due = taskSnapshot.data.documents[position]['due']
                                .add(new Duration(days: _duration));
                            debugPrint("New due date is $_due");
                          }

                          Firestore.instance
                              .collection(globals.flat)
                              .document(flatId)
                              .collection(globals.tasks)
                              .document(taskSnapshot
                                  .data.documents[position].documentID)
                              .updateData({'due': _due});

                          var taskHistoryData = {
                            "created_at": DateTime.now(),
                            "completed_by": _userId,
                            "user_name": _userName
                          };
                          Firestore.instance
                              .collection(globals.flat)
                              .document(flatId)
                              .collection(globals.tasks)
                              .document(taskSnapshot
                              .data.documents[position].documentID)
                              .collection(globals.taskHistory).add(taskHistoryData);

                        } else {
                          Firestore.instance
                              .collection(globals.flat)
                              .document(flatId)
                              .collection(globals.tasks)
                              .document(taskSnapshot
                                  .data.documents[position].documentID)
                              .updateData({'completed': true});

                          var taskHistoryData = {
                            "created_at": DateTime.now(),
                            "completed_by": _userId,
                            "user_name": _userName
                          };
                          Firestore.instance
                              .collection(globals.flat)
                              .document(flatId)
                              .collection(globals.tasks)
                              .document(taskSnapshot
                              .data.documents[position].documentID)
                              .collection(globals.taskHistory).add(taskHistoryData);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    new IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        var state = Slidable.of(context);
                        var dismiss = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return new AlertDialog(
                              title: new Text('Delete'),
                              content: new Text('Item will be deleted'),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                new FlatButton(
                                  child: new Text('Ok'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );

                        if (dismiss) {
                          Firestore.instance
                              .collection(globals.flat)
                              .document(flatId)
                              .collection(globals.tasks)
                              .document(taskSnapshot
                                  .data.documents[position].documentID)
                              .delete();
                          state.dismiss();
                        }
                      },
                    ),
                  ],
                  child: ListTile(
                    /*leading: CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(
                        Icons.arrow_right,
                        color: Colors.black26,
                      ),
                    ),*/
                    title: CommonWidgets.textBox(
                        taskSnapshot.data.documents[position]["title"], 15.0,
                        color: Colors.black),
                    subtitle: Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          color: Colors.indigo[700],
                          size: 16,
                        ),
                        Container(
                          width: 4.0,
                        ),
                        CommonWidgets.textBox(
                            datetimeString,
                            11.0,
                            color: Colors.black45),
                      ],
                    ),
                    leading: Container(
                      decoration: new BoxDecoration(
                          border: new Border(
                              right: new BorderSide(width: 1.0, color: Colors.indigo[700]))),
                      child: Tooltip(
                        key: tooltipKey[position],
                        decoration: BoxDecoration(
                          color: Colors.indigo[100]
                        ),
                        message:
                            taskSnapshot.data.documents[position]["priority"] == 0
                                ? 'Low Priority'
                                : 'High Priority',
                        child: IconButton(
                          icon: Icon(
                            taskSnapshot.data.documents[position]
                            ["priority"] ==
                                0
                                ? Icons.low_priority
                                : Icons.priority_high,
                            color: taskSnapshot.data.documents[position]
                                        ["priority"] ==
                                    0
                                ? Colors.indigo[700]
                                : Colors.red,
                          ),
                          onPressed: () {
                            dynamic tooltip = tooltipKey[position].currentState;
                            tooltip.ensureTooltipVisible();
                          },
                        ),
                      ),
                    ),
                    onTap: () {
                      debugPrint("Task added");
                      navigateToViewTask(
                          taskId:
                              taskSnapshot.data.documents[position].documentID);
                    },
                  ),
                ),
              );
            },
          );
        });
  }

  void navigateToAddTask({taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, flatId);
      }),
    );
  }

  void navigateToViewTask({taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, flatId);
      }),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Widget filterOptions() {
    return Container(
      height: 68.0,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /// Show all tasks
          Column(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(31),
                color: peopleFilterAllSelected ? Colors.black12 : Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.home,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    setState(() {
                      peopleFilterAllSelected = true;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "All",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          /// Show my tasks
          Column(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(31),
                color: peopleFilterAllSelected ? Colors.white : Colors.black12,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    setState(() {
                      peopleFilterAllSelected = false;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Me",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          /// Task Filter
          Column(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    showFilterBottomSheet();
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Filter",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),

          ///Task Sort
          Column(
            children: <Widget>[
              Material(
                color: Colors.white,
                child: InkWell(
                  customBorder: CircleBorder(),
                  child: IconButton(
                      icon: Icon(
                        Icons.sort,
                        color: Colors.black,
                      ),
                      onPressed: null),
                  onTap: () {
                    showSortBottomSheet(context);
                  },
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Sort",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 2.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSortRadioValueChange(int value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
          sortAscending = true;
          Navigator.of(context).pop();
          break;
        case 1:
          sortAscending = false;
          Navigator.of(context).pop();
          break;
      }
    });
  }

  showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          bottom: true,
          child: Container(
            height: 180.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 0,
                          groupValue: _radioValue1,
                          onChanged: _handleSortRadioValueChange,
                        ),
                        new Text(
                          'Ascending',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: 1,
                          groupValue: _radioValue1,
                          onChanged: _handleSortRadioValueChange,
                        ),
                        new Text(
                          'Descending',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(
                    "Due Date",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700),
                  ),
                  trailing: sortBy == sortingValues.DUE_DATE
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      sortBy = sortingValues.DUE_DATE;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.priority_high),
                  title: Text(
                    "Priority",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700),
                  ),
                  trailing: sortBy == sortingValues.PRIORITY
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      sortBy = sortingValues.PRIORITY;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterSheet(this.filterChange);
      },
    );
  }

  void filterChange(String filter, bool value) {
    setState(() {
      if (filter == Strings.responsibility) {
        _isResponsibility = value;
      }
      if (filter == Strings.issue) {
        _isIssue = value;
      }
    });
  }

  String getSortField() {
    if (sortBy == sortingValues.DUE_DATE) return 'due';
    if (sortBy == sortingValues.PRIORITY) return 'priority';
    return 'due';
  }

  void _showDaily(id, title, description, due) async {
    var time = due;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowDailyID", 'RepeatDaily', 'Repeat Task Daily at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        id.hashCode, title, description, time, platformChannelSpecifics,
        payload: due.hour.toString() + due.minute.toString());
  }

  void _showWeekly(id, title, description, due, day) async {
    var time = due;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowWeeklyID", 'RepeatWeekly', 'Repeat Task Weekly at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        id.hashCode, title, description, day, time, platformChannelSpecifics,
        payload: day.value.toString() + due.hour.toString() + due.minute.toString());
  }

  void _showMonthly(id, title, description, due, date) async {
    var time = due;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "ShowMonthlyID", 'RepeatMonthly', 'Repeat Task Monthly at specified time');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        id.hashCode, title, description, date, platformChannelSpecifics,
        payload: due.hour.toString() + due.minute.toString());
  }

  void handleNotifications(var documents) async {
    initializedNotifications = true;
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    ///To handle case of delete task
    debugPrint(pendingNotificationRequests.length.toString() +
        " pending notifications " +
        documents.length.toString());
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      debugPrint("PENDING = " + pendingNotificationRequest.payload.toString());
      var s = false;
      for (int position = 0; position < documents.length; position++) {
        if (pendingNotificationRequest.id ==
            documents[position].documentID.hashCode) {
          s = true;
        }
      }
      if (!s) {
        debugPrint(
            "Cancelling " + pendingNotificationRequest.payload.toString());
        await flutterLocalNotificationsPlugin
            .cancel(pendingNotificationRequest.id);
      }
    }

    for (int position = 0; position < documents.length; position++) {
      var frequencyOption = documents[position]['repeat'] ?? -1;
      var existingNotification;
      for (var pendingNotificationRequest in pendingNotificationRequests) {
        if (pendingNotificationRequest.id ==
            documents[position].documentID.hashCode) {
          existingNotification = pendingNotificationRequest;
        }
      }
      switch (frequencyOption) {
        case 0:
        case -1:
          {
            var due = (documents[position]['due'] as Timestamp).toDate().toLocal();
            var notificationTime =
                TimeOfDay.fromDateTime(due.subtract(Duration(hours: 1)));
            var dueTimeOfDay = TimeOfDay.fromDateTime(due);
            var title = "Upcoming Task : " + documents[position]['title'];
            var description =
                "You have a task due at ${dueTimeOfDay.hour}:${dueTimeOfDay.minute}. Please check it.";
            var dueTime =
                Time(notificationTime.hour, notificationTime.minute, 0);
            var payload =
                notificationTime.hour.toString() + notificationTime.minute.toString();
            if (existingNotification != null &&
                existingNotification.payload != payload) {
              debugPrint("Cancelling previous instance");
              await flutterLocalNotificationsPlugin
                  .cancel(documents[position].documentID.hashCode);
              _showDaily(
                  documents[position].documentID, title, description, dueTime);
            } else if (existingNotification != null) {
            } else {
              _showDaily(
                  documents[position].documentID, title, description, dueTime);
            }
          }
          break;
        case 2:
          {
            var due = (documents[position]['due'] as Timestamp).toDate().toLocal();
            var notificationTime =
                TimeOfDay.fromDateTime(due);
            var dueTimeOfDay = TimeOfDay.fromDateTime(due);
            var title = "Upcoming Task : " + documents[position]['title'];
            var dueDay = Day(due.weekday);
            var description =
                "You have a task due at ${dueTimeOfDay.hour}:${dueTimeOfDay.minute}. Please check it.";
            var dueTime =
                Time(notificationTime.hour, notificationTime.minute, 0);

            var payload =
                dueDay.value.toString() + dueTimeOfDay.hour.toString() + dueTimeOfDay.minute.toString();
            if (existingNotification != null &&
                existingNotification.payload != payload) {
              debugPrint("Cancelling previous instance");
              await flutterLocalNotificationsPlugin
                  .cancel(documents[position].documentID.hashCode);
              _showWeekly(
                  documents[position].documentID, title, description, dueTime, dueDay);
            } else if (existingNotification != null) {
            } else {
              _showWeekly(
                  documents[position].documentID, title, description, dueTime, dueDay);
            }
          }
          break;
        case 3:
          {
            var due = (documents[position]['due'] as Timestamp).toDate();
            var frequencies = documents[position]['frequency'] ?? new List();
            for (int i = 0; i < frequencies.length(); i++) {
              if ((frequencies[i] - DateTime.now().weekday) % 7 == 1 &&
                  TimeOfDay.now().hour < TimeOfDay.fromDateTime(due).hour &&
                  TimeOfDay.now().minute < TimeOfDay.fromDateTime(due).minute) {
                var notificationTime =
                    TimeOfDay.fromDateTime(due.subtract(Duration(days: 1)));
                var dueTimeOfDay = TimeOfDay.fromDateTime(due);
                var title = "Upcoming Task : " + documents[position]['title'];
                var description =
                    "You have a task due at ${dueTimeOfDay.hour}:${dueTimeOfDay.minute}. Please check it.";
                var dueTime =
                    Time(notificationTime.hour, notificationTime.minute, 0);
                var payload = dueTimeOfDay.hour.toString() +
                    dueTimeOfDay.minute.toString();
                if (existingNotification != null &&
                    existingNotification.payload != payload) {
                  debugPrint("Cancelling previous instance");
                  await flutterLocalNotificationsPlugin
                      .cancel(documents[position].documentID.hashCode);
                  _showDaily(documents[position].documentID, title, description,
                      dueTime);
                } else if (existingNotification != null) {
                } else {
                  _showDaily(documents[position].documentID, title, description,
                      dueTime);
                }
                break;
              }
            }
          }
          break;
        case 4:
          {
            var due = (documents[position]['due'] as Timestamp).toDate();
            var notificationTime =
                TimeOfDay.fromDateTime(due);
            var dueTimeOfDay = TimeOfDay.fromDateTime(due);
            var title = "Upcoming Task : " + documents[position]['title'];
            var dueDay = Day(due.subtract(Duration(days: 1)).weekday);
            var description =
                "You have a task due ${_days[due.subtract(Duration(days: 1)).weekday-1]} at ${dueTimeOfDay.hour}:${dueTimeOfDay.minute}. Please check it.";
            var dueTime =
                Time(notificationTime.hour, notificationTime.minute, 0);
            var payload =
                dueTimeOfDay.hour.toString() + dueTimeOfDay.minute.toString();
            if (existingNotification != null &&
                existingNotification.payload != payload) {
              debugPrint("Cancelling previous instance");
              await flutterLocalNotificationsPlugin
                  .cancel(documents[position].documentID.hashCode);
              _showMonthly(
                  documents[position].documentID, title, description, dueTime, due.subtract(Duration(days: 1)));
            } else if (existingNotification != null) {
            } else {
              _showMonthly(
                  documents[position].documentID, title, description, dueTime, due.subtract(Duration(days: 1)));
            }
          }
          break;
        case 5:
          {
            var due = (documents[position]['due'] as Timestamp).toDate();
            var frequencies = documents[position]['frequency'];
            for (int i = 0; i < frequencies.length(); i++) {
              if ((frequencies[i] - DateTime.now().day) % 28 == 1 &&
                  TimeOfDay.now().hour < TimeOfDay.fromDateTime(due).hour &&
                  TimeOfDay.now().minute < TimeOfDay.fromDateTime(due).minute) {
                var notificationTime =
                    TimeOfDay.fromDateTime(due.subtract(Duration(days: 1)));
                var dueTimeOfDay = TimeOfDay.fromDateTime(due);
                var title = "Upcoming Task : " + documents[position]['title'];
                var description =
                    "You have a task due at ${dueTimeOfDay.hour}:${dueTimeOfDay.minute}. Please check it.";
                var dueTime =
                    Time(notificationTime.hour, notificationTime.minute, 0);
                var payload = dueTimeOfDay.hour.toString() +
                    dueTimeOfDay.minute.toString();
                if (existingNotification != null &&
                    existingNotification.payload != payload) {
                  debugPrint("Cancelling previous instance");
                  await flutterLocalNotificationsPlugin
                      .cancel(documents[position].documentID.hashCode);
                  _showDaily(documents[position].documentID, title, description,
                      dueTime);
                } else if (existingNotification != null) {
                } else {
                  _showDaily(documents[position].documentID, title, description,
                      dueTime);
                }
                break;
              }
            }
          }
          break;
        default:
          {}
          break;
      }
    }
  }
}

class FilterSheet extends StatefulWidget {
  Function callback;

  FilterSheet(this.callback);

  @override
  State<StatefulWidget> createState() {
    return new _FilterSheet();
  }
}

class _FilterSheet extends State<FilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
      ),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 3.0,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: Text(Strings.responsibility),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.white30,
              shape: StadiumBorder(side: BorderSide()),
              selected: TaskListState._isResponsibility,
              onSelected: (bool value) {
                setState(() {
                  TaskListState._isResponsibility = value;
                });
                this.widget.callback(Strings.responsibility, value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilterChip(
              label: Text(Strings.issue),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.white30,
              shape: StadiumBorder(side: BorderSide()),
              selected: TaskListState._isIssue,
              onSelected: (bool value) {
                setState(() {
                  TaskListState._isIssue = value;
                });
                this.widget.callback(Strings.issue, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
