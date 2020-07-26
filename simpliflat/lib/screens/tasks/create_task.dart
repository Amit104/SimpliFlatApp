import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/models/models.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  final taskId;
  final _flatId;
  final typeOfTask;
  final bool isTenantPortal;

  CreateTask(this.taskId, this._flatId, this.typeOfTask, this.isTenantPortal);

  @override
  State<StatefulWidget> createState() {
    return _CreateTask(taskId, _flatId, typeOfTask, isTenantPortal);
  }
}

class _CreateTask extends State<CreateTask> {
  final taskId;
  final _flatId;
  String typeOfTask;
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
  TextEditingController notescontroller = TextEditingController();
  TextEditingController paymentAmountController = TextEditingController();
  TextEditingController payeecontroller = TextEditingController();

  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  String _duedate;
  static DateTime _due;
  static int _repeat = -1;
  static Set<int> _selectedFrequencies;
  bool initialized = false;
  String _durationStr = '';
  Duration _duration;
  String _repeatStr = '';

  DateTime _nextDueDate;

  DateTime duebefore;
  int repeatbefore;

  bool openConfictsView = false;

  String _notes = '';

  Map<int, String> repeatMsgs = {
    -1: 'Occurs Once',
    0: 'Set Daily',
    1: 'Always Available',
    2: 'Set weekly',
    3: 'Set weekly on particular days',
    4: 'Set Monthly',
    5: 'Set monthly on particular dates'
  };

  String _payee;

  bool isTenantPortal;

  RegExp regExp = new RegExp('[0-9]{2}h [0-9]{2}m');

  bool _isRemindMeOfIssueSelected;

  bool showConflictsWarningSign = false;

  String collectionname;

  DocumentReference listRef;
  var listTitle = 'Loading...';

  _CreateTask(this.taskId, this._flatId, this.typeOfTask, this.isTenantPortal) {
    _isRemindMeOfIssueSelected = false;
    collectionname =
        isTenantPortal ? 'tasks_landlord' : collectionname = 'tasks';
  }

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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.grey[300],
            title: taskId == null ? Text("Add Task") : Text("Edit Task"),
            elevation: 0.0,
            centerTitle: true,
          ),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return Column(children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 0.0),
                  child: taskId == null
                      ? buildForm(null)
                      : StreamBuilder(
                          stream: Firestore.instance
                              .collection(globals.flat)
                              .document(_flatId)
                              .collection(collectionname)
                              .document(taskId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return LoadingContainerVertical(1);
                            if (taskId != null && !initialized) {
                              /** if edit task */
                              /** process data receieved from database and assign */
                              debugPrint(snapshot.data['title'] +
                                  ' ' +
                                  snapshot.data['priority'].toString() +
                                  ' ' +
                                  snapshot.data['duration'].toString() +
                                  ' ' +
                                  snapshot.data['repeat'].toString() +
                                  ' ' +
                                  snapshot.data['frequency'].toString() +
                                  ' ' +
                                  snapshot.data['assignee'].toString() +
                                  ' ' +
                                  snapshot.data['due'].toString() +
                                  ' ' +
                                  snapshot.data['notes']);
                              /** get task name */
                              tc.text = snapshot.data['title'];
                              /** get task name ends */

                              /** get priority */
                              _selectedPriority = snapshot.data['priority'] == 0
                                  ? "Low"
                                  : "High";
                              /** get priority ends */

                              /**  get duration */
                              if (snapshot.data['duration'] != '') {
                                var durationElements =
                                    snapshot.data['duration'].split(":");
                                _duration = new Duration(
                                    hours: int.parse(durationElements[0]),
                                    minutes: int.parse(durationElements[1]));
                                _durationStr = getFormattedDurationString();
                              } else {
                                _durationStr = '';
                              }
                              /** get duration ends */

                              /** get repeat */
                              _repeat = snapshot.data['repeat'];
                              repeatbefore = _repeat;
                              if (snapshot.data['frequency'] != '')
                                _selectedFrequencies = snapshot
                                    .data['frequency']
                                    .toString()
                                    .split(',')
                                    .map(int.parse)
                                    .toSet();
                              else
                                _selectedFrequencies = new Set();
                              if (_repeat == -1)
                                _repeatStr = 'Repeat';
                              else
                                _repeatStr = repeatMsgs[_repeat];
                              /** get repeat ends */

                              /** get assigned users */
                              _selectedUser = snapshot.data['assignee'];
                              if (_selectedUser != '')
                                selectedUsers
                                    .addAll(_selectedUser.split(',').toList());
                              /** get assigned users ends */

                              _selectedType = snapshot.data['type'];
                              typeOfTask = snapshot.data['type'];

                              /** get due date time starts */
                              _selectedDate =
                                  (snapshot.data['due'] as Timestamp).toDate();
                              duebefore =
                                  (snapshot.data['due'] as Timestamp).toDate();
                              _selectedTime = new TimeOfDay(
                                  hour: _selectedDate.hour,
                                  minute: _selectedDate.minute);
                              /** get due date time ends */

                              /** get notes */
                              _notes = snapshot.data['notes'];
                              notescontroller.text = _notes;
                              /** get notes ends */

                              /** get remindIssue */
                              _isRemindMeOfIssueSelected =
                                  snapshot.data['remindIssue'];
                              /** get remindIssue ends */

                              /** get payment amount */
                              paymentAmountController.text =
                                  snapshot.data['paymentAmount'].toString();
                              /** get payment amount ends */

                              /** get payee */
                              _payee = snapshot.data['payee'];
                              payeecontroller.text =
                                  _payee == null ? '' : _payee;
                              /** get payee ends */

                              /** get list attachments **/
                              listRef = snapshot.data['listRef'] != null
                                  ? snapshot.data['listRef']
                                  : null;

                              /** get next due date starts */
                              if (snapshot.data['nextDueDate'] != null)
                                _nextDueDate =
                                    (snapshot.data['nextDueDate'] as Timestamp)
                                        .toDate();
                              else
                                _nextDueDate =
                                    (snapshot.data['due'] as Timestamp)
                                        .toDate();
                              ;
                              /** get next due date ends */

                              _remind =
                                  snapshot.data['shouldRemindDaily'] ?? false;

                              initialized = true;
                              debugPrint(tc.text +
                                  ' ' +
                                  _selectedDate.toIso8601String() +
                                  ' ' +
                                  _selectedTime.toString() +
                                  ' ' +
                                  _selectedPriority +
                                  ' ' +
                                  selectedUsers.toList().join(",") +
                                  ' ' +
                                  _repeat.toString() +
                                  ' ' +
                                  _selectedFrequencies.join(",") +
                                  ' ' +
                                  _durationStr +
                                  ' ' +
                                  notescontroller.text);
                              //return buildForm(snapshot.data);
                              /** data processed and assigned */
                            } else if (taskId == null) {
                              tc.text = "";
                              notescontroller.text = "";
                              payeecontroller.text = "";
                            }

                            return buildForm(snapshot.data); /** build screen */
                          },
                        ),
                ),
              ),
              Row(
                children: <Widget>[
                  _getSaveButtonWidget(),
                  _getDeleteButtonWidget(),
                ],
              ),
            ]);
          }),
        ));
  }

  Widget _getDeleteButtonWidget() {
    return Expanded(
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.only(top: 1.0, right: 1.0, left: 0.0),
          child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              color: Colors.grey[200],
              child: Text(
                "Delete",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'Montserrat'),
              ),
              onPressed: () {
                Firestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot freshSnap = await transaction.get(Firestore
                      .instance
                      .collection(collectionname)
                      .document(taskId));
                  await transaction.delete(freshSnap.reference).then((result) {
                    Utility.createErrorSnackBar(_navigatorContext,
                        error: "Success!");
                    Navigator.of(_navigatorContext).pop();
                  });
                });
              }),
        ),
      ),
    );
  }

  Widget _getSaveButtonWidget() {
    return Expanded(
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.only(top: 1.0, right: 1.0, left: 0.0),
          child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15.0),
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'Montserrat'),
              ),
              onPressed: () async {
                String errorMsg = _validateForm();
                if (errorMsg == '') {
                  debugPrint('Saved');
                  var task = tc.text.trim();
                  var timeNow = DateTime.now();

                  var notestext = '';
                  if (notescontroller.text != null)
                    notestext = notescontroller.text.trim();

                  var payeetext = '';
                  if (payeecontroller.text != null)
                    payeetext = payeecontroller.text.trim();

                  String _time = "$_selectedTime".substring(10, 15);
                  String _date = "$_selectedDate.toLocal()".substring(0, 11);
                  _duedate = "$_date$_time" + ":00";
                  debugPrint("Due date is: $_duedate");
                  _due = DateTime.parse(_duedate);
                  debugPrint("Due date is: $_due");
                  var _userId = await Utility.getUserId();
                  DateTime temp = new DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute);
                  Timestamp duedatetime = Timestamp.fromDate(temp);
                  String _frequencies = (_selectedFrequencies == null)
                      ? ""
                      : _selectedFrequencies.toList().join(",");

                  double paymentAmount = (typeOfTask == 'Payment')
                      ? double.parse(paymentAmountController.text)
                      : 0.0;

                  debugPrint(task +
                      ' ' +
                      duedatetime.toString() +
                      ' ' +
                      _selectedPriority +
                      ' ' +
                      selectedUsers.toList().join(",") +
                      ' ' +
                      _repeat.toString() +
                      ' ' +
                      _frequencies +
                      ' ' +
                      _durationStr +
                      ' ' +
                      notestext);

                  Timestamp _nextNewDueDate;

                  if (taskId == null) {
                    _nextNewDueDate = Timestamp.fromDate(getNextDueDateTime(
                        DateTime.now(),
                        duedatetime.toDate(),
                        _repeat,
                        _frequencies));

                    var data = {
                      "title": task,
                      "updated_at": timeNow,
                      "created_at": timeNow,
                      "due": duedatetime,
                      "type": typeOfTask,
                      "priority": _selectedPriority == "Low" ? 0 : 1,
                      "assignee": selectedUsers.isEmpty
                          ? ""
                          : selectedUsers.toList().join(","),
                      "user_id": _userId,
                      "shouldRemindDaily":
                          _selectedType == "Responsibility" ? false : _remind,
                      "repeat": _repeat,
                      "frequency": _frequencies,
                      "duration": _duration == null ? "" : _duration.toString(),
                      "notes": notestext,
                      "remindIssue": _isRemindMeOfIssueSelected,
                      "paymentAmount": paymentAmount,
                      "payee": payeetext,
                      "nextDueDate": _nextNewDueDate,
                      "completed": false,
                      "listRef": listRef,
                      "landlord_id": globals.landlordIdValue,
                      "assigned_to_flat": false
                    };

                    Firestore.instance
                        .collection(globals.flat)
                        .document(_flatId)
                        .collection(collectionname)
                        .add(data);
                    if (_selectedFrequencies != null)
                      _selectedFrequencies.clear();
                    _repeat = -1;
                    Navigator.of(_navigatorContext).pop();
                  } else {
                    if (duebefore.compareTo(duedatetime.toDate()) != 0 ||
                        repeatbefore != _repeat) {
                      //add repeat not changed condition too
                      debugPrint('not equal');
                      _nextNewDueDate = Timestamp.fromDate(getNextDueDateTime(
                          DateTime.now(),
                          duedatetime.toDate(),
                          _repeat,
                          _frequencies));
                    } else {
                      debugPrint('--- ' + _nextDueDate.toIso8601String());
                      _nextNewDueDate = Timestamp.fromDate(_nextDueDate);
                    }

                    var data = {
                      "title": task,
                      "updated_at": timeNow,
                      "due": duedatetime,
                      "type": typeOfTask,
                      "priority": _selectedPriority == "Low" ? 0 : 1,
                      "assignee": selectedUsers.isEmpty
                          ? ""
                          : selectedUsers.toList().join(','),
                      "user_id": _userId,
                      "shouldRemindDaily":
                          _selectedType == "Responsibility" ? false : _remind,
                      "repeat": _repeat,
                      "frequency": _frequencies,
                      "duration": _duration == null ? "" : _duration.toString(),
                      "notes": notestext,
                      "remindIssue": _isRemindMeOfIssueSelected,
                      "paymentAmount": paymentAmount,
                      "nextDueDate": _nextNewDueDate,
                      "payee": payeetext,
                      "listRef": listRef
                    };
                    Firestore.instance
                        .collection(globals.flat)
                        .document(_flatId)
                        .collection(collectionname)
                        .document(taskId)
                        .updateData(data);
                    if (_selectedFrequencies != null)
                      _selectedFrequencies.clear();
                    _repeat = -1;
                    Navigator.of(_navigatorContext).pop();
                  }
                } else {
                  return showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Validation Error'),
                          content: Text(errorMsg),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                }
              }),
        ),
      ),
    );
  }

  Widget _getTaskNameWidget() {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;
    return Container(
      height: 55.0,
      alignment: Alignment.center,
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
          hintText: 'Task Name',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 12.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700),
          labelStyle: textStyle,
        ),
      ),
    );
  }

  Widget _getDueDateTimeWidget(String nextDueDate) {
    debugPrint('new datetime = ' + nextDueDate);

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(width: 1.0, color: Colors.grey[300])),
      child: ListTile(
          dense: true,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.calendar_today,
                color: Colors.blueGrey,
              ),
            ],
          ),
          title: Text('Due',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontFamily: 'Montserrat',
              )),
          subtitle: nextDueDate == ''
              ? null
              : Text(nextDueDate,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontFamily: 'Montserrat',
                  )),
          trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                    visible: showConflictsWarningSign,
                    child: IconButton(
                      icon: Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          openConfictsView = true;
                        });
                      },
                    )),
                Icon(Icons.edit, color: Colors.blueGrey)
              ]),
          onTap: () {
            _selectDate(context);
          }),
    );
  }

  String getDateTimeFormattedString(duedate) {
    // DateTime _selectedDate = (duedate as Timestamp).toDate();
    // var _selectedTime = new TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute);
    // String date = DateFormat('dd/MM/yyyy').format(_selectedDate);
    // String time = _selectedTime.hour.toString().padLeft(2, '0') + ":" + _selectedTime.minute.toString().padLeft(2, '0');
    // return date + ' ' + time;
    if (duedate == null) return '';
    var numToMonth = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec'
    };
    DateTime datetime = (duedate as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        "  " +
        f.format(datetime);

    return datetimeString;
  }

  Container _getRepeatLayout() {
    int subtitle = _repeat;
    debugPrint('subtitle --- ' + subtitle.toString());
    Set<int> frequencies = _selectedFrequencies;
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(width: 1.0, color: Colors.grey[300])),
        child: ListTile(
          dense: true,
          leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.replay)]),
          title: Text(
            (subtitle == null
                ? '-'
                : subtitle == 3
                    ? getWeeksFrequencyMsg(frequencies.toList())
                    : repeatMsgs[subtitle]),
            style: TextStyle(
                color: Colors.black, fontSize: 14.0, fontFamily: 'Montserrat'),
          ),
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
                      child: new RepeatDialog(
                          this.getFrequency, _repeat, _selectedFrequencies),
                    ),
                  ),
                ),
              ),
            );
          },
          trailing: Icon(Icons.edit),
        ));
  }

  String getWeeksFrequencyMsg(List<int> frequency) {
    String msg = 'Occurs weekly on ';
    frequency.sort();
    for (int i = 0; i < frequency.length; i++) {
      msg = msg + _days[frequency[i] - 1];
      if (i < frequency.length - 1) msg = msg + ', ';
    }
    return msg;
  }

  String landlordId;
  String landlordName;

  // Future<dynamic> getAssigneeData() async {
  //   landlordId = await Utility.getLandlordId();
  //   landlordName = await Utility.getLandlordName();
  //   QuerySnapshot result = await Firestore.instance
  //                 .collection(globals.user)
  //                 .where('flat_id', isEqualTo: _flatId)
  //                 .getDocuments();
  //   return result;
  // }

  Widget _getAssigneesLayout() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection(globals.user)
            .where('flat_id', isEqualTo: _flatId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingContainerVertical(1);

          return Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      dense: true,
                      title: Text(
                        'ASSIGN TO',
                        style: TextStyle(fontSize: 15.0),
                      ),
                      trailing:
                          Icon(Icons.people, color: Colors.lightGreen[400])),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    height: 60.0,
                    child: ListView.builder(
                        itemCount: isTenantPortal == true
                            ? snapshot.data.documents.length + 1
                            : snapshot.data.documents.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int position) {
                          var documentID;
                          var name;
                          if (isTenantPortal && position == 0) {
                            documentID = globals.landlordIdValue;
                            name = globals.landlordNameValue;
                          } else if (!isTenantPortal) {
                            documentID = snapshot
                                .data.documents[position].documentID
                                .toString()
                                .trim();
                            name = snapshot.data.documents[position]['name']
                                .toString()
                                .trim();
                          } else if (isTenantPortal && position > 0) {
                            documentID = snapshot
                                .data.documents[position - 1].documentID
                                .toString()
                                .trim();
                            name = snapshot.data.documents[position - 1]['name']
                                .toString()
                                .trim();
                          }
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                debugPrint("docuemnt - " + documentID);
                                if (selectedUsers.contains(documentID))
                                  selectedUsers.remove(documentID);
                                else
                                  selectedUsers.add(documentID);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 5.0),
                              child: Chip(
                                labelPadding: EdgeInsets.all(5.0),
                                shape: StadiumBorder(
                                    side: BorderSide(
                                        color: Colors.grey[400], width: 0.5)),
                                backgroundColor:
                                    selectedUsers.contains(documentID)
                                        ? Colors.grey[400]
                                        : Colors.white,
                                avatar: name==null? null : CircleAvatar(
                                    backgroundColor: Colors.primaries[
                                        documentID.toString().trim().hashCode %
                                            Colors.primaries.length],
                                    //: Colors.purple,
                                    child: Text(
                                      getInitials(name),
                                    )),
                                label: Text(name),
                              ),
                            ),
                          );
                        }),
                  )
                ]),
          );
        });

    // return StreamBuilder(
    //           stream: Firestore.instance
    //               .collection(globals.user)
    //               .where('flat_id', isEqualTo: _flatId)
    //               .snapshots(),
    //           builder: (context, snapshot) {
    //             if (!snapshot.hasData) return LoadingContainerVertical(1);

    //             return Container (
    //               padding: EdgeInsets.only(top: 5.0),
    //               child: Column (
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [ListTile(dense: true, title: Text('ASSIGN TO', style: TextStyle(fontSize: 15.0),), trailing: Icon(Icons.people,color:Colors.lightGreen[400])),
    //                 Container(
    //                   padding: EdgeInsets.only(left: 10.0),
    //                   height: 60.0,
    //                   child: ListView.builder(
    //                       itemCount: snapshot.data.documents.length + 1,
    //                       scrollDirection: Axis.horizontal,
    //                       itemBuilder: (BuildContext context, int position) {
    //                         return GestureDetector(
    //                           onTap: () {
    //                             setState(() {
    //                               if(position == 0) {
    //                                 documentID = landlordId;

    //                               }
    //                               var documentID = snapshot
    //                                   .data.documents[position].documentID
    //                                   .toString()
    //                                   .trim();
    //                               debugPrint("docuemnt - " + documentID);
    //                               if (selectedUsers.contains(documentID))
    //                                 selectedUsers.remove(documentID);
    //                               else
    //                                 selectedUsers.add(documentID);
    //                             });
    //                           },

    //                                 child: Container(
    //                                   margin: EdgeInsets.only(right: 5.0),
    //                                                                       child: Chip (
    //                                     labelPadding: EdgeInsets.all(5.0),
    //                                     avatar: CircleAvatar(
    //                                           backgroundColor: selectedUsers.contains(snapshot
    //                                           .data.documents[position].documentID
    //                                           .toString()
    //                                           .trim())
    //                                       ? Colors.grey[400]
    //                                       : Colors.purple,
    //                                           child: Text(getInitials(snapshot.data.documents[position]['name'])),
    //                                         ),
    //                                     label: Text(snapshot.data.documents[position]['name']),

    //                                     ),
    //                                 ),
    //                         );
    //                       }),
    //                 )
    //                 ]),
    //             );
    //           },
    //         );
  }

  Widget _getRemindMeWidget() {
    return Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(width: 1.0, color: Colors.grey[300])),
        child: ListTile(
            dense: true,
            trailing: Switch(
              value: _isRemindMeOfIssueSelected,
              onChanged: (value) {
                setState(() {
                  debugPrint((!value).toString());
                  _isRemindMeOfIssueSelected = value;
                  _repeat = value ? 0 : -1;
                  debugPrint(_isRemindMeOfIssueSelected.toString());
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.lightBlue[300],
            ),
            title: Text(
              'Remind daily',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat'),
            )));
  }

  Widget _getPaymentInfoWidget() {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;

    _payee = _payee == null ? '-' : _payee;
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          ListTile(
            dense: true,
            trailing: Icon(
              Icons.payment,
              color: Colors.lightBlue[400],
            ),
            title: Text(
              'PAYMENT INFORMATION',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Container(
            child: ListTile(
              dense: true,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.attach_money,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              title: Container(
                child: TextField(
                  controller: paymentAmountController,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17.0,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Payment Amount',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 10.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700),
                    labelStyle: textStyle,
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: ListTile(
              dense: true,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              title: TextFormField(
                  maxLines: null,
                  controller: payeecontroller,
                  decoration: const InputDecoration(
                    hintText: 'Payee UPI Id.',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  )),
            ),
          ),
        ]));
  }

  Widget _getAttachList() {
    if (listRef != null) {
      listRef.get().then((listData) {
        setState(() {
          if (listData != null && listData.data != null) {
            listTitle = listData.data['title'].toString().trim();
          } else {
            listTitle = "@@##error##@@";
          }
        });
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        dense: true,
        trailing: Icon(Icons.list, color: Colors.indigo),
        title: Text('ATTACH LIST',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontFamily: 'Montserrat',
            )),
      ),
      Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(width: 1.0, color: Colors.grey[300])),
          child: ListTile(
            dense: true,
            leading:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.attach_file,
                color: Colors.black,
              )
            ]),
            title: Text(
              (listRef == null || listTitle == "@@##error##@@")
                  ? 'Attach lists here'
                  : listTitle,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat'),
            ),
            onTap: () async {
              if (listRef == null || listTitle == "@@##error##@@") {
                var selectedListRef = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Pick a list to attach'),
                    content: Container(
                      height:
                          MediaQuery.of(_navigatorContext).size.height * .80,
                      width: MediaQuery.of(_navigatorContext).size.width * .95,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection(globals.flat)
                            .document(_flatId)
                            .collection(globals.lists)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          var lists = [];
                          if (!snapshot.hasData)
                            return LoadingContainerVertical(3);
                          if (snapshot.data.documents.length == 0)
                            return Container(
                              child: CommonWidgets.textBox(
                                  "You don't have any lists!", 22),
                            );
                          snapshot.data.documents.sort((a, b) =>
                              b['created_at'].compareTo(a['created_at']));
                          return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, left: 8.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(_navigatorContext)
                                            .size
                                            .width *
                                        0.75,
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 1.0,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(_navigatorContext).pop(
                                              snapshot
                                                  .data.documents[position]);
                                        },
                                        splashColor: Colors.indigo[100],
                                        child: ListTile(
                                          title: Text(
                                            snapshot.data.documents[position]
                                                ['title'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          leading: Icon(
                                            Icons.arrow_right,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  ),
                );

                if (selectedListRef != null) {
                  setState(() {
                    listRef = selectedListRef.reference;
                    listTitle = selectedListRef['title'].toString().trim();
                    debugPrint("title = " + listTitle);
                  });
                }
              }
            },
            trailing: (listRef == null || listTitle == "@@##error##@@")
                ? Icon(Icons.edit)
                : GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      setState(() {
                        listRef = null;
                      });
                    },
                  ),
          )),
    ]);
  }

  Widget _getNotesWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        dense: true,
        trailing: Icon(Icons.event_note, color: Colors.indigo[400]),
        title: Text('NOTES',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontFamily: 'Montserrat',
            )),
      ),
      Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 10.0, right: 5.0, bottom: 4.0),
          child: TextFormField(
              maxLines: null,
              controller: notescontroller,
              decoration: const InputDecoration(
                hintText: 'Notes',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ))),
    ]);
  }

  Widget _getDurationWidget() {
    return ListTile(
      title: _durationStr == ''
          ? Text(
              'Duration',
              style: TextStyle(
                color: _durationStr == '' ? Colors.grey[500] : Colors.black,
              ),
            )
          : Text(getFormattedDurationString()),
      leading: Icon(
        Icons.timer,
        color: Colors.indigo[400],
      ),
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
              title: new Text("Duration",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16.0)),
              content: new SingleChildScrollView(
                child: new Column(
                  children: [
                    CupertinoTimerPicker(
                      initialTimerDuration:
                          _duration == null ? new Duration() : _duration,
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (value) {
                        debugPrint(value.toString());
                        _durationStr = value.toString();
                        _duration = value;
                      },
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              OutlineButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
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
                                    setState(() {
                                      showConflictsWarningSign = false;
                                      _durationStr = _durationStr;
                                      _getTasksWithConflicts();
                                    });
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }),
                              OutlineButton(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
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
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  })
                            ]))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getConflictsViewWidget() {
    return Visibility(
      visible: tasksWithConflicts.length > 0 && openConfictsView,
      child: Container(
        color: Colors.grey[100],
        child: Card(
          child: Column(
            children: [
              Container(
                  color: Colors.grey[400],
                  child: ListTile(
                      title: Text('Conflicts'),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            openConfictsView = false;
                          });
                        },
                      ))),
              Scrollbar(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 400.0),
                    child: ListView.separated(
                      itemCount: tasksWithConflicts.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        int repeatTemp = tasksWithConflicts[index]['repeat'];
                        List<int> freqTemp;
                        if (repeatTemp == 3 || repeatTemp == 5) {
                          freqTemp =
                              (tasksWithConflicts[index]['frequency'] as String)
                                  .split(',')
                                  .map(int.parse)
                                  .toList();
                        }
                        return ListTile(
                          title: Text(tasksWithConflicts[index]['title']),
                          subtitle: Text(repeatTemp == 3
                              ? getWeeksFrequencyMsg(freqTemp.toList())
                              : repeatMsgs[repeatTemp]),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildForm(data) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  _getTaskNameWidget(),
                  typeOfTask != 'Complaint'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask != 'Complaint' ? _getRepeatLayout() : Container(),
                  typeOfTask == 'Reminder'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Reminder' ? _getDurationWidget() : Container(),
                  _repeat != 1 ? SizedBox(height: 20.0) : Container(),
                  _repeat != 1
                      ? _getDueDateTimeWidget(getDateTimeFormattedString1())
                      : Container(),
                  _repeat != 1 ? SizedBox(height: 10.0) : Container(),
                  _repeat != 1 ? _getConflictsViewWidget() : Container(),
                  typeOfTask == 'Complaint'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Complaint'
                      ? _getRemindMeWidget()
                      : Container(),
                  SizedBox(height: 20.0),
                  _getAssigneesLayout(),
                  typeOfTask == 'Payment'
                      ? SizedBox(height: 20.0)
                      : Container(),
                  typeOfTask == 'Payment'
                      ? _getPaymentInfoWidget()
                      : Container(),
                  !isTenantPortal?
                  SizedBox(height: 20.0):Container(),
                  !isTenantPortal?
                  _getAttachList():Container(),
                  SizedBox(height: 20.0),
                  _getNotesWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getNextDueDateTime(
      DateTime nowDueDate, DateTime due, int repeat, String frequency) {
    int nowTime = nowDueDate.hour * 60 + nowDueDate.minute;
    int dueTime = due.hour * 60 + due.minute;
    DateTime now = nowDueDate;
    switch (repeat) {
      case -1:
        {
          return due;
        }
      case 0:
        {
          if (nowTime > dueTime) {
            return due.add(new Duration(days: 1));
          }

          return new DateTime(
              now.year, now.month, now.day, due.hour, due.minute);
        }
      case 1:
        {
          return DateTime.now().add(new Duration(minutes: 1));
        }
      case 2:
        {
          if (nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          return new DateTime(
                  now.year, now.month, now.day, due.hour, due.minute)
              .add(new Duration(days: 7));

          //DateTime tempNow = new DateTime(nowDueDate.year, nowDueDate.month, nowDueDate.day, due.hour, due.minute);

          // tempNow = tempNow.add(new Duration(days: 1));
          // while(tempNow.weekday != nowDueDate.weekday) {
          //   tempNow = tempNow.add(new Duration(days: 1));
          // }

          // return tempNow;
        }
      case 3:
        {
          List<int> taskFreq =
              frequency.split(',').map(int.parse).toSet().toList();
          taskFreq.sort();
          int taskDay = -1;
          for (int i = 0; i < taskFreq.length; i++) {
            if ((taskFreq[i] == now.weekday && nowTime < dueTime) ||
                taskFreq[i] > nowDueDate.weekday) {
              taskDay = taskFreq[i];
              break;
            }
          }

          if (taskDay == -1) {
            taskDay = taskFreq[0];
          }

          DateTime tempNow = new DateTime(nowDueDate.year, nowDueDate.month,
              nowDueDate.day, due.hour, due.minute);
          while (tempNow.weekday != taskDay) {
            tempNow = tempNow.add(new Duration(days: 1));
          }

          return new DateTime(
              tempNow.year, tempNow.month, tempNow.day, due.hour, due.minute);
        }
      case 4:
        {
          if (nowTime < dueTime) {
            return new DateTime(
                now.year, now.month, now.day, due.hour, due.minute);
          }

          int month = nowDueDate.month;
          int year = nowDueDate.year;
          if (month == 12) {
            month = 1;
            year++;
          } else {
            month++;
          }

          return new DateTime(
              year, month, nowDueDate.day, due.hour, due.minute);
        }
      case 5:
        {
          List<int> taskFreq =
              frequency.split(',').map(int.parse).toSet().toList();
          taskFreq.sort();
          int taskDay = -1;
          for (int i = 0; i < taskFreq.length; i++) {
            if ((taskFreq[i] == now.day && nowTime < dueTime) ||
                taskFreq[i] > nowDueDate.day) {
              taskDay = taskFreq[i];
              break;
            }
          }

          int month = nowDueDate.month;
          int year = nowDueDate.year;

          if (taskDay == -1) {
            taskDay = taskFreq[0];
            if (month == 12) {
              month = 1;
              year++;
            } else {
              month++;
            }
          }

          return new DateTime(
              year, month, taskDay, nowDueDate.hour, nowDueDate.minute);
        }
    }

    return nowDueDate;
  }

  /// validates form and returns error message or '' if no error
  String _validateForm() {
    /** validate title */

    if (!_formKey1.currentState.validate()) {
      return 'Task Name is mandatory';
    } else if (_selectedDate == null || _selectedTime == null) {
      return 'Due date and time is mandatory';
    }

    if (typeOfTask == 'Reminder') {
    } else if (typeOfTask == 'Complaint') {
    } else if (typeOfTask == 'Payment') {}

    return '';
  }

  ///formats selected due date and and selected due time into a dd/MM/yyyy hh24:mi:ss string
  String getDateTimeFormattedString1() {
    if (_selectedDate == null || _selectedTime == null) return '';
    String date = DateFormat('dd/MM/yyyy').format(_selectedDate);
    String time = _selectedTime.hour.toString().padLeft(2, '0') +
        ":" +
        _selectedTime.minute.toString().padLeft(2, '0');
    return date + ' ' + time;
  }

  ///formats duration into a '<>h <>m' string
  String getFormattedDurationString() {
    String hours = _duration.inHours.toString();
    String minutes = _duration.inMinutes.remainder(60).toString();
    return 'Takes  ' + hours + 'h ' + minutes + 'm';
  }

  ///returns initials of name
  String getInitials(String name) {
    var names = name.split(' ');
    var initials = names[0][0];
    if (names.length == 2) initials = initials + names[1][0];

    return initials;
  }

  ///callback after repeat is set
  getFrequency(Set<int> frequencies, int repeat) {
    var msg = repeatMsgs[repeat];
    debugPrint("in getFreq");

    setState(() {
      if (repeat == 1) {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay(
            hour: _selectedDate.hour, minute: _selectedDate.minute + 1);
      } else {
        _selectedDate = null;
        _selectedTime = null;
      }
      _selectedFrequencies = frequencies;
      _repeat = repeat;
      _repeatStr = msg;
      showConflictsWarningSign = false;
      openConfictsView = false;
    });
  }

  ///dialog box to select due date and time and check conflicts
  Future<Null> _selectDate(BuildContext context) async {
    DateTime picked;
    if (_repeat == 1) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
                content: Text(
                    'Not allowed to set due date time when repeat is set to always available'));
          });
      return;
    }
    if (_repeat == -1 || typeOfTask == 'Complaint') {
      picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate == null ? DateTime.now() : _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101));
      final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime,
      );
      if ((timePicked != null && timePicked != _selectedTime) ||
          (picked != null && picked != _selectedDate)) {
        setState(() {
          showConflictsWarningSign = false;
        });
        setState(() {
          _selectedTime = timePicked;
          _selectedDate = picked;
        });
        _getTasksWithConflicts();
      }
    } else {
      final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime: _selectedTime == null ? TimeOfDay.now() : _selectedTime,
      );
      if ((timePicked != null && timePicked != _selectedTime)) {
        String freq =
            _selectedFrequencies == null ? '' : _selectedFrequencies.join(',');
        DateTime now = DateTime.now();

        picked = getNextDueDateTime(
            now,
            new DateTime(now.year, now.month, now.day, timePicked.hour,
                timePicked.minute),
            _repeat,
            freq);

        setState(() {
          showConflictsWarningSign = false;
        });
        debugPrint('in else');
        setState(() {
          _selectedTime = timePicked;
          _selectedDate = picked;
        });
        _getTasksWithConflicts();
      }
    }
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

  ///get all tasks to check conflicts
  Future<List<DocumentSnapshot>> _getAllTasks() async {
    QuerySnapshot tasks = await Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection(globals.tasks)
        .where("completed", isEqualTo: false)
        .getDocuments();

    QuerySnapshot tasks1 = await Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection("tasks_landlord")
        .where("landlord_id", isEqualTo: globals.landlordIdValue)
        .where("completed", isEqualTo: false)
        .getDocuments();
    tasks.documents.addAll(tasks1.documents);
    if (tasks.documents.isNotEmpty)
      return tasks.documents;
    else
      return null;
  }

  List tasksWithConflicts = new List();

  ///check conflicts and add them in tasksWithConflicts variable
  void _getTasksWithConflicts() {
    if (_selectedDate == null || _selectedTime == null) {
      debugPrint('returned');
      return;
    }
    debugPrint('not returned');

    tasksWithConflicts = new List();
    _getAllTasks().then((tasksList) {
      if (tasksList == null) return;
      DateTime duedatetime = new DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute);
      DateTime toduedatetime;
      if (_duration != null) {
        toduedatetime = duedatetime.add(_duration);
      } else {
        toduedatetime = duedatetime.add(new Duration(hours: 0, minutes: 1));
      }
      for (int i = 0; i < tasksList.length; i++) {
        debugPrint(tasksList[i].toString());
        if (tasksList[i].documentID == taskId) {
          continue;
        }
        debugPrint(tasksList[i].data['title']);
        debugPrint(
            (tasksList[i].data['due'] as Timestamp).toDate().toIso8601String());

        debugPrint(tasksList[i].data['frequency']);

        debugPrint(tasksList[i].data['duration']);
        debugPrint(tasksList[i].data['repeat'].toString());

        DateTime existingduedatetime =
            (tasksList[i].data['due'] as Timestamp).toDate();
        DateTime existingtoduedatetime =
            existingduedatetime.add(new Duration(hours: 0, minutes: 1));
        DateTime relativeExistingToDueDateTime = new DateTime(
                duedatetime.year,
                duedatetime.month,
                duedatetime.day,
                existingduedatetime.hour,
                existingduedatetime.minute)
            .add(new Duration(hours: 0, minutes: 1));

        DateTime relativeExistingDateTime = new DateTime(
            duedatetime.year,
            duedatetime.month,
            duedatetime.day,
            existingduedatetime.hour,
            existingduedatetime.minute);
        if (tasksList[i].data['duration'] != '') {
          int hours = int.parse(tasksList[i].data['duration'].split(':')[0]);
          int minutes = int.parse(tasksList[i].data['duration'].split(':')[1]);
          existingtoduedatetime = existingduedatetime
              .add(new Duration(hours: hours, minutes: minutes));
          relativeExistingToDueDateTime = new DateTime(
                  duedatetime.year,
                  duedatetime.month,
                  duedatetime.day,
                  existingduedatetime.hour,
                  existingduedatetime.minute)
              .add(new Duration(hours: hours, minutes: minutes));
        }

        int taskRepeat = tasksList[i].data['repeat'];
        if (taskRepeat == 3 && _repeat == 2) {
          List<int> frequency =
              tasksList[i].data['frequency'].split(',').map(int.parse).toList();
          if (frequency.contains(duedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && _repeat == 3) {
          List<int> frequency = _selectedFrequencies.toList();
          if (frequency.contains(existingduedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && _repeat == 4) {
          List<int> frequency =
              tasksList[i].data['frequency'].split(',').map(int.parse).toList();
          if (frequency.contains(duedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && _repeat == 5) {
          List<int> frequency = _selectedFrequencies.toList();

          if (frequency.contains(existingduedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && _repeat == 2) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && _repeat == 4) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 3 && _repeat == 3) {
          Set<int> frequency1 = (tasksList[i].data['frequency'] as String)
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.intersection(_selectedFrequencies).isNotEmpty &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && _repeat == 5) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();
          if (frequency1.intersection(_selectedFrequencies).isNotEmpty &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && _repeat == 2) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && _repeat == 3) {
          if (_selectedFrequencies.contains(existingduedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && _repeat == 4) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == -1 && _repeat == 5) {
          if (_selectedFrequencies.contains(existingduedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 2 && _repeat == -1) {
          if (duedatetime.weekday == existingduedatetime.weekday &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 3 && _repeat == -1) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.contains(duedatetime.weekday) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 4 && _repeat == -1) {
          if (duedatetime.day == existingduedatetime.day &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 5 && _repeat == -1) {
          Set<int> frequency1 = tasksList[i]
              .data['frequency']
              .split(',')
              .map(int.parse)
              .toList()
              .toSet();

          if (frequency1.contains(duedatetime.day) &&
              _overlap(duedatetime, toduedatetime, relativeExistingDateTime,
                  relativeExistingToDueDateTime)) {
            tasksWithConflicts.add(tasksList[i].data);
          }
        } else if (taskRepeat == 1) {
          tasksWithConflicts.add(tasksList[i].data);
        } else if (taskRepeat == -1 &&
            _repeat == -1 &&
            _overlap(duedatetime, toduedatetime, existingduedatetime,
                existingtoduedatetime)) {
          tasksWithConflicts.add(tasksList[i].data);
        } else if (_overlap(duedatetime, toduedatetime,
            relativeExistingDateTime, relativeExistingToDueDateTime)) {
          debugPrint(tasksList[i].data['title']);
          tasksWithConflicts.add(tasksList[i].data);
        }
      }

      for (int i = 0; i < tasksWithConflicts.length; i++) {
        debugPrint("conflicts - " +
            i.toString() +
            " - " +
            tasksWithConflicts[i]['title']);
      }

      setState(() {
        tasksWithConflicts = tasksWithConflicts;
        if (tasksWithConflicts.length > 0)
          showConflictsWarningSign = true;
        else
          showConflictsWarningSign = false;
      });
    }).catchError((e) => print("error while fetching data: $e"));
  }

  ///check if the two tasks overlap with respect to time
  bool _overlap(DateTime newTaskFrom, DateTime newTaskTo,
      DateTime existingTaskFrom, DateTime existingTaskTo) {
    debugPrint(newTaskFrom.toIso8601String() +
        ' -- ' +
        newTaskTo.toIso8601String() +
        ' -- ' +
        existingTaskFrom.toIso8601String() +
        ' -- ' +
        existingTaskTo.toIso8601String());
    return !(newTaskFrom.isAfter(existingTaskTo) ||
            existingTaskFrom.isAfter(newTaskTo)) ||
        newTaskFrom.compareTo(existingTaskFrom) == 0 ||
        newTaskFrom.compareTo(existingTaskTo) == 0 ||
        newTaskTo.compareTo(existingTaskFrom) == 0 ||
        newTaskTo.compareTo(existingTaskTo) == 0;
  }
}

class RepeatDialog extends StatefulWidget {
  final Function callback;

  int repeatOps;
  Set<int> frequencies;

  RepeatDialog(this.callback, repeatOps, frequencies) {
    this.repeatOps = repeatOps;
    this.frequencies = frequencies;
  }

  @override
  State<StatefulWidget> createState() {
    return new _RepeatDialogState(repeatOps, frequencies);
  }
}

class _RepeatDialogState extends State<RepeatDialog> {
  var _repeatOps = new Map<String, int>();

  String _selectedDailyOp = "once a day";
  String _selectedWeeklyOp = "once a week";
  String _selectedMonthlyOp = "once a month";

  _RepeatDialogState(int repeatOps, Set frequencies) {
    _repeatOps["once a day"] = 0;
    _repeatOps["always available"] = 1;
    _repeatOps["once a week"] = 2;
    _repeatOps["on these days"] = 3;
    _repeatOps["once a month"] = 4;
    _repeatOps["on these dates"] = 5;
    if (repeatOps == 3 && frequencies != null) {
      _selectedWeekDays = Set.from(frequencies);
      _selectedFreq = 'Weekly';
      _selectedWeeklyOp = 'on these days';
    } else if (repeatOps == 5 && frequencies != null) {
      _selectedDates = Set.from(frequencies);
      _selectedFreq = 'Monthly';
      _selectedMonthlyOp = 'on these dates';
    } else if (repeatOps == 0) {
      _selectedFreq = 'Daily';
      _selectedDailyOp = 'once a day';
    } else if (repeatOps == 2) {
      _selectedFreq = 'Weekly';
      _selectedWeeklyOp = 'once a week';
    } else if (repeatOps == 4) {
      _selectedFreq = 'Monthly';
      _selectedMonthlyOp = 'once a month';
    } else {
      _selectedFreq = 'Daily';
      _selectedDailyOp = 'always available';
    }
  }

  //var _formKey1 = GlobalKey<FormState>();
  int _counter = 1;
  Set<int> selectedFrequency = new Set();

  String _selectedPriority = "Low";
  String _selectedFreq = "Daily";
  String _selectedUser = "User 1";
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _taskFrequency = ["Once", "Daily", "Weekly", "Monthly"];
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

  Set<int> _selectedWeekDays = new Set();
  Set<int> _selectedDates = new Set();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 2.3,
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
                    : (_selectedFreq == 'Monthly')
                        ? _showMonthlyWidget(context)
                        : Container(),
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
                            debugPrint("in save");
                            if (_selectedDailyOp != 'always available') {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                          'Changing repeat will reset due date and time'),
                                      actions: <Widget>[
                                        OutlineButton(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(10.0),
                                            side: BorderSide(
                                              width: 1.0,
                                              color: Colors.indigo[900],
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          textColor: Colors.black,
                                          child: Text('Continue',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700)),
                                          onPressed: () {
                                            var repeat;
                                            if (_selectedFreq == 'Daily')
                                              repeat =
                                                  _repeatOps[_selectedDailyOp];
                                            else if (_selectedFreq ==
                                                'Weekly') {
                                              repeat =
                                                  _repeatOps[_selectedWeeklyOp];
                                              selectedFrequency =
                                                  _selectedWeekDays;
                                            } else if (_selectedFreq ==
                                                'Monthly') {
                                              repeat = _repeatOps[
                                                  _selectedMonthlyOp];
                                              selectedFrequency =
                                                  _selectedDates;
                                            } else if (_selectedFreq ==
                                                'Once') {
                                              repeat = -1;
                                            }

                                            this.widget.callback(
                                                selectedFrequency, repeat);

                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                        OutlineButton(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(10.0),
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
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              debugPrint("in else");
                              var repeat;
                              if (_selectedFreq == 'Daily')
                                repeat = _repeatOps[_selectedDailyOp];
                              else if (_selectedFreq == 'Weekly') {
                                repeat = _repeatOps[_selectedWeeklyOp];
                                selectedFrequency = _selectedWeekDays;
                              } else if (_selectedFreq == 'Monthly') {
                                repeat = _repeatOps[_selectedMonthlyOp];
                                selectedFrequency = _selectedDates;
                              } else if (_selectedFreq == 'Once') {
                                repeat = -1;
                              }

                              this.widget.callback(selectedFrequency, repeat);

                              Navigator.of(context, rootNavigator: true).pop();
                            }
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
                            debugPrint("in cancel");

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
                            var day = (position + 1);
                            if (_selectedWeekDays.contains(day))
                              _selectedWeekDays.remove(day);
                            else
                              _selectedWeekDays.add(day);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(2.0),
                          child: CircleAvatar(
                            backgroundColor:
                                _selectedWeekDays.contains((position + 1))
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
                height: MediaQuery.of(context).size.height / 5.6,
                child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 4,
                    children: List.generate(31, (position) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            var date = (position + 1);
                            if (_selectedDates.contains(date))
                              _selectedDates.remove(date);
                            else
                              _selectedDates.add(date);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          child: CircleAvatar(
                            backgroundColor:
                                _selectedDates.contains((position + 1))
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
                        ),
                      );
                    })))
            : Container(margin: EdgeInsets.all(10.0))
      ],
    );
  }
}
