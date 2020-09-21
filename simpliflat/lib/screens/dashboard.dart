import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/tasks/task_list.dart';
import 'package:simpliflat/screens/tasks/view_task.dart';
import 'package:simpliflat/screens/tenant_portal/add_landlord.dart';
import 'package:simpliflat/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

import 'models/models.dart';

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

  // final taskId;
  var currentUserId;
  bool noticesExist = false;
  bool tasksExist = false;

  List incomingRequests;
  int incomingRequestsCount;

  var _progressCircleState = 0;
  var _isButtonDisabled = false;

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
    if (this.incomingRequests == null) {
      incomingRequests = new List();
      _updateRequestsView();
    }
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "SimpliFlat",
            style: TextStyle(color: Color(0xff373D4C), fontFamily: 'Roboto',fontWeight: FontWeight.w700,),
          ),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.settings,
              color: Color(0xff373D4C),
            ),
            onPressed: () {
              Utility.navigateToProfileOptions(context);
            },
          ),
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return new SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),

                // Navigation
                navigationLinks(),

                SizedBox(
                  height: 25.0,
                ),

                //Incoming requests
                Row(
                  children: (incomingRequests == null ||
                          incomingRequests.length == 0)
                      ? <Widget>[Container(margin: EdgeInsets.all(0.0))]
                      : <Widget>[
                          Expanded(child: Container()),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 6.0),
                            child: Text("Incoming Requests",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black)),
                          ),
                          Expanded(flex: 15, child: Container()),
                        ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 7.0, bottom: 7.0),
                  height:
                      (incomingRequests == null || incomingRequests.length == 0)
                          ? 0.0
                          : 118.0,
                  color: Colors.white,
                  child:
                      (incomingRequests == null || incomingRequests.length == 0)
                          ? null
                          : _getIncomingRequestsHorizontal(),
                ),

                SizedBox(
                  height:
                      (incomingRequests == null || incomingRequests.length == 0)
                          ? 0.0
                          : 25.0,
                ),
                getTasks(),
                SizedBox(
                  height: 1.0,
                ),
                getNotices(),

                getEmptyImage(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget navigationLinks() {
    return Row(
      children: <Widget>[
        Expanded(
          child:
              getNavigationButton("TENANT PORTAL", IconsCustom.home, Color(0xff6C67D3)),
        ),
        Expanded(
          child: getNavigationButton("PAYMENTS", Icons.credit_card, Color(0xff47D76E)),
        ),
      ],
    );
  }

  Widget getNavigationButton(String buttonText, var buttonIcon, Color color) {
    return Container(
      margin: EdgeInsets.only(left: 18.0, right: 18.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
      ),
      child: InkWell(
        splashColor: color,
        onTap: () async {
          var landlordId = await Utility.getLandlordId();
          if (landlordId == null || landlordId == "") {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddLandlord(flatId)));
          } else {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TenantPortal(flatId)));
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 20.0,
              ),
              Icon(
                buttonIcon,
                size: 35.0,
                color: Colors.white,
              ),
              Container(
                height: 5.0,
              ),
              Text(buttonText.split(' ')[0], style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w700, fontSize: 25.0, color: Colors.white,)),
              Text(buttonText.split(' ').length > 1 ?buttonText.split(' ')[1] : "", style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.normal, fontSize: 25.0, color: Colors.white,)),
              Container(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Map<String, dynamic>> icons = {
    'Reminder': {'icon': Icons.calendar_today, 'color': Color(0xff6C67D3)},
    'Payment': {'icon': Icons.payment, 'color': Color(0xff47D76E)},
    'Complaint': {'icon': Icons.error, 'color': Color(0xffFFC217)}
  };

  // Get Tasks data for today
  Widget getTasks() {
    var date = DateFormat("yyyy-MM-dd");

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(globals.user)
            .where('flat_id', isEqualTo: flatId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (!snapshot1.hasData) return LoadingContainerVertical(7);
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
                        (DocumentSnapshot a, DocumentSnapshot b) => int.parse(b
                        .data['nextDueDate']
                        .compareTo(a.data['nextDueDate'])
                        .toString()));

                taskSnapshot.data.documents.removeWhere((data) =>
                date.format((data['nextDueDate'] as Timestamp).toDate()) !=
                    date.format(DateTime.now().toLocal()));

                taskSnapshot.data.documents.removeWhere((s) =>
                !s.data['assignee'].toString().contains(currentUserId.trim()));

                /// TASK LIST VIEW
                var tooltipKey = new List();
                for (int i = 0; i < taskSnapshot.data.documents.length; i++) {
                  tooltipKey.add(GlobalKey());
                }

                return Container(
                  color: Color(0xff2079FF),
                  child: ExpansionTile(
                    title: Text("TASKS FOR YOU TODAY", style: TextStyle(color: Colors.white, fontFamily: 'Roboto',fontWeight: FontWeight.w700, fontSize: 16.0,),),
                    initiallyExpanded: true,
                    backgroundColor: Color(0xff2079FF),
                    children: [
                      ListView.builder(
                        itemCount: taskSnapshot.data.documents.length,
                        scrollDirection: Axis.vertical,
                        key: UniqueKey(),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int position) {
                          var datetime = (taskSnapshot.data.documents[position]
                          ["nextDueDate"] as Timestamp)
                              .toDate();

                          if (taskSnapshot.data.documents.length > 0) {
                            tasksExist = true;
                          } else {
                            tasksExist = false;
                          }

                          return Padding(
                              padding: const EdgeInsets.only(right: 0.0, left: 0.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                  elevation: 0.0,
                                  child: ClipPath(
                                    clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),

                                      ),
                                    ),
                                    child: Container(
                                      padding:
                                      EdgeInsets.only(top: 0.0, bottom: 0.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            // color: getPriorityColor(
                                            //     datetime, isCompleted),
                                              color: (icons[taskSnapshot
                                                  .data.documents[position]
                                              ["type"]]['color']),
                                              width: 5.0),
                                          bottom: BorderSide(
                                            color: Color(0xff000000),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        title: CommonWidgets.textBox(
                                            taskSnapshot.data.documents[position]
                                            ["title"],
                                            15.0,
                                            fontFamily: 'Roboto',fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 6.0),
                                            taskSnapshot.data.documents[position]
                                            ["repeat"] ==
                                                1
                                                ? CommonWidgets.textBox(
                                              'Always Available', 12.0,
                                              color: Colors.black45, fontFamily: 'Roboto',fontWeight: FontWeight.w700,)
                                                : Row(
                                              children: <Widget>[
                                                CommonWidgets.textBox(
                                                  _getDateTimeString(
                                                      datetime),
                                                  11.0,
                                                  color: Colors.black45, fontFamily: 'Roboto',fontWeight: FontWeight.w700,),
                                                Container(
                                                  width: 4.0,
                                                ),
                                                taskSnapshot.data.documents[
                                                position]
                                                ["repeat"] !=
                                                    -1
                                                    ? Icon(
                                                  Icons.replay,
                                                  size: 16,
                                                )
                                                    : Container(),
                                              ],
                                            )
                                          ],
                                        ),
                                        trailing: getUsersAssignedView(
                                            taskSnapshot.data.documents[position]
                                            ["assignee"],
                                            snapshot1),
                                        leading: Container(
                                          child: Tooltip(
                                            key: tooltipKey[position],
                                            decoration:
                                            BoxDecoration(color: Colors.indigo),
                                            message: taskSnapshot
                                                .data.documents[position]["type"],
                                            child: IconButton(
                                              icon: Icon(
                                                (icons[taskSnapshot
                                                    .data.documents[position]
                                                ["type"]]['icon']),
                                                color: (icons[taskSnapshot
                                                    .data.documents[position]
                                                ["type"]]['color']),
                                              ),
                                              onPressed: () {
                                                dynamic tooltip =
                                                    tooltipKey[position]
                                                        .currentState;
                                                tooltip.ensureTooltipVisible();
                                              },
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          debugPrint("Task added");
                                          navigateToViewTask(
                                              taskId: taskSnapshot.data
                                                  .documents[position].documentID);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        },
                      )
                    ],
                  ),
                );
              });
        });
  }

  String _getDateTimeString(DateTime nextDueDate) {
    final f = new DateFormat.jm();
    var datetimeString = nextDueDate.day.toString() +
        " " +
        numToMonth[nextDueDate.month.toInt()] +
        " " +
        nextDueDate.year.toString() +
        " | " +
        f.format(nextDueDate);

    return datetimeString;
  }

  Widget getUsersAssignedView(users, AsyncSnapshot<QuerySnapshot> snapshot1) {
    return new Container(
      margin: EdgeInsets.only(right: 5.0),
      child: Stack(
        alignment: Alignment.centerRight,
        overflow: Overflow.visible,
        children:
        _getPositionedOverlappingUsers(users, snapshot1.data.documents),
      ),
    );
  }

  List<Widget> _getPositionedOverlappingUsers(
      users, List<DocumentSnapshot> flatUsers) {
    List<String> userList;

    userList = users.toString().trim().split(',').toList();

    var overflowAddition = 0.0;
    if (userList.length > 3) overflowAddition = 8.0;

    List<Widget> overlappingUsers = new List();
    overflowAddition > 0
        ? overlappingUsers.add(Text('+', style: TextStyle(fontSize: 16.0)))
        : overlappingUsers.add(Container(
      height: 0.0,
      width: 0.0,
    ));

    for (var j in userList) {
      debugPrint("elems == " + j);
    }

    userList.sort();
    int length = userList.length > 3 ? 3 : userList.length;
    debugPrint("length == " + userList.length.toString());

    int availableUsers = 0;
    for (int i = 0; i < length; i++) {
      debugPrint("i == " + i.toString());
      String initial = getInitial(userList[i], flatUsers);
      if (initial == '') {
        continue;
      }
      availableUsers++;
      var color = userList[i].toString().trim().hashCode;
      overlappingUsers.add(new Positioned(
        right: (i * 20.0) + overflowAddition,
        child: new CircleAvatar(
          maxRadius: 14.0,
          backgroundColor: Colors.primaries[color % Colors.primaries.length]
          [300],
          child: Text(initial),
        ),
      ));
    }
    if (userList.contains(globals.landlordIdValue)) {
      var colorL = globals.landlordIdValue.toString().trim().hashCode;

      overlappingUsers.add(new Positioned(
        right: (availableUsers * 20) + overflowAddition,
        child: new CircleAvatar(
          maxRadius: 14.0,
          backgroundColor: Colors.primaries[colorL % Colors.primaries.length]
          [300],
          child: Text(globals.landlordNameValue[0]),
        ),
      ));
    }
    return overlappingUsers;
  }

  String getInitial(documentId, flatUsers) {
    for (int i = 0; i < flatUsers.length; i++) {
      if (flatUsers[i].documentID == documentId) {
        return flatUsers[i].data['name'][0];
      }
    }
    return '';
  }

  void navigateToViewTask({taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return ViewTask(taskId, flatId, false);
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
        return Container(
          color: Color(0xff2079FF),
          child: ExpansionTile(
            title: Text("NOTICES TODAY", style: TextStyle(color: Colors.white, fontFamily: 'Roboto',fontWeight: FontWeight.w700, fontSize: 16.0,),),
            initiallyExpanded: true,
            backgroundColor: Color(0xff2079FF),
            children: [
              ListView.builder(
                  itemCount: notesSnapshot.data.documents.length,
                  key: UniqueKey(),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int position) {
                    return _buildNoticeListItem(
                        notesSnapshot.data.documents[position], position);
                  })
            ],
          ),
        );;
      },
    );
  }

  Widget _buildNoticeListItem(DocumentSnapshot notice, index) {
    debugPrint(currentUserId + " + USERID");
    var datetime = (notice['updated_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = f.format(datetime);

    var userName = notice['user_name'] == null
        ? ""
        : notice['user_name'].toString().trim();

    var color = notice['user_id'].toString().trim().hashCode;

    String noticeTitle = notice['note'].toString().trim();
    if (noticeTitle.length > 100) {
      noticeTitle = noticeTitle.substring(0, 100) + "...";
    }

    return Padding(
        padding: const EdgeInsets.only(right: 0.0, left: 0.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
            elevation: 0.0,
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),

                ),
              ),
              child: Container(
                padding:
                EdgeInsets.only(top: 0.0, bottom: 0.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        color:
                        (Colors.primaries[color % Colors.primaries.length]),
                        width: 5.0),
                    bottom: BorderSide(
                      color: Color(0xff000000),
                      width: 0.5,
                    ),
                    top: BorderSide(
                      color: Color(0xff373D4C),
                      width: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            color: Colors
                                .primaries[color % Colors.primaries.length],
                          ),
                        ),
                        padding: EdgeInsets.only(bottom: 5.0),
                      ),
                      Text(
                        notice['note'].toString().trim(),
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    child: Text(datetimeString,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          color: Colors.black45,
                        )),
                    padding: EdgeInsets.only(top: 6.0),
                  ),
                ),
              ),
            ),
          ),
        ));

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

  void navigateToAddTask({taskId}) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return CreateTask(taskId, flatId);
    //   }),
    // );
  }

  // TODO fix
  ListView _getIncomingRequestsHorizontal() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: this.incomingRequestsCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 1.0, right: 1.0),
            child: SizedBox(
              width: 135,
              height: 105,
              child: Card(
                color: Colors.white,
                elevation: 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 10.0,
                    ),
                    Center(
                      child: Text(
                        incomingRequests[index].name,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Container(
                      height: 2.0,
                    ),
                    Center(
                      child: Text(
                        incomingRequests[index].phone,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Container(
                      height: 24.0,
                    ),
                    new Expanded(
                        child: new Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ButtonTheme(
                                    height: 20.0,
                                    minWidth: 30.0,
                                    child: RaisedButton(
                                        elevation: 0.0,
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(0.0),
                                          side: BorderSide(
                                            width: 0.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        color: Colors.white,
                                        textColor:
                                            Theme.of(context).primaryColorDark,
                                        child: (_progressCircleState == 0)
                                            ? setUpButtonChild("Accept")
                                            : setUpButtonChild("Waiting"),
                                        onPressed: () {
                                          if (_isButtonDisabled == false)
                                            _respondToJoinRequest(
                                                incomingRequests[index], 1);
                                          else {
                                            setState(() {
                                              _progressCircleState = 1;
                                            });

                                            Utility.createErrorSnackBar(context,
                                                error:
                                                    "Waiting for Request Call to Complete!");
                                          }
                                        })),
                                ButtonTheme(
                                    height: 20.0,
                                    minWidth: 30.0,
                                    child: RaisedButton(
                                        elevation: 0.0,
                                        shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(0.0),
                                          side: BorderSide(
                                            width: 0.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        color: Colors.white,
                                        textColor:
                                            Theme.of(context).primaryColorDark,
                                        child: (_progressCircleState == 0)
                                            ? setUpButtonChild("Accept",
                                                color: Colors.red,
                                                icon: Icons.delete)
                                            : setUpButtonChild("Waiting"),
                                        onPressed: () {
                                          if (_isButtonDisabled == false) {
                                            var request =
                                                incomingRequests[index];
                                            setState(() {
                                              incomingRequests.removeAt(index);
                                              incomingRequestsCount--;
                                            });
                                            _respondToJoinRequest(request, -1);
                                          } else
                                            Utility.createErrorSnackBar(context,
                                                error:
                                                    "Waiting for Request Call to Complete!");
                                        })),
                              ],
                            ))),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _updateRequestsView() async {
    Firestore.instance
        .collection("joinflat")
        .where("flat_id", isEqualTo: flatId)
        .where("status", isEqualTo: 0)
        .where("request_from_flat", isEqualTo: 0)
        .getDocuments()
        .then((joinRequests) {
      if (joinRequests == null || joinRequests.documents.length == 0) {
        //no requests
      } else {
        joinRequests.documents.sort(
            (a, b) => b.data['updated_at'].compareTo(a.data['updated_at']));
        List<FlatIncomingResponse> usersToFetch = new List();
        for (int i = 0; i < joinRequests.documents.length; i++) {
          FlatIncomingResponse f = new FlatIncomingResponse();
          f.userId = joinRequests.documents[i].data['user_id'];
          f.createdAt =
              (joinRequests.documents[i].data['created_at'] as Timestamp)
                  .toDate();
          f.updatedAt =
              (joinRequests.documents[i].data['updated_at'] as Timestamp)
                  .toDate();
          Firestore.instance
              .collection("user")
              .document(f.userId)
              .get()
              .then((userData) {
            f.name = userData.data['name'];
            f.phone = userData.data['phone'];
            usersToFetch.add(f);
          }).whenComplete(() {
            setState(() {
              this.incomingRequestsCount = usersToFetch.length;
              this.incomingRequests = usersToFetch;
            });
          });
        }
        for (int i = 0; i < usersToFetch.length; i++) {
          debugPrint(usersToFetch[i].userId);
          Firestore.instance
              .collection("user")
              .document(usersToFetch[i].userId.trim())
              .get()
              .then((userData) {
            if (userData.exists) {
              usersToFetch[i].name = userData.data['name'];
              usersToFetch[i].phone = userData.data['phone'];
              debugPrint("###" + usersToFetch[i].name);
            }
          });
        }
        /*Firestore.instance.runTransaction((transaction) async {
          debugPrint("IN TRANSACTION");
          for (int i = 0; i < usersToFetch.length; i++) {
            DocumentSnapshot userData = await transaction.get(Firestore.instance
                .collection("user")
                .document(usersToFetch[i].userId.trim()));

            if (userData.exists) {
              usersToFetch[i].name = userData.data['name'];
              usersToFetch[i].phone = userData.data['phone'];
            }
          }
        }).whenComplete(() {
          debugPrint("IN WHEN COMPLETE TRANSACTION");
          setState(() {
            this.incomingRequestsCount = usersToFetch.length;
            this.incomingRequests = usersToFetch;
          });
        }).catchError((e) {
          debugPrint("SERVER TRANSACTION ERROR");
          Utility.createErrorSnackBar(_navigatorContext);
        });*/
      }
    }, onError: (e) {
      debugPrint("SERVER ERROR");
      Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  Widget setUpButtonChild(buttonText,
      {icon = Icons.check, color: Colors.green}) {
    if (_progressCircleState == 0) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: new Icon(
          icon,
          color: color,
          size: 24,
        ),
      );
    } else if (_progressCircleState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      );
    } else {
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    }
  }

  // TODO get latest request first
  _respondToJoinRequest(userData, didAccept) async {
    setState(() {
      _isButtonDisabled = true;
    });
    var timeNow = DateTime.now();
    if (didAccept == 1) {
      Firestore.instance
          .collection("joinflat")
          .where("user_id", isEqualTo: userData.userId.toString().trim())
          .getDocuments()
          .then((joinRequests) {
        if (joinRequests == null || joinRequests.documents.length == 0) {
          Utility.createErrorSnackBar(_navigatorContext);
          _enableButtonOnly();
        } else {
          DocumentReference toUpdateFlat;
          var batch = Firestore.instance.batch();
          for (var request in joinRequests.documents) {
            DocumentReference ref = Firestore.instance
                .collection("joinflat")
                .document(request.documentID);
            var data = {"status": -1, "updated_at": timeNow};
            batch.updateData(ref, data);
            if (request.data["flat_id"] == flatId &&
                request.data["request_from_flat"] == 0) {
              toUpdateFlat = ref;
            }
          }
          batch.commit().then((snapshot) {
            if (toUpdateFlat == null) {
              Utility.createErrorSnackBar(_navigatorContext);
              _enableButtonOnly();
            } else {
              toUpdateFlat
                  .updateData({"status": 1, "updated_at": timeNow}).then(
                      (snapshot) {
                Firestore.instance
                    .collection("user")
                    .document(userData.userId.toString().trim())
                    .updateData({
                  "flat_id": flatId.toString().trim(),
                  "updated_at": timeNow
                }).then((user) {
                  debugPrint(userData.userId);
                  setState(() {
                    FlatUsersResponse newUser = new FlatUsersResponse(
                        name: userData.name,
                        userId: userData.userId,
                        createdAt: userData.createdAt,
                        updatedAt: timeNow);
                    //existingUsers.add(newUser);
                    //existingUsers.sort(
                    //        (a, b) => b.getUpdatedAt.compareTo(a.getUpdatedAt));
                    //usersCount++;
                    incomingRequests.remove(userData);
                    incomingRequestsCount--;
                    Utility.createErrorSnackBar(_navigatorContext,
                        error: "Success!");
                  });
                  _enableButtonOnly();
                }, onError: (e) {
                  debugPrint("ERROR IN REQ ACEEPT");
                  Utility.createErrorSnackBar(_navigatorContext);
                  _enableButtonOnly();
                });
              }, onError: (e) {
                debugPrint("ERROR IN REQ ACEEPT");
                Utility.createErrorSnackBar(_navigatorContext);
                _enableButtonOnly();
              });
            }
          }, onError: (e) {
            debugPrint("ERROR IN REQ ACEEPT");
            Utility.createErrorSnackBar(_navigatorContext);
            _enableButtonOnly();
          });
        }
      }, onError: (e) {
        debugPrint("ERROR IN REQ ACCEPT");
        Utility.createErrorSnackBar(_navigatorContext);
        _enableButtonOnly();
      });
    } else {
      debugPrint("####" + userData.userId);
      Firestore.instance
          .collection("joinflat")
          .where("user_id", isEqualTo: userData.userId.toString().trim())
          .where("flat_id", isEqualTo: flatId.toString().trim())
          .where("request_from_flat", isEqualTo: 0)
          .getDocuments()
          .then((joinRequests) {
        if (joinRequests == null || joinRequests.documents.length == 0) {
          debugPrint("CALL ERROR");
          Utility.createErrorSnackBar(_navigatorContext);
          _enableButtonOnly();
        } else {
          debugPrint(joinRequests.documents[0].documentID);
          Firestore.instance
              .collection("joinflat")
              .document(joinRequests.documents[0].documentID)
              .updateData({"status": -1, "updated_at": timeNow}).then((user) {
            setState(() {
              incomingRequests.remove(userData);
              incomingRequestsCount--;
              Utility.createErrorSnackBar(_navigatorContext, error: "Success!");
            });
            _enableButtonOnly();
          }, onError: (e) {
            debugPrint("ERROR IN REQ ACEEPT");
            Utility.createErrorSnackBar(_navigatorContext);
            _enableButtonOnly();
          });
        }
      });
    }
  }

  _enableButtonOnly() {
    setState(() {
      _isButtonDisabled = false;
    });
  }

  getEmptyImage() {
    if(!noticesExist && !tasksExist) {
      return Center(
        child: Column(
          children: [
            Image.asset('assets/images/dashboard-bg.PNG', fit: BoxFit.fill,),
            Container(height: 10.0,),
            Text(
              "You are all caught up for today!",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Roboto',fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
