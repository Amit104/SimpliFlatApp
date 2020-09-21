import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:grouped_list/grouped_list.dart';

class Notice extends StatefulWidget {
  final _flatId;
  final _userId;
  final _lastUpdated;

  Notice(this._flatId, this._userId, this._lastUpdated);

  @override
  State<StatefulWidget> createState() {
    return NoticeBoard(_flatId, _userId, _lastUpdated);
  }
}

class NoticeBoard extends State<Notice> {
  final _flatId, currentUserId;
  var _navigatorContext;
  var _minimumPadding = 5.0;
  var date = DateFormat("yyyy-MM-dd");
  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  TextEditingController addNote = TextEditingController();
  var _lastUpdated;

  NoticeBoard(this._flatId, this.currentUserId, this._lastUpdated);

  @override
  void initState() {
    if (_lastUpdated == null) {
      setState(() {
        _lastUpdated = DateTime.now();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notices",
          style: TextStyle(
            color: Color(0xff373D4C),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xff373D4C),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection(globals.flat)
                      .document(_flatId)
                      .collection(globals.noticeBoard)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
                    if (!notesSnapshot.hasData)
                      return LoadingContainerVertical(3);
                    notesSnapshot.data.documents.sort(
                        (a, b) => b['created_at'].compareTo(a['created_at']));
                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: GroupedListView<dynamic, String>(
                        groupBy: (element) => date
                            .format((element['updated_at'] as Timestamp)
                                .toDate()
                                .toLocal())
                            .toString(),
                        sort: false,
                        elements: notesSnapshot.data.documents,
                        padding: EdgeInsets.only(top: 10.0),

                        separator: Divider(
                          height: 0.0,
                          thickness: 0.0,
                          color: Colors.white,
                        ),
                        groupSeparatorBuilder: (String value) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              child: new Text(getDateValue(value),
                                  style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.normal,
                                  )),
                              decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(0.0)),
                                  color: Color(0xffBFDAFF)),
                              padding:
                                  new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                            ),
                          ),
                        ),
                        itemBuilder: (BuildContext context, element) {
                          return _buildNoticeListItem(element);
                        },
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey1,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                      controller: addNote,
                      decoration: InputDecoration(
                        hintText: "New Note",
                        filled: true,
                        fillColor: Color(0xffBFDAFF),
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                        focusedBorder: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(
                            right: 8.0,
                            top: 3.0,
                            bottom: 3.0,
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Color(0xff2079FF), // button color
                              child: InkWell(
                                splashColor: Color(0xff2079FF),
                                // inkwell color
                                child: SizedBox(
                                    width: 45,
                                    height: 45,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    )),
                                onTap: () async {
                                  if (addNote.text == null || addNote.text.toString().trim() == "") {
                                    _addOrUpdateNote(
                                        _navigatorContext, 1); //1 is add
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String getDateValue(value) {
    var numToMonth = {
      1: 'JANUARY',
      2: 'FEBRUARY',
      3: 'MARCH',
      4: 'APRIL',
      5: 'MAY',
      6: 'JUNE',
      7: 'JULY',
      8: 'AUGUST',
      9: 'SEPTEMBER',
      10: 'OCTOBER',
      11: 'NOVEMBER',
      12: 'DECEMBER'
    };
    DateTime separatorDate = DateTime.parse(value);
    DateTime currentDate =
        DateTime.parse(date.format(DateTime.now().toLocal()).toString());
    String yesterday = date.format(
        DateTime(currentDate.year, currentDate.month, currentDate.day - 1));
    if (value == date.format(DateTime.now().toLocal()).toString()) {
      return "TODAY";
    } else if (value == yesterday) {
      return "YESTERDAY";
    } else {
      return separatorDate.day.toString() +
          " " +
          numToMonth[separatorDate.month.toInt()] +
          " " +
          separatorDate.year.toString();
    }
  }

  Widget _buildNoticeListItem(DocumentSnapshot notice) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    var datetime = (notice['created_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    var datetimeString = f.format(datetime);

    var userName = notice['user_name'] == null
        ? "User"
        : notice['user_name'].toString().trim();

    var color = notice['user_id'].toString().trim().hashCode;

    return Card(
      color: isNoteSynced(notice['updated_at'])
          ? Colors.grey[100]
          : Colors.white,
      elevation: 0.0,
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                  color:
                  (Colors.primaries[color % Colors.primaries.length]),
                  width: 5.0),
              bottom: BorderSide(
                color: Color(0xff373D4C),
                width: 0.5,
              ),
              top: BorderSide(
                color: Color(0xff373D4C),
                width: 0.5,
              ),
            ),
          ),
          child: Slidable(
            key: GlobalKey(),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            enabled: currentUserId.toString().trim() ==
                notice['user_id'].toString().trim(),
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
                      content: new Text(
                          'Are you sure you want to delete this notice?'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        new FlatButton(
                          child: new Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (actionType) {
                _deleteNote(context, notice.reference);
              },
            ),
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
                        content: new Text(
                            'Are you sure you want to delete this notice?'),
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
                    _deleteNote(context, notice.reference);
                    state.dismiss();
                  }
                },
              ),
            ],
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
              onTap: () {
                setState(() {
                  if (currentUserId == notice['user_id'].toString().trim())
                    note.text = notice['note'].toString().trim();
                });
                var dialogTitle =
                currentUserId == notice['user_id'].toString().trim()
                    ? "Edit Note"
                    : "Notice";
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
                      title: new Text(dialogTitle,
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontFamily: 'Montserrat',
                              fontSize: 18.0)),
                      content: Container(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height / 3,
                        child: currentUserId !=
                            notice['user_id'].toString().trim()
                            ? Text(notice['note'].toString().trim())
                            : Column(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    top: _minimumPadding,
                                    bottom: _minimumPadding),
                                child: TextFormField(
                                  keyboardType:
                                  TextInputType.multiline,
                                  maxLines: 6,
                                  minLines: 1,
                                  style: textStyle,
                                  controller: note,
                                  validator: (String value) {
                                    if (value.isEmpty)
                                      return "Cannot add empty note!";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Note",
                                    hintText:
                                    "Eg. Maid is not coming today",
                                    hintStyle:
                                    TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700),
                                    errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700),
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: _minimumPadding,
                                    bottom: _minimumPadding),
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: <Widget>[
                                      OutlineButton(
                                          shape:
                                          new RoundedRectangleBorder(
                                            borderRadius:
                                            new BorderRadius
                                                .circular(10.0),
                                            side: BorderSide(
                                              width: 1.0,
                                              color:
                                              Colors.indigo[900],
                                            ),
                                          ),
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          textColor: Colors.black,
                                          child: Text('Save',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.0,
                                                  fontFamily:
                                                  'Montserrat',
                                                  fontWeight:
                                                  FontWeight
                                                      .w700)),
                                          onPressed: () {
                                            debugPrint("UPDATE");
                                            if (_formKey2.currentState
                                                .validate()) {
                                              debugPrint("NOTEID IS" +
                                                  notice.documentID
                                                      .toString());
                                              _addOrUpdateNote(
                                                  context, 2,
                                                  noteReference:
                                                  notice
                                                      .reference);
                                              Navigator.of(context,
                                                  rootNavigator:
                                                  true)
                                                  .pop();
                                            }
                                          }),
                                      OutlineButton(
                                          shape:
                                          new RoundedRectangleBorder(
                                            borderRadius:
                                            new BorderRadius
                                                .circular(10.0),
                                            side: BorderSide(
                                              width: 1.0,
                                              color:
                                              Colors.indigo[900],
                                            ),
                                          ),
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          textColor: Colors.black,
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.0,
                                                  fontFamily:
                                                  'Montserrat',
                                                  fontWeight:
                                                  FontWeight
                                                      .w700)),
                                          onPressed: () {
                                            Navigator.of(context,
                                                rootNavigator:
                                                true)
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
            ),
          ),
        ),
      ),
    );
  }

  _addOrUpdateNote(scaffoldContext, addOrUpdate, {noteReference}) async {
    var timeNow = DateTime.now();
    var userId = await Utility.getUserId();
    var userName = await Utility.getUserName();
    if (addOrUpdate == 1) {
      /// add note
      var data = {
        'note': addNote.text.toString().trim(),
        'user_id': userId,
        'created_at': timeNow,
        'updated_at': timeNow,
        'user_name': userName
      };
      setState(() {
        addNote.text = '';
      });
      DocumentReference addNoteRef = Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.noticeBoard)
          .document();
      setNoteSynced(timeNow);
      addNoteRef.setData(data).then((v) {
        if (mounted)
          Utility.createErrorSnackBar(scaffoldContext, error: 'Note Saved');
      }, onError: (e) {
        debugPrint("ERROR IN UPDATE CONTACT VIEW");
        if (mounted) Utility.createErrorSnackBar(_navigatorContext);
      });
    } else {
      /// Update Note
      debugPrint("updated = " + note.text);
      var data = {
        'note': note.text.toString().trim(),
        'updated_at': timeNow,
        'user_name': userName
      };
      setNoteSynced(timeNow);
      Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.noticeBoard)
          .document(noteReference.documentID)
          .get()
          .then((freshNote) {
        if (freshNote == null) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        } else {
          Firestore.instance
              .collection(globals.flat)
              .document(_flatId)
              .collection(globals.noticeBoard)
              .document(freshNote.documentID)
              .updateData(data)
              .then((updated) {}, onError: (e) {
            if (mounted) Utility.createErrorSnackBar(_navigatorContext);
          });
        }
      }, onError: (e) {
        if (mounted) Utility.createErrorSnackBar(_navigatorContext);
      });
    }
  }

  _deleteNote(scaffoldContext, noticeReference) {
    Firestore.instance
        .collection(globals.flat)
        .document(_flatId)
        .collection(globals.noticeBoard)
        .document(noticeReference.documentID)
        .get()
        .then((freshNote) {
      if (freshNote == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        Firestore.instance
            .collection(globals.flat)
            .document(_flatId)
            .collection(globals.noticeBoard)
            .document(freshNote.documentID)
            .delete()
            .then((deleted) {
          if (mounted)
            Utility.createErrorSnackBar(context, error: "Note Deleted");
        }, onError: (e) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      }
    }, onError: (e) {
      if (mounted) Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  Future<Null> _handleRefresh() async {
    setNoteSynced(DateTime.now());
    return null;
  }

  bool isNoteSynced(var datetime) {
    if ((datetime as Timestamp)
            .toDate()
            .difference(_lastUpdated)
            .inMilliseconds >
        0) return true;
    return false;
  }

  void setNoteSynced(DateTime datetime) {
    if (mounted) {
      setState(() {
        _lastUpdated = datetime;
      });
    }
    Utility.addToSharedPref(noticeboardLastUpdated: datetime);
  }
}
