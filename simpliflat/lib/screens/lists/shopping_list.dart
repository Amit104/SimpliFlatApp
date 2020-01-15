import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

import '../utility.dart';
import 'list_items.dart';

class ShoppingLists extends StatefulWidget {
  final flatId;

  ShoppingLists(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return ShoppingListsState(this.flatId);
  }
}

class ShoppingListsState extends State<ShoppingLists> {
  var _navigatorContext;
  List lists;
  TextEditingController addListController = TextEditingController();
  var _formKey1 = GlobalKey<FormState>();
  TextEditingController listController = TextEditingController();
  var _formKey2 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  TextEditingController textField = TextEditingController();
  final flatId;

  ShoppingListsState(this.flatId);

  @override
  void initState() {
    super.initState();
  }

  Widget getLists() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.lists)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        lists = [];
        if (!snapshot.hasData) return LoadingContainerVertical(3);
        if (snapshot.data.documents.length == 0)
          return Container(
            child: CommonWidgets.textBox("Add Lists here", 22),
          );
        snapshot.data.documents
            .sort((a, b) => b['created_at'].compareTo(a['created_at']));
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int position) {
              return _buildListItem(
                  snapshot.data.documents[position], position);
            });
      },
    );
  }

  Widget _buildListItem(DocumentSnapshot list, index) {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.subhead;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width * 0.85,
        child: Card(
          color: Colors.white,
          elevation: 1.0,
          child: Slidable(
            key: Key(index.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
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
                          'Are you sure you want to delete this list?'),
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
                _deleteList(_navigatorContext, list.reference);
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
                        content: new Text('Are you sure you want to delete this list?'),
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
                    _deleteList(_navigatorContext, list.reference);
                    state.dismiss();
                  }
                },
              ),
            ],
            child: ListTile(
              title: Text(list['title'].toString().trim(),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  )),
              trailing: GestureDetector(
                child: Icon(Icons.edit),
                onTap: () {
                  setState(() {
                    listController.text = list['title'].toString().trim();
                  });
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
                        title: new Text("Edit List Title",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: 16.0)),
                        content: Container(
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height / 3,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: _minimumPadding,
                                      bottom: _minimumPadding),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    style: textStyle,
                                    controller: listController,
                                    validator: (String value) {
                                      if (value.isEmpty)
                                        return "Cannot add empty name!";
                                      if (value.length > 25) return "Too long!";
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        labelText: "Title",
                                        hintText: "Eg. Groceries",
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
                                        border: InputBorder.none),
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
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0),
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
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            onPressed: () {
                                              debugPrint("UPDATE");
                                              if (_formKey2.currentState
                                                  .validate()) {
                                                debugPrint("LISTID IS" +
                                                    list.documentID.toString());
                                                _addOrUpdateList(context, 2,
                                                    listReference:
                                                        list.reference);
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              }
                                            }),
                                        OutlineButton(
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      10.0),
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
              onTap: () {
                Navigator.push(
                  _navigatorContext,
                  MaterialPageRoute(builder: (context) {
                    return ListItems(list, flatId);
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  _addOrUpdateList(scaffoldContext, addOrUpdate, {listReference}) async {
    var timeNow = DateTime.now();
    var userId = await Utility.getUserId();
    if (addOrUpdate == 1) {
      /// add list
      var data = {
        'title': addListController.text.toString().trim(),
        'user_id': userId,
        'created_at': timeNow,
        'updated_at': timeNow,
        'items': []
      };
      setState(() {
        addListController.text = '';
      });
      Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.lists)
          .add(data)
          .then((v) {
        if (mounted)
          Utility.createErrorSnackBar(scaffoldContext, error: 'List Added');
      }, onError: (e) {
        if (mounted) Utility.createErrorSnackBar(_navigatorContext);
      });
    } else {
      /// Update list
      var data = {
        'title': listController.text.toString().trim(),
        'updated_at': timeNow
      };
      Firestore.instance
          .collection(globals.flat)
          .document(flatId)
          .collection(globals.lists)
          .document(listReference.documentID)
          .get()
          .then((freshNote) {
        if (freshNote == null) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        } else {
          Firestore.instance
              .collection(globals.flat)
              .document(flatId)
              .collection(globals.lists)
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

  _deleteList(scaffoldContext, listReference) {
    Firestore.instance
        .collection(globals.flat)
        .document(flatId)
        .collection(globals.lists)
        .document(listReference.documentID)
        .get()
        .then((freshNote) {
      if (freshNote == null) {
        Utility.createErrorSnackBar(_navigatorContext);
      } else {
        Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .collection(globals.lists)
            .document(freshNote.documentID)
            .delete()
            .then((deleted) {
          if (mounted)
            Utility.createErrorSnackBar(context, error: "List Deleted");
        }, onError: (e) {
          if (mounted) Utility.createErrorSnackBar(_navigatorContext);
        });
      }
    }, onError: (e) {
      if (mounted) Utility.createErrorSnackBar(_navigatorContext);
    });
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
          title: Text("Lists"),
          elevation: 0.0,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  addList(_navigatorContext);
                })
          ],
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Column(
            children: <Widget>[
              Expanded(
                child: getLists(),
              ),
            ],
          );
        }),
      ),
    );
  }

  String openGateValidator(String name) {
    return null;
  }

  void addList(context) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    setState(() {
      addListController.text = "";
    });
    showDialog(
      context: context,
      builder: (_) => new Form(
        key: _formKey1,
        child: AlertDialog(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
            side: BorderSide(
              width: 1.0,
              color: Colors.indigo[900],
            ),
          ),
          title: new Text("Add List",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 16.0)),
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height / 3,
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        top: _minimumPadding, bottom: _minimumPadding),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      style: textStyle,
                      controller: addListController,
                      validator: (String value) {
                        if (value.isEmpty) return "Cannot add empty name!";
                        if (value.length > 25) return "Too long!";
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Eg. Groceries",
                          hintStyle: TextStyle(color: Colors.grey),
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
                          border: InputBorder.none),
                    )),
                Padding(
                    padding: EdgeInsets.only(
                        top: _minimumPadding, bottom: _minimumPadding),
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
                                debugPrint("ADD");
                                if (_formKey1.currentState.validate()) {
                                  _addOrUpdateList(context, 1);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
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
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
