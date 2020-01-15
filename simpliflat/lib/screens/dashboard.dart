import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/tasks/view_task.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

class Dashboard extends StatefulWidget {
  final flatId;

  Dashboard(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return DashboardState(this.flatId);
  }
}

class DashboardState extends State<Dashboard> {
  var _navigatorContext;
  final flatId;
  var currentUserId;
  bool noticesExist = false;
  bool tasksExist = false;

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

  DashboardState(this.flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Utility.getUserId().then((id) {
      if (id == null || id == "") {
      } else {
        setState(() {
          currentUserId = id;
        });
      }
    });
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "SimpliFlat",
            style: TextStyle(color: Colors.indigo[900]),
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return new SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                dateUI(),
                SizedBox(
                  height: 30.0,
                ),

                // Statistics
                Text(
                  'Point Board',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),

                //Statistics
                SizedBox(
                  height: 20.0,
                ),
                pointBoard(),
                SizedBox(
                  height: 25.0,
                ),

                // Today's Items
                tasksExist
                    ? Text(
                        'Tasks for you today',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    : Container(height: 0.0),
                getTasks(),
                SizedBox(
                  height: 20.0,
                ),
                noticesExist
                    ? Text(
                        'Notices today',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    : Container(height: 0.0),
                getNotices(),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// TODO : Get real statistics here. Currently placeholders
  Widget pointBoard() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '2',
                style: TextStyle(fontSize: 25.0),
              ),
              Text(
                'Tasks',
                style: TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '3',
                style: TextStyle(fontSize: 25.0),
              ),
              Text(
                'Complains',
                style: TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '115.0',
                style: TextStyle(fontSize: 25.0),
              ),
              Text(
                'Rupees Earned',
                style: TextStyle(fontSize: 12.0, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Get Tasks data for today
  Widget getTasks() {
    var date = DateFormat("yyyy-MM-dd");
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .collection(globals.tasks)
            .where("completed", isEqualTo: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
          if (!taskSnapshot.hasData) return LoadingContainerVertical(3);

          taskSnapshot.data.documents.sort(
              (DocumentSnapshot a, DocumentSnapshot b) =>
                  int.parse(b.data['due'].compareTo(a.data['due']).toString()));

          taskSnapshot.data.documents.removeWhere((data) =>
              date.format((data['due'] as Timestamp).toDate()) !=
              date.format(DateTime.now().toLocal()));

          taskSnapshot.data.documents.removeWhere((s) =>
              !s.data['assignee'].toString().contains(currentUserId.trim()));

          /// TASK LIST VIEW
          var tooltipKey = new List();
          for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
            tooltipKey.add(GlobalKey());
          }

          return new ListView.builder(
            itemCount: taskSnapshot.data.documents.length,
            scrollDirection: Axis.vertical,
            key: UniqueKey(),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int position) {
              var datetime =
                  (taskSnapshot.data.documents[position]["due"] as Timestamp)
                      .toDate();
              final f = new DateFormat.jm();
              var datetimeString = datetime.day.toString() +
                  " " +
                  numToMonth[datetime.month.toInt()] +
                  " " +
                  datetime.year.toString() +
                  " - " +
                  f.format(datetime);

              if (taskSnapshot.data.documents.length > 0) {
                tasksExist = true;
              } else {
                tasksExist = false;
              }

              return Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Card(
                      color: Colors.white,
                      elevation: 2.0,
                      child: ListTile(
                        title: CommonWidgets.textBox(
                            taskSnapshot.data.documents[position]["title"],
                            15.0,
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
                            CommonWidgets.textBox(datetimeString, 11.0,
                                color: Colors.black45),
                          ],
                        ),
                        trailing: getUsersAssignedView(
                            taskSnapshot.data.documents[position]["assignee"]),
                        onTap: () {
                          navigateToViewTask(
                              taskId: taskSnapshot
                                  .data.documents[position].documentID);
                        },
                      ),
                    ),
                  ));
            },
          );
        });
  }

  /// TODO: Change taskList code to store names along with user id in array. Then change this hardcoded values to show those.

  Widget getUsersAssignedView(users) {
    //get user color id
    List userList = users.toString().trim().split(';');
    var overflowAddition = 0.0;
    if (userList.length > 3) overflowAddition = 8.0;
    var color = currentUserId.toString().trim().hashCode;

    return new Stack(
      alignment: Alignment.centerRight,
      overflow: Overflow.visible,
      children: <Widget>[
        overflowAddition > 0
            ? Text('+', style: TextStyle(fontSize: 16.0))
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        new Positioned(
          right: overflowAddition,
          child: CircleAvatar(
            maxRadius: 16.0,
            backgroundColor: Colors.orange,
            child: Padding(
              child: Text('A'),
              padding: EdgeInsets.only(left: 5.0),
            ),
          ),
        ),
        new Positioned(
          right: 15.0 + overflowAddition,
          child: new CircleAvatar(
            maxRadius: 16.0,
            backgroundColor: Colors.primaries[color % Colors.primaries.length],
            child: Padding(
              child: Text('B'),
              padding: EdgeInsets.only(left: 5.0),
            ),
          ),
        ),
        new Positioned(
          right: 30.0 + overflowAddition,
          child: new CircleAvatar(
            maxRadius: 16.0,
            backgroundColor: Colors.blue,
            child: Text('C'),
          ),
        ),
      ],
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

  // Get NoticeBoard data
  Widget getNotices() {
    var date = DateFormat("yyyy-MM-dd");
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.noticeBoard)
          //.where('updated_at', isGreaterThanOrEqualTo: date.format(DateTime.now().toLocal()))
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
        if (!notesSnapshot.hasData ||
            currentUserId == null ||
            currentUserId == "") return LoadingContainerVertical(3);
        notesSnapshot.data.documents
            .sort((a, b) => b['updated_at'].compareTo(a['updated_at']));
        notesSnapshot.data.documents.removeWhere((data) =>
            date.format((data['updated_at'] as Timestamp).toDate()) !=
            date.format(DateTime.now().toLocal()));
        if (notesSnapshot.data.documents.length > 0) {
          noticesExist = true;
        } else {
          noticesExist = false;
        }
        return ListView.builder(
            itemCount: notesSnapshot.data.documents.length,
            key: UniqueKey(),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int position) {
              return _buildNoticeListItem(
                  notesSnapshot.data.documents[position], position);
            });
      },
    );
  }

  Widget _buildNoticeListItem(DocumentSnapshot notice, index) {
    debugPrint(currentUserId + " + USERID");
    var datetime = (notice['updated_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        " - " +
        f.format(datetime);

    var userName = notice['user_name'] == null
        ? ""
        : notice['user_name'].toString().trim();

    var color = notice['user_id'].toString().trim().hashCode;

    String noticeTitle = notice['note'].toString().trim();
    if (noticeTitle.length > 100) {
      noticeTitle = noticeTitle.substring(0, 100) + "...";
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: Text(userName,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        color:
                            Colors.primaries[color % Colors.primaries.length],
                      )),
                  padding: EdgeInsets.only(bottom: 5.0),
                ),
                Text(noticeTitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    )),
              ],
            ),
            subtitle: Padding(
              child: Text(datetimeString,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontFamily: 'Montserrat',
                    color: Colors.black45,
                  )),
              padding: EdgeInsets.only(top: 6.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget dateUI() {
    var numToWeekday = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    };

    var now = DateTime.now().toLocal();
    String day = numToWeekday[now.weekday];
    String date = numToMonth[now.month.toInt()] + " " + now.day.toString();
    return Text(
      day + ", " + date,
      style: TextStyle(
        color: Colors.green,
        fontSize: 40.0,
        fontFamily: 'Satisfy',
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
