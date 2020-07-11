import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:simpliflat/screens/models/DatabaseHelper.dart';
import 'package:grouped_list/grouped_list.dart';

// TODO - show username with note
class Notice extends StatefulWidget {
  final _flatId;
  final _userId;
  final _offlineDocuments;

  Notice(this._flatId, this._userId, this._offlineDocuments);

  @override
  State<StatefulWidget> createState() {
    return NoticeBoard(_flatId, _userId, _offlineDocuments);
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
  List<Map<String, dynamic>> _offlineDocuments;
  List<String> _readDocuments = new List();

  final dbHelper = DatabaseHelper.instance;

  NoticeBoard(this._flatId, this.currentUserId, this._offlineDocuments);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (var doc in _offlineDocuments) {
      _readDocuments.add(doc[DatabaseHelper.documentID]);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notices"),
        centerTitle: true,
        elevation: 0.0,
      ),
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
                            .format((element['created_at'] as Timestamp)
                                .toDate()
                                .toLocal())
                            .toString(),
                        sort: false,
                        elements: notesSnapshot.data.documents,
                        groupSeparatorBuilder: (String value) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              child: new Text(getDateValue(value),
                                  style: new TextStyle(
                                      color: Colors.red[900],
                                      fontSize: 14.0,
                                      fontFamily: 'Robato')),
                              decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(6.0)),
                                  color: Colors.red[100]),
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
                  padding: EdgeInsets.only(
                    bottom: 10.0,
                    top: 5.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10.0),
                      ),
                      Expanded(
                        child: Form(
                          key: _formKey1,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontFamily: 'Montserrat',
                            ),
                            controller: addNote,
                            validator: (String value) {
                              if (value.isEmpty)
                                return "Cannot add empty note!";
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Add Note...",
                              hintStyle: TextStyle(color: Colors.black87),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              ),
                              errorStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700),
                              //border: InputBorder.none
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.red[900], // button color
                          child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  Icons.add,
                                )),
                            onTap: () async {
                              if (_formKey1.currentState.validate()) {
                                _addOrUpdateNote(
                                    _navigatorContext, 1); //1 is add
                              }
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                      ),
                    ],
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
    if (!isOffline(notice.documentID)) {
      Map<String, dynamic> row = {
        DatabaseHelper.documentID: notice.documentID,
        DatabaseHelper.isSynced: 1,
        DatabaseHelper.type: globals.noticeBoard
      };
      _insertDB(row);
    }
    var datetime = (notice['created_at'] as Timestamp).toDate();
    final f = new DateFormat.jm();
    //var datetimeString = datetime.day.toString() + " " + numToMonth[datetime.month.toInt()] + " " +
    //    datetime.year.toString() + " - " + f.format(datetime);
    var datetimeString = f.format(datetime);

    var userName = notice['user_name'] == null
        ? ""
        : notice['user_name'].toString().trim();

    var color = notice['user_id'].toString().trim().hashCode;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          color: isNotSynced(
                  notice.documentID) //_notSynced.contains(notice.documentID)
              ? Colors.grey[100]
              : Colors.white,
          elevation: 1.0,
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
                    child: Text(userName,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                          color:
                              Colors.primaries[color % Colors.primaries.length],
                        )),
                    padding: EdgeInsets.only(bottom: 5.0),
                  ),
                  Text(notice['note'].toString().trim(),
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
              trailing: isRead(notice.documentID)
                  ? null
                  : Icon(Icons.radio_button_checked),
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
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 2,
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
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            OutlineButton(
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                textColor: Colors.black,
                                                child: Text('Save',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                onPressed: () {
                                                  debugPrint("UPDATE");
                                                  if (_formKey2.currentState
                                                      .validate()) {
                                                    debugPrint("NOTEID IS" +
                                                        notice.documentID
                                                            .toString());
                                                    _addOrUpdateNote(context, 2,
                                                        noteReference:
                                                            notice.reference);
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  }
                                                }),
                                            OutlineButton(
                                                shape:
                                                    new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          10.0),
                                                  side: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                textColor: Colors.black,
                                                child: Text('Cancel',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w700)),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
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
    if (_offlineDocuments == null) {
      await _query();
    }
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
      setNoteSynced(addNoteRef.documentID);
      addNoteRef.setData(data).then((v) {
        if (mounted)
          Utility.createErrorSnackBar(scaffoldContext, error: 'Note Saved');
        removeNoteSynced(addNoteRef.documentID);
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
      setNoteSynced(noteReference.documentID);
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
              .then((updated) {
            removeNoteSynced(noteReference.documentID);
          }, onError: (e) {
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
          _deleteDB(noticeReference.documentID);
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

  void setNoteSynced(documentID) async {
    Map<String, dynamic> row = {
      DatabaseHelper.documentID: documentID,
      DatabaseHelper.isSynced: 0,
      DatabaseHelper.type: globals.noticeBoard
    };
    if (mounted) {
      setState(() {
        if (!_readDocuments.contains(documentID))
          _readDocuments.add(documentID);
        if (isOffline(documentID)) {
          _updateDB(row);
        } else {
          _insertDB(row);
        }
        _query();
      });
    } else {
      if (!_readDocuments.contains(documentID)) _readDocuments.add(documentID);
      if (isOffline(documentID)) {
        _updateDB(row);
      } else {
        _insertDB(row);
      }
      _query();
    }
  }

  void removeNoteSynced(documentID) async {
    Map<String, dynamic> row = {
      DatabaseHelper.documentID: documentID,
      DatabaseHelper.isSynced: 1,
      DatabaseHelper.type: globals.noticeBoard
    };

    if (mounted) {
      setState(() {
        _updateDB(row);
        _query();
      });
    } else {
      _updateDB(row);
      _query();
    }
  }

  Future<Null> _handleRefresh() async {
    List<String> toRemove = new List();

    try {
      await Firestore.instance.runTransaction((transaction) async {
        for (var doc in _offlineDocuments) {
          debugPrint('pppp' + doc[DatabaseHelper.documentID]);
          if (doc[DatabaseHelper.isSynced] == 0) {
            var document = await transaction.get(Firestore.instance
                .collection(globals.flat)
                .document(_flatId)
                .collection(globals.noticeBoard)
                .document(doc[DatabaseHelper.documentID]));
            if (document.exists) toRemove.add(doc[DatabaseHelper.documentID]);
          }
        }
      });
    } catch (e) {}

    for (var doc in toRemove) {
      Map<String, dynamic> row = {
        DatabaseHelper.documentID: doc,
        DatabaseHelper.isSynced: 0,
        DatabaseHelper.type: globals.noticeBoard
      };
      debugPrint('TEEEE - ' + doc);
      _updateDB(row);
    }

    if (mounted) {
      setState(() {
        _query();
        _readDocuments.clear();
        for (var doc in _offlineDocuments) {
          _readDocuments.add(doc[DatabaseHelper.documentID]);
        }
      });
    }

    return null;
  }

  void _query() async {
    _offlineDocuments = await dbHelper.queryRows(globals.noticeBoard);
  }

  void _updateDB(row) async {
    await dbHelper.update(row);
  }

  void _insertDB(row) async {
    await dbHelper.insert(row);
  }

  void _deleteDB(documentID) async {
    await dbHelper.delete(documentID);
  }

  bool isNotSynced(documentID) {
    for (Map<String, dynamic> m in _offlineDocuments) {
      if (m[DatabaseHelper.documentID] == documentID) {
        if (m[DatabaseHelper.isSynced] == 0) return true;
        return false;
      }
    }
    return false;
  }

  bool isOffline(documentID) {
    for (Map<String, dynamic> m in _offlineDocuments) {
      if (m[DatabaseHelper.documentID] == documentID) return true;
    }
    return false;
  }

  bool isRead(documentID) {
    return _readDocuments.contains(documentID);
  }
}
