import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

class TaskHistory extends StatefulWidget {
  final taskId;
  final _flatId;
  final isTenantPortal;

  TaskHistory(this.taskId, this._flatId, this.isTenantPortal);

  @override
  State<StatefulWidget> createState() {
    return _TaskHistory(this.taskId, this._flatId, this.isTenantPortal);
  }
}

class _TaskHistory extends State<TaskHistory> {
  final taskId;
  final _flatId;
  var _navigatorContext;
  String collectionname;
  bool isTenantPortal;

  _TaskHistory(this.taskId, this._flatId, this.isTenantPortal) {
    collectionname = isTenantPortal
        ? 'tasks_' + globals.landlordIdValue
        : collectionname = 'tasks';
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
            title: Text("History"),
            elevation: 0.0,
            centerTitle: true,
          ),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(globals.flat)
                    .document(_flatId)
                    .collection(collectionname)
                    .document(taskId)
                    .collection(globals.taskHistory)
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> historySnapshot) {
                  if (!historySnapshot.hasData)
                    return LoadingContainerVertical(3);
                  historySnapshot.data.documents.sort(
                      (a, b) => b['created_at'].compareTo(a['created_at']));
                  return ListView.builder(
                      itemCount: historySnapshot.data.documents.length,
                      key: UniqueKey(),
                      itemBuilder: (BuildContext context, int position) {
                        return _buildHistoryListItem(
                            historySnapshot.data.documents[position], position);
                      });
                },
              ),
            );
          }),
        ));
  }

  Widget _buildHistoryListItem(DocumentSnapshot document, int index) {
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
    var datetime = (document['created_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = datetime.day.toString() +
        " " +
        numToMonth[datetime.month.toInt()] +
        " " +
        datetime.year.toString() +
        " - " +
        f.format(datetime);

    // TODO - username update in collection must be done by a cloud function for consistency
    var userName = document['user_name'].toString().trim();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Dismissible(
            key: Key(index.toString()),
            background: CommonWidgets.swipeBackground(),
            onDismissed: (direction) {
              _deleteItem(context, document.reference);
            },
            child: ListTile(
              leading: Icon(Icons.history),
              title: userName == ""
                  ? "<Holder>"
                  : Text(userName,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      )),
              subtitle: Padding(
                child: Text(datetimeString,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black45,
                    )),
                padding: EdgeInsets.only(top: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteItem(BuildContext context, DocumentReference reference) {
    Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection(collectionname)
        .document(taskId)
        .collection(globals.taskHistory)
        .document(reference.documentID)
        .delete()
        .then((freshNote) {
      if (mounted) Utility.createErrorSnackBar(context, error: "Deleted!");
    }, onError: (e) {
      if (mounted) Utility.createErrorSnackBar(_navigatorContext);
    });
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
