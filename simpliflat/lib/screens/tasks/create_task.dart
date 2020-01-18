import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/models/models.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'dart:core';

class CreateTask extends StatefulWidget {
  final taskId;
  final _flatId;

  CreateTask(this.taskId, this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _CreateTask(taskId, _flatId);
  }
}

class _CreateTask extends State<CreateTask> {
  final taskId;
  final _flatId;
  List existingUsers;

  Set<String> selectedUsers = new Set();

  //static const existingUsers = ["User1", "User2"];
  bool _remind = false;
  String _selectedType = "Responsibility";
  String _selectedPriority = "Low";
  String _selectedUser = "";
  List<String> assignedTo = new List();
  int _usersCount;
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  var _navigatorContext;
  TextEditingController tc = TextEditingController();
  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(Duration(seconds: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _duedate;
  static DateTime _due;
  static int _repeat = -1;
  static Set<int> _selectedFrequencies;
  bool initialized = false;

  _CreateTask(this.taskId, this._flatId);

  void initUsers() {
    if (this.existingUsers == null) {
      existingUsers = new List();
      _updateUsersView();
    }
  }

  @override
  Widget build(BuildContext context) {
    //initUsers();
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: taskId == null ? Text("Add Task") : Text("Edit Task"),
            elevation: 0.0,
            centerTitle: true,
          ),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: taskId == null
                  ? buildForm(null)
                  : StreamBuilder(
                      stream: Firestore.instance
                          .collection(globals.flat)
                          .document(_flatId)
                          .collection(globals.tasks)
                          .document(taskId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return LoadingContainerVertical(1);
                        if (taskId != null && !initialized) {
                          tc.text = snapshot.data['title'];
                          _selectedType = snapshot.data['type'];
                          _selectedPriority =
                              snapshot.data['priority'] == 0 ? "Low" : "High";
                          _selectedUser = snapshot.data['assignee'];
                          _selectedDate = (snapshot.data['due'] as Timestamp).toDate();
                          _remind = snapshot.data['shouldRemindDaily'] ?? false;
                          selectedUsers
                              .addAll(_selectedUser.split(',').toList());
                          initialized = true;
                        } else if (taskId == null) tc.text = "";
                        return buildForm(snapshot.data);
                      },
                    ),
            );
          }),
        ));
  }

  Widget buildForm(data) {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;
    //tc.text = taskId != null ? data["title"]: tc.text;

    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Form(
            key: _formKey1,
            child: TextFormField(
              controller: tc,
              style: textStyle,
              validator: (String value) {
                if (value.isEmpty) return "Task cannot be empty!";
                if (value.length > 50)
                  return "Maximum length of task is 50 characters!";
                return null;
              },
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700),
                  labelText: 'Task',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
          ),
        ),
        ListTile(
          title: DropdownButton(
              items: _priorities.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              style: textStyle,
              value: _selectedPriority,
              hint: Text('Priority'),
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedPriority = valueSelected;
                });
              }),
        ),
        ListTile(
          title: DropdownButton(
              items: _taskType.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              style: textStyle,
              value: _selectedType,
              hint: Text('Type of Task'),
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedType = valueSelected;
                });
              }),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0),
          child: (_selectedType == 'Issue')
              ? CheckboxListTile(
                  title: Text("Remind me about this issue"),
                  value: _remind,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _remind = value;
                    });
                  },
                )
              : ListTile(
                  title: Text("Repeat"),
                  trailing: Icon(Icons.replay),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => new Form(
                            key: _formKey2,
                            child: AlertDialog(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                side: BorderSide(
                                  width: 1.0,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              title: new Text("Repeat",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Montserrat',
                                      fontSize: 16.0)),
                              content: new SingleChildScrollView(
                                child: new Material(
                                  child: new RepeatDialog(this.getFrequency),
                                ),
                              ),
                            ),
                          ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0),
          child: (_selectedType == "Responsibility" && _repeat != -1)
              ? Text("Repeating task : " + _repeat.toString())
              : null,
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0),
          child: (_selectedType == "Responsibility" &&
                  _selectedFrequencies != null &&
                  _selectedFrequencies.length != 0)
              ? Text("$_selectedFrequencies")
              : null,
        ),
        StreamBuilder(
          stream: Firestore.instance
              .collection(globals.user)
              .where('flat_id', isEqualTo: _flatId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LoadingContainerVertical(1);

            return Container(
              padding: EdgeInsets.only(top: 5.0),
              height: 120.0,
              child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int position) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          var documentID = snapshot
                              .data.documents[position].documentID
                              .toString()
                              .trim();
                          debugPrint("docuemnt - " + documentID);
                          if (selectedUsers.contains(documentID))
                            selectedUsers.remove(documentID);
                          else
                            selectedUsers.add(documentID);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 7,
                          child: Card(
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(
                                width: 1.0,
                                color: Colors.black,
                              ),
                            ),
                            color: selectedUsers.contains(snapshot
                                    .data.documents[position].documentID
                                    .toString()
                                    .trim())
                                ? Colors.black12
                                : Colors.white,
                            elevation: 2.0,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Column(
                                children: <Widget>[
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      snapshot.data.documents[position]['name'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Due date",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${_selectedDate.toLocal()}".substring(0, 11),
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0)),
        ),
        SizedBox(
          height: 5.0,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("${_selectedTime}".substring(10, 15),
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0)),
        ),
        SizedBox(
          height: 20.0,
        ),
        RaisedButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
            side: BorderSide(
              width: 1.0,
              color: Colors.indigo[900],
            ),
          ),
          color: Colors.white,
          textColor: Theme.of(context).primaryColorDark,
          onPressed: () => _selectDate(context),
          child: Text('Select date',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(
                        width: 1.0,
                        color: Colors.indigo[900],
                      ),
                    ),
                    color: Colors.white,
                    textColor: Theme.of(context).primaryColorDark,
                    child: Text('Save',
                        textScaleFactor: 1.5,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      if (_formKey1.currentState.validate()) {
                        debugPrint('Saved');
                        var task = tc.text.trim();
                        var timeNow = DateTime.now();
                        String _time = "$_selectedTime".substring(10, 15);
                        String _date =
                            "$_selectedDate.toLocal()".substring(0, 11);
                        _duedate = "$_date$_time" + ":00";
                        debugPrint("Due date is: $_duedate");
                        _due = DateTime.parse(_duedate);
                        debugPrint("Due date is: $_due");
                        var _userId = await Utility.getUserId();
                        if (taskId == null) {
                          List<int> _frequencies = (_selectedFrequencies == null)
                              ? []
                              :_selectedFrequencies.toList();
                          var data = {
                            "title": task,
                            "updated_at": timeNow,
                            "created_at": timeNow,
                            "due": _due,
                            "type": _selectedType,
                            "priority": _selectedPriority == "Low" ? 0 : 1,
                            "assignee": selectedUsers.isEmpty
                                ? ""
                                : selectedUsers.toList().join(","),
                            "user_id": _userId,
                            "shouldRemindDaily":
                                _selectedType == "Responsibility"
                                    ? false
                                    : _remind,
                            "repeat": _selectedType == "Responsibility"
                                ? _repeat
                                : -1,
                            "frequency": _frequencies,
                            "completed": false
                          };
                          Firestore.instance
                              .collection(globals.flat)
                              .document(_flatId)
                              .collection(globals.tasks)
                              .add(data);
                          if (_selectedFrequencies != null)
                            _selectedFrequencies.clear();
                          _repeat = -1;
                          Navigator.of(_navigatorContext).pop();
                        } else {
                          List<int> _frequencies = (_selectedFrequencies == null)
                          ? []
                          :_selectedFrequencies.toList();
                          var data = {
                            "title": task,
                            "updated_at": timeNow,
                            "due": _due,
                            "type": _selectedType,
                            "priority": _selectedPriority == "Low" ? 0 : 1,
                            "assignee": selectedUsers.isEmpty
                                ? ""
                                : selectedUsers.toList(),
                            "user_id": _userId,
                            "shouldRemindDaily":
                                _selectedType == "Responsibility"
                                    ? false
                                    : _remind,
                            "repeat": _selectedType == "Responsibility"
                                ? _repeat
                                : -1,
                            "frequency":  _frequencies,
                          };
                          Firestore.instance
                              .collection(globals.flat)
                              .document(_flatId)
                              .collection(globals.tasks)
                              .document(taskId)
                              .updateData(data);
                          if (_selectedFrequencies != null)
                            _selectedFrequencies.clear();
                          _repeat = -1;
                          Navigator.of(_navigatorContext).pop();
                        }
                      }
                    }),
              ),
              Container(
                width: 5.0,
              ),
              Expanded(
                  child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        side: BorderSide(
                          width: 1.0,
                          color: Colors.indigo[900],
                        ),
                      ),
                      color: Colors.white,
                      textColor: Theme.of(context).primaryColorDark,
                      child: Text('Delete',
                          textScaleFactor: 1.5,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700)),
                      onPressed: () {
                        Firestore.instance.runTransaction((transaction) async {
                          DocumentSnapshot freshSnap = await transaction.get(
                              Firestore.instance
                                  .collection("tasks")
                                  .document(taskId));
                          await transaction
                              .delete(freshSnap.reference)
                              .then((result) {
                            Utility.createErrorSnackBar(_navigatorContext,
                                error: "Success!");
                            Navigator.of(_navigatorContext).pop();
                          });
                        });
                      }))
            ],
          ),
        ),
      ],
    );
  }

  getFrequency(Set<int> frequencies, int repeat) {
    setState(() {
      _selectedFrequencies = frequencies;
      _repeat = repeat;
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(seconds: 1)),
        lastDate: DateTime(2101));
    final TimeOfDay timePicked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (timePicked != null &&
        timePicked != _selectedTime &&
        picked != null &&
        picked != _selectedDate)
      setState(() {
        _selectedTime = timePicked;
        _selectedDate = picked;
      });
  }

  void _updateUsersView() async {
    Firestore.instance
        .collection("user")
        .where("flat_id", isEqualTo: _flatId)
        .getDocuments()
        .then((snapshot) {
      if (snapshot == null || snapshot.documents.length == 0) {
        //addContacts
      } else {
        setState(() {
          snapshot.documents.sort(
              (a, b) => b.data['updated_at'].compareTo(a.data['updated_at']));
          var responseArray = snapshot.documents
              .map((m) => new FlatUsersResponse.fromJson(m.data, m.documentID))
              .toList();
          this._usersCount = responseArray.length;
          this.existingUsers = responseArray;
        });
      }
    }, onError: (e) {
      debugPrint("ERROR IN UPDATE USERS VIEW");
      Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_selectedFrequencies != null) _selectedFrequencies.clear();
    _repeat = -1;
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    if (_selectedFrequencies != null) _selectedFrequencies.clear();
    _repeat = -1;
    Navigator.pop(_navigatorContext, true);
  }
}

class RepeatDialog extends StatefulWidget {
  final Function callback;

  RepeatDialog(this.callback);

  @override
  State<StatefulWidget> createState() {
    return new _RepeatDialogState();
  }
}

class _RepeatDialogState extends State<RepeatDialog> {
  var _repeatOps = new Map<String, int>();

  _RepeatDialogState() {
    _repeatOps["once a day"] = 0;
    _repeatOps["always available"] = 1;
    _repeatOps["once a week"] = 2;
    _repeatOps["on these days"] = 3;
    _repeatOps["once a month"] = 4;
    _repeatOps["on these dates"] = 5;
  }

  //var _formKey1 = GlobalKey<FormState>();
  int _counter = 1;
  Set<int> selectedFrequency = new Set();
  String _selectedDailyOp = "once a day";
  String _selectedWeeklyOp = "once a week";
  String _selectedMonthlyOp = "once a month";
  String _selectedPriority = "Low";
  String _selectedFreq = "Daily";
  String _selectedUser = "User 1";
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _taskFrequency = ["Daily", "Weekly", "Monthly"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  static const _taskDaily = [
    "once a day",
    "always available",
  ];
  static const _taskWeekly = [
    "once a week",
    "on these days",
  ];
  static const _taskMonthly = [
    "once a month",
    "on these dates",
  ];

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 2.5,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                  items: _taskFrequency.map((String dropdownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropdownStringItem,
                      child: Text(dropdownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: _selectedFreq,
                  hint: Text('Frequency'),
                  onChanged: (valueSelected) {
                    setState(() {
                      debugPrint('User selected something');
                      _selectedFreq = valueSelected;
                    });
                  }),
            ),
//            Center(child: Text("every")),
//            Container(margin: EdgeInsets.all(10.0)),
//            Center(
//              child: Row(
//                children: <Widget>[
//                  Container(margin: EdgeInsets.all(5.0)),
//                  GestureDetector(
//                    child: Icon(Icons.minimize),
//                    onTap: () {
//                      setState(() {
//                        _counter--;
//                      });
//                    },
//                  ),
//                  Container(margin: EdgeInsets.all(5.0)),
//                  Text(_counter.toString()),
//                  Container(margin: EdgeInsets.all(5.0)),
//                  GestureDetector(
//                    child: Icon(Icons.add),
//                    onTap: () {
//                      setState(() {
//                        _counter++;
//                      });
//                    },
//                  ),
//                ],
//              ),
//            ),
            (_selectedFreq == 'Daily')
                ? _showDailyWidget(context)
                : (_selectedFreq == 'Weekly')
                    ? _showWeeklyWidget(context)
                    : _showMonthlyWidget(context),
            Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      OutlineButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.indigo[900],
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.black,
                          child: Text('Save',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          onPressed: () {
                            var repeat;
                            if (_selectedFreq == 'Daily')
                              repeat = _repeatOps[_selectedDailyOp];
                            else if (_selectedFreq == 'Weekly')
                              repeat = _repeatOps[_selectedWeeklyOp];
                            else
                              repeat = _repeatOps[_selectedMonthlyOp];

                            this.widget.callback(selectedFrequency, repeat);

                            Navigator.of(context, rootNavigator: true).pop();
                          }),
                      OutlineButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 1.0,
                              color: Colors.indigo[900],
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.black,
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          })
                    ]))
          ],
        ));
  }

  Widget _showDailyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskDaily.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedDailyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedDailyOp = valueSelected;
                });
              }),
        ),
//        (_selectedDailyOp == "times per day")
//            ? Container(
//                width: double.maxFinite,
//                height: MediaQuery.of(context).size.height / 5.0,
//                child: ListView.builder(
//                    scrollDirection: Axis.horizontal,
//                    itemCount: 24,
//                    itemBuilder: (context, int position) {
//                      return CircleAvatar(
//                        child: Text(position.toString() + "x"),
//                      );
//                    }))
        Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget _showWeeklyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskWeekly.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedWeeklyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedWeeklyOp = valueSelected;
                });
              }),
        ),
        (_selectedWeeklyOp == 'on these days')
            ? Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 5.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, int position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            var day = (position+1);
                            if (selectedFrequency.contains(day))
                              selectedFrequency.remove(day);
                            else
                              selectedFrequency.add(day);
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              selectedFrequency.contains((position+1))
                                  ? Colors.indigo[300]
                                  : Colors.indigo[100],
                          child: Text(
                            _days[position],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    }))
            : Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }

  Widget _showMonthlyWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: DropdownButton(
              items: _taskMonthly.map((String dropdownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropdownStringItem,
                  child: Text(dropdownStringItem),
                );
              }).toList(),
              value: _selectedMonthlyOp,
              onChanged: (valueSelected) {
                setState(() {
                  debugPrint('User selected something');
                  _selectedMonthlyOp = valueSelected;
                });
              }),
        ),
        (_selectedMonthlyOp == 'on these dates')
            ? Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 5.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 28,
                    itemBuilder: (context, int position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            var date = (position + 1);
                            if (selectedFrequency.contains(date))
                              selectedFrequency.remove(date);
                            else
                              selectedFrequency.add(date);
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: selectedFrequency
                                  .contains((position + 1))
                              ? Colors.indigo[300]
                              : Colors.indigo[100],
                          child: Text(
                            (position + 1).toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    }))
            : Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }
}
