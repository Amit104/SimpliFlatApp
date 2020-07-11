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

class MessageBoard extends StatefulWidget {
  final _flatId;

  MessageBoard(this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _MessageBoard(_flatId);
  }
}

class _MessageBoard extends State<MessageBoard> {
  final _flatId;
  var currentUserId;
  var _navigatorContext;
  var _minimumPadding = 5.0;
  var date = DateFormat("yyyy-MM-dd");
  var _formKey1 = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  TextEditingController addNote = TextEditingController();

  _MessageBoard(this._flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Board"),
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
                      .collection(globals.messageBoard)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> notesSnapshot) {
                    Utility.getUserId().then((id) {
                      setState(() {
                        currentUserId = id;
                      });
                    });
                    if (!notesSnapshot.hasData || currentUserId == null)
                      return LoadingContainerVertical(3);
                    notesSnapshot.data.documents.sort(
                        (a, b) => b['created_at'].compareTo(a['created_at']));
                    return GroupedListView<dynamic, String>(
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
                              hintText: "Add Message...",
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
                            splashColor: Colors.indigo, // inkwell color
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
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: new Key(notice.documentID.toString()),
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
                  Text(notice['message'].toString().trim(),
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
              onTap: () {
                setState(() {
                  if (currentUserId == notice['user_id'].toString().trim())
                    note.text = notice['message'].toString().trim();
                });
                var dialogTitle =
                    currentUserId == notice['user_id'].toString().trim()
                        ? "Edit Message"
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
                            ? Text(notice['message'].toString().trim())
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
                                                    debugPrint("MESSAGEID IS" +
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
    if (addOrUpdate == 1) {
      /// add Message
      var data = {
        'message': addNote.text.toString().trim(),
        'user_id': userId,
        'created_at': timeNow,
        'updated_at': timeNow,
        'user_name': userName,
        'is_created_by_tenant': 1
      };
      setState(() {
        addNote.text = '';
      });
      DocumentReference addNoteRef = Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.messageBoard)
          .document();
      addNoteRef.setData(data).then((v) {
        if (mounted)
          Utility.createErrorSnackBar(scaffoldContext, error: 'Message Saved');
      }, onError: (e) {
        debugPrint("ERROR IN UPDATE CONTACT VIEW");
        if (mounted) Utility.createErrorSnackBar(_navigatorContext);
      });
    } else {
      /// Update Message
      debugPrint("updated = " + note.text);
      var data = {
        'message': note.text.toString().trim(),
        'updated_at': timeNow,
        'user_name': userName
      };
      Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.messageBoard)
          .document(noteReference.documentID)
          .get()
          .then((freshNote) {
        if (freshNote == null) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        } else {
          Firestore.instance
              .collection(globals.flat)
              .document(_flatId)
              .collection(globals.messageBoard)
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
        .collection(globals.messageBoard)
        .document(noticeReference.documentID)
        .get()
        .then((freshNote) {
      if (freshNote == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        Firestore.instance
            .collection(globals.flat)
            .document(_flatId)
            .collection(globals.messageBoard)
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
}
