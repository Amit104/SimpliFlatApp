import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/models/models.dart';
import 'package:simpliflat/screens/tasks/create_task.dart';
import 'package:simpliflat/screens/tasks/taskHistory.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

class ViewTask extends StatefulWidget {
  final taskId;
  final _flatId;

  ViewTask(this.taskId, this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _ViewTask(taskId, _flatId);
  }
}

class _ViewTask extends State<ViewTask> {
  final taskId;
  final _flatId;
  bool _remind = false;
  String _selectedType = "Responsibility";
  String _selectedPriority = "Low";
  static const _priorities = ["High", "Low"];
  static const _taskType = ["Responsibility", "Issue"];
  static const _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> assignedTo = new List();
  var _navigatorContext;
  TextEditingController tc = TextEditingController();
  var _formKey1 = GlobalKey<FormState>();
  Set<String> selectedUsers = new Set();

  _ViewTask(this.taskId, this._flatId);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
          return null;
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
                  ? Container()
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
                        tc.text = taskId == null ? "" : snapshot.data['title'];
                        return Column(
                          children: <Widget>[
                            Expanded(child: buildView(snapshot.data)),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: RaisedButton(
                                      color: Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(0.0),
                                      ),
                                      child: Text(
                                        "Edit",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      onPressed: () {
                                        navigateToAddTask(taskId: taskId);
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(0.0),
                                      ),
                                      color: Colors.black,
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      onPressed: () {
                                        Navigator.of(_navigatorContext).pop();
                                        Firestore.instance
                                            .collection(globals.flat)
                                            .document(_flatId)
                                            .collection(globals.tasks)
                                            .document(taskId).delete();

                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            );
          }),
        ));
  }

  void navigateToAddTask({taskId}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateTask(taskId, _flatId);
      }),
    );
  }

  Widget buildView(data) {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.title;
    //tc.text = taskId != null ? data["title"]: tc.text;

    return ListView(
      children: <Widget>[
        Text(
          data['title'],
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),
        Text(
          data['priority']==0?"Low":"High",
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),

        Text(
          data['type'],
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),
        Text(
          "Due - " + data['due'].toString(),
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),
        Text(
          data['completed']==true?"Completed":"Not Completed",
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),
        Text(
          "Created - " + data['created_at'].toString(),
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontFamily: 'Montserrat'),
        ),
        StreamBuilder(
          stream: Firestore.instance
              .collection(globals.user)
              .where('flat_id', isEqualTo: _flatId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LoadingContainerVertical(1);
            snapshot.data.documents.removeWhere((s) => !data['assignee'].toString().contains(s.documentID));
            if(snapshot.data.documents.length==0) return Text("Unassigned");
            return Container(
              padding: EdgeInsets.only(top: 5.0),
              height: 120.0,
              child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int position) {
                    return Padding(
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
                          color: Colors.white,
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
                    );
                  }),
            );
          },
        ),
        RaisedButton(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(0.0),
          ),
          child: Text(
            "History",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: 'Montserrat'),
          ),
          onPressed: () {
            _navigateToTaskHistory(taskId, _flatId);
          },
        ),
      ],
    );
  }

  _navigateToTaskHistory(taskId, flatId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return TaskHistory(taskId, _flatId);
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
