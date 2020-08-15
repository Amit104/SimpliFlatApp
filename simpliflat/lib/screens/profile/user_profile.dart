import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/models/models.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:simpliflat/screens/profile/profile_options.dart';
import 'package:url_launcher/url_launcher.dart';

import '../about.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserProfile();
  }
}

class _UserProfile extends State<UserProfile> {
  var _navigatorContext;
  var _minimumPadding = 5.0;
  var _flatId;
  List contactList;
  String userName;
  String userPhone;
  double contactHeight = 0;
  List existingUsers;
  List noteList;
  List addUsersRequests;
  int addUserRequestCount;
  int contactsCount;
  int noteCount;
  int usersCount;
  var _isButtonDisabled = false;
  var _formKey1 = GlobalKey<FormState>();
  var _progressCircleState = 0;
  String flatName = "";
  String displayId = "";

  TextEditingController contactName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController addUserForm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
  }

  void initLists() async {
    await _getFromSharedPref();

    if (this.existingUsers == null) {
      existingUsers = new List();
      _updateUsersView();
    }

    if (this.addUserRequestCount == null) {
      addUsersRequests = new List();
      _updateAddUserView();
    }

    _updateUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    initLists();
    fetchFlatName(context);
    var deviceSize = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline;
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    Utility.getFlatName().then((name) {
      if (name != null) {
        setState(() {
          flatName = name;
        });
      } else {
        setState(() {
          flatName = "Hey there!";
        });
      }
    });

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return null;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              Strings.profileAppBar,
              style: TextStyle(color: Colors.indigo[900]),
            ),
            elevation: 2.0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.indigo,
              ),
              onPressed: () {
                Utility.navigateToProfileOptions(context);
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.indigo,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => About()),
                  );
                },
              ),
            ],
          ),
          body: Builder(builder: (BuildContext scaffoldC) {
            _navigatorContext = scaffoldC;
            return new Center(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: _minimumPadding * 2,
                        left: _minimumPadding * 2,
                        right: _minimumPadding * 2),
                    child: ListView(
                      children: <Widget>[
                        // Flat members
                        Row(
                          children: <Widget>[
                            Expanded(flex: 1, child: Container()),
                            Text(
                              "Flat Members",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                              ),
                            ),
                            Expanded(flex: 9, child: Container()),
                            Container(
                              child: ButtonTheme(
                                minWidth: 40.0,
                                height: 30.0,
                                child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(40.0),
                                      side: BorderSide(
                                        width: 0.5,
                                        color: Colors.indigo[900],
                                      ),
                                    ),
                                    color: Colors.white,
                                    textColor:
                                        Theme.of(context).primaryColorDark,
                                    child: Icon(Icons.group_add,
                                        color: Colors.black),
                                    onPressed: () {
                                      setState(() {
                                        contactName.text = '';
                                        phone.text = '';
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (_) => new Form(
                                              key: _formKey1,
                                              child: AlertDialog(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(10.0),
                                                    side: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.indigo[900],
                                                    ),
                                                  ),
                                                  title: new Text(
                                                      "Add New User",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 16.0)),
                                                  content: Container(
                                                    width: double.maxFinite,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                top:
                                                                    _minimumPadding,
                                                                bottom:
                                                                    _minimumPadding),
                                                            child:
                                                                TextFormField(
                                                              autofocus: true,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: textStyle,
                                                              controller:
                                                                  addUserForm,
                                                              validator: (String
                                                                  value) {
                                                                if (value
                                                                    .isEmpty)
                                                                  return "Please enter Phone number ";
                                                                return null;
                                                              },
                                                              decoration: InputDecoration(
                                                                  labelText:
                                                                      "Phone Number",
                                                                  labelStyle: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          16.0,
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  hintText:
                                                                      "9005489765",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          color: Colors
                                                                              .grey),
                                                                  errorStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          12.0,
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            )),
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                top:
                                                                    _minimumPadding,
                                                                bottom:
                                                                    _minimumPadding),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  OutlineButton(
                                                                      shape:
                                                                          new RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            new BorderRadius.circular(10.0),
                                                                        side:
                                                                            BorderSide(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              Colors.indigo[900],
                                                                        ),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      textColor:
                                                                          Colors
                                                                              .black,
                                                                      child: Text(
                                                                          'Add',
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 14.0,
                                                                              fontFamily: 'Montserrat',
                                                                              fontWeight: FontWeight.w700)),
                                                                      onPressed: () {
                                                                        if (_formKey1.currentState.validate() &&
                                                                            _isButtonDisabled ==
                                                                                false) {
                                                                          setState(
                                                                              () {
                                                                            debugPrint("STARTING API CALL");
                                                                          });
                                                                          _addUserToFlat(
                                                                              addUserForm.text);
                                                                          addUserForm
                                                                              .clear();
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .pop();
                                                                        }
                                                                      }),
                                                                  OutlineButton(
                                                                      shape:
                                                                          new RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            new BorderRadius.circular(10.0),
                                                                        side:
                                                                            BorderSide(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              Colors.indigo[900],
                                                                        ),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      textColor:
                                                                          Colors
                                                                              .black,
                                                                      child: Text(
                                                                          'Cancel',
                                                                          style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 14.0,
                                                                              fontFamily: 'Montserrat',
                                                                              fontWeight: FontWeight.w700)),
                                                                      onPressed: () {
                                                                        Navigator.of(context,
                                                                                rootNavigator: true)
                                                                            .pop();
                                                                      })
                                                                ]))
                                                      ],
                                                    ),
                                                  ))));
                                    }),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 2.0),
                          height: 100.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  blurRadius: 1,
                                  offset: Offset(0, 4), // changes position of shadow
                                ),
                              ],
                              border: Border.all(width: 1.0, color: Colors.grey[300])),
                          child: (existingUsers == null ||
                                  existingUsers.length == 0)
                              ? LoadingContainerHorizontal(
                                  MediaQuery.of(context).size.height / 10 -
                                      10.0)
                              : _getExistingUsers(),
                        ),

                        //Your Requests
                        Row(
                          children: (addUsersRequests == null ||
                                  addUsersRequests.length == 0)
                              ? <Widget>[Container(margin: EdgeInsets.all(0.0))]
                              : <Widget>[
                                  Expanded(child: Container()),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 6.0),
                                    child: Text("Your Requests",
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
                          padding: EdgeInsets.only(top: 7.0),
                          height: (addUsersRequests == null ||
                                  addUsersRequests.length == 0)
                              ? 0.0
                              : 118.0,
                          color: Colors.white,
                          child: (addUsersRequests == null ||
                                  addUsersRequests.length == 0)
                              ? null
                              : _getExistingAddUserRequests(),
                        ),

                        // options list
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(flex: 1, child: Container()),
                            Text(
                              "Flat Contacts",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                              ),
                            ),
                            Expanded(flex: 10, child: Container()),
                            Container(
                              child: ButtonTheme(
                                minWidth: 40.0,
                                height: 27.0,
                                child: RaisedButton(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(40.0),
                                      side: BorderSide(
                                        width: 0.5,
                                        color: Colors.indigo[900],
                                      ),
                                    ),
                                    color: Colors.white,
                                    textColor:
                                        Theme.of(context).primaryColorDark,
                                    child: Icon(Icons.person_add,
                                        color: Colors.black),
                                    onPressed: () {
                                      setState(() {
                                        contactName.text = '';
                                        phone.text = '';
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (_) => new Form(
                                              key: _formKey1,
                                              child: AlertDialog(
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
                                                title: new Text("Add contact",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 16.0)),
                                                content: Container(
                                                    width: double.maxFinite,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2.5,
                                                    child: ListView(
                                                      children: <Widget>[
                                                        TextFormField(
                                                          autofocus: true,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          style: textStyle,
                                                          controller:
                                                              contactName,
                                                          validator:
                                                              (String value) {
                                                            if (value.isEmpty)
                                                              return "Please enter Name";
                                                            if (value.length >
                                                                20)
                                                              return "Name too long!!";
                                                            return null;
                                                          },
                                                          decoration: InputDecoration(
                                                              labelText:
                                                                  "Contact Name",
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      13.0,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              hintText: "Maid",
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              errorStyle: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.0,
                                                                    bottom:
                                                                        10.0),
                                                            child:
                                                                TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: textStyle,
                                                              controller: phone,
                                                              validator: (String
                                                                  value) {
                                                                if (value
                                                                    .isEmpty)
                                                                  return "Please enter Phone Number";
                                                                if (value
                                                                        .length !=
                                                                    10)
                                                                  return "Please enter valid 10 digit number";
                                                                return null;
                                                              },
                                                              decoration: InputDecoration(
                                                                  labelText:
                                                                      "Phone Number",
                                                                  labelStyle: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          13.0,
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  hintText:
                                                                      "9005489765",
                                                                  hintStyle:
                                                                      TextStyle(
                                                                          color: Colors
                                                                              .grey),
                                                                  errorStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          12.0,
                                                                      fontFamily:
                                                                          'Montserrat',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                            )),
                                                        Padding(
                                                            padding: EdgeInsets.only(
                                                                top:
                                                                    _minimumPadding,
                                                                bottom:
                                                                    _minimumPadding),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <
                                                                    Widget>[
                                                                  OutlineButton(
                                                                      shape:
                                                                          new RoundedRectangleBorder(
                                                                              borderRadius: new BorderRadius.circular(
                                                                                  10.0),
                                                                              side:
                                                                                  BorderSide(
                                                                                width: 1.0,
                                                                                color: Colors.indigo[900],
                                                                              )),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      textColor:
                                                                          Colors
                                                                              .blue,
                                                                      child: Text(
                                                                          'Save',
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 14.0,
                                                                              fontFamily: 'Montserrat',
                                                                              fontWeight: FontWeight.w700)),
                                                                      onPressed: () {
                                                                        if (_formKey1
                                                                            .currentState
                                                                            .validate()) {
                                                                          setState(
                                                                              () {});
                                                                          _addOrUpdateFlatContact(
                                                                              _navigatorContext,
                                                                              1); //1 is add
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .pop();
                                                                        }
                                                                      }),
                                                                  OutlineButton(
                                                                      shape:
                                                                          new RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            new BorderRadius.circular(10.0),
                                                                        side:
                                                                            BorderSide(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              Colors.indigo[900],
                                                                        ),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      textColor:
                                                                          Colors
                                                                              .black,
                                                                      child: Text(
                                                                          'Cancel',
                                                                          style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 14.0,
                                                                              fontFamily: 'Montserrat',
                                                                              fontWeight: FontWeight.w700)),
                                                                      onPressed: () {
                                                                        Navigator.of(context,
                                                                                rootNavigator: true)
                                                                            .pop();
                                                                      })
                                                                ]))
                                                      ],
                                                    )),
                                              )));
                                    }),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                          ],
                        ),
                        Container(
                          color: Colors.white,
                          height: contactHeight,
                          child: getContacts(context),
                        ),
                      ],
                    )));
          })),
    );
  }

  _addOrUpdateFlatContact(scaffoldContext, addOrUpdate, {phoneExisting}) {
    var flatContactName = contactName.text;
    var contactPhone = "+91" + phone.text.replaceFirst("+91", "");
    var timeNow = DateTime.now();
    if (_flatId == null || _flatId == "") _getFromSharedPref();
    if (addOrUpdate == 1) {
      Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.flatContacts)
          .where("phone", isEqualTo: contactPhone)
          .limit(1)
          .getDocuments()
          .then((contact) {
        if (contact == null || contact.documents.length == 0) {
          var data = {
            "created_at": timeNow,
            "name": flatContactName,
            "phone": contactPhone,
            "updated_at": timeNow
          };
          Firestore.instance
              .collection(globals.flat)
              .document(_flatId)
              .collection(globals.flatContacts)
              .add(data)
              .then((addedContact) {
            Utility.createErrorSnackBar(scaffoldContext,
                error: 'Contact Saved');
          }, onError: (e) {
            Utility.createErrorSnackBar(scaffoldContext);
          });
        } else {
          Utility.createErrorSnackBar(scaffoldContext,
              error: 'Contact already exists!');
        }
      }, onError: (e) {
        Utility.createErrorSnackBar(scaffoldContext);
      });
    } else {
      Firestore.instance
          .collection(globals.flat)
          .document(_flatId)
          .collection(globals.flatContacts)
          .where("phone", isEqualTo: phoneExisting.trim())
          .limit(1)
          .getDocuments()
          .then((contact) {
        if (contact == null || contact.documents.length == 0) {
          Utility.createErrorSnackBar(scaffoldContext);
        } else {
          var data = {
            "name": flatContactName,
            "phone": contactPhone,
            "updated_at": timeNow
          };
          Firestore.instance
              .collection(globals.flat)
              .document(_flatId)
              .collection(globals.flatContacts)
              .document(contact.documents[0].documentID)
              .updateData(data)
              .then((addedContact) {
            Utility.createErrorSnackBar(scaffoldContext,
                error: 'Contact Saved');
          }, onError: (e) {
            Utility.createErrorSnackBar(scaffoldContext);
          });
        }
      }, onError: (e) {
        Utility.createErrorSnackBar(scaffoldContext);
      });
    }
  }

  // TODO get latest request first
  _addUserToFlat(phonenum) async {
    debugPrint(phonenum.toString());
    await _getFromSharedPref();
    setState(() {
      _isButtonDisabled = true;
      _progressCircleState = 1;
    });

    var phone = "+91" + phonenum.replaceFirst("+91", "");

    Firestore.instance
        .collection("user")
        .where("phone", isEqualTo: phone)
        .getDocuments()
        .then((user) {
      if (user == null || user.documents.length == 0) {
        Utility.createErrorSnackBar(_navigatorContext,
            error: "User does not exist!");
        _enableButton();
      } else {
        var data = user.documents[0].data;
        if (data["flat_id"] != null && data["flat_id"] != "") {
          _enableButton();
          Utility.createErrorSnackBar(_navigatorContext,
              error:
                  "User already is in a flat. Ask the user to leave the other flat and try again!");
        } else {
          var timeNow = DateTime.now();
          var dataJson = {
            "user_id": user.documents[0].documentID,
            "flat_id": _flatId,
            "status": 0,
            "request_from_flat": 1,
            "created_at": timeNow,
            "updated_at": timeNow
          };
          var updateJson = {
            "user_id": user.documents[0].documentID,
            "flat_id": _flatId,
            "status": 0,
            "request_from_flat": 1,
            "updated_at": timeNow
          };
          Firestore.instance
              .collection("joinflat")
              .where("user_id", isEqualTo: user.documents[0].documentID)
              .where("flat_id", isEqualTo: _flatId)
              .where("request_from_flat", isEqualTo: 0)
              .where("status", isEqualTo: 0)
              .getDocuments()
              .then((requests) {
            if (requests == null || requests.documents.length == 0) {
              debugPrint("USER REQUEST NULL");
              Firestore.instance
                  .collection("joinflat")
                  .where("user_id", isEqualTo: user.documents[0].documentID)
                  .where("flat_id", isEqualTo: _flatId)
                  .where("request_from_flat", isEqualTo: 1)
                  .getDocuments()
                  .then((requestsFromFlat) {
                if (requestsFromFlat == null ||
                    requestsFromFlat.documents.length == 0) {
                  debugPrint("USER REQUEST NULL ADD");
                  Firestore.instance.collection("joinflat").add(dataJson).then(
                      (addedRequest) {
                    var newUserRequest = FlatAddUsersResponse(
                        userId: user.documents[0].documentID,
                        name: data["name"],
                        phone: phone,
                        createdAt: timeNow,
                        updatedAt: timeNow);
                    setState(() {
                      if (addUsersRequests == null) {
                        addUsersRequests = new List();
                        addUserRequestCount = 0;
                      }
                      addUsersRequests.add(newUserRequest);
                      addUsersRequests.sort(
                          (a, b) => b.getUpdatedAt.compareTo(a.getUpdatedAt));
                      addUserRequestCount++;
                    });
                    _enableButton();
                    Utility.createErrorSnackBar(_navigatorContext,
                        error: "Success!");
                  }, onError: (e) {
                    Utility.createErrorSnackBar(_navigatorContext);
                    _enableButton();
                  });
                } else {
                  debugPrint("USER REQUEST NULL CREATE");
                  Firestore.instance
                      .collection("joinflat")
                      .document(requestsFromFlat.documents[0].documentID)
                      .updateData(updateJson)
                      .then((addedRequest) {
                    var newUserRequest = FlatAddUsersResponse(
                        userId: user.documents[0].documentID,
                        name: data["name"],
                        phone: phone,
                        createdAt:
                            requestsFromFlat.documents[0].data["created_at"],
                        updatedAt: timeNow);
                    if (requestsFromFlat.documents[0].data["status"] != 0) {
                      setState(() {
                        addUsersRequests.add(newUserRequest);
                        addUsersRequests.sort(
                            (a, b) => b.getUpdatedAt.compareTo(a.getUpdatedAt));
                        addUserRequestCount++;
                      });
                    }
                    _enableButton();
                    Utility.createErrorSnackBar(_navigatorContext,
                        error: "Success!");
                  }, onError: (e) {
                    Utility.createErrorSnackBar(_navigatorContext);
                    _enableButton();
                  });
                }
              }, onError: (e) {
                Utility.createErrorSnackBar(_navigatorContext);
                _enableButton();
              });
            } else {
              FlatIncomingResponse userData = new FlatIncomingResponse();
              userData.userId = user.documents[0].documentID;
              userData.phone = user.documents[0].data["phone"];
              userData.name = user.documents[0].data["name"];
              userData.updatedAt =
                  (requests.documents[0].data["updated_at"] as Timestamp)
                      .toDate();
              userData.createdAt =
                  (requests.documents[0].data["created_at"] as Timestamp)
                      .toDate();
              Firestore.instance
                  .collection("joinflat")
                  .where("user_id",
                      isEqualTo: userData.userId.toString().trim())
                  .getDocuments()
                  .then((joinRequests) {
                if (joinRequests == null ||
                    joinRequests.documents.length == 0) {
                  Utility.createErrorSnackBar(_navigatorContext);
                  debugPrint("USER REQUEST NOT FOUND");
                  _enableButton();
                } else {
                  DocumentReference toUpdateFlat;
                  var batch = Firestore.instance.batch();
                  for (var request in joinRequests.documents) {
                    DocumentReference ref = Firestore.instance
                        .collection("joinflat")
                        .document(request.documentID);
                    var data = {"status": -1, "updated_at": timeNow};
                    batch.updateData(ref, data);
                    if (request.data["flat_id"] == _flatId &&
                        request.data["request_from_flat"] == 0) {
                      toUpdateFlat = ref;
                    }
                  }
                  batch.commit().then((snapshot) {
                    if (toUpdateFlat == null) {
                      Utility.createErrorSnackBar(_navigatorContext);
                      _enableButton();
                    } else {
                      toUpdateFlat.updateData({
                        "status": 1,
                        "updated_at": timeNow
                      }).then((snapshot) {
                        Firestore.instance
                            .collection("user")
                            .document(userData.userId.toString().trim())
                            .updateData({
                          "flat_id": _flatId.toString().trim(),
                          "updated_at": timeNow
                        }).then((userUpdate) {
                          debugPrint(userData.userId);
                          setState(() {
                            FlatUsersResponse newUser = new FlatUsersResponse(
                                name: userData.name,
                                userId: userData.userId,
                                createdAt: data["created_at"],
                                updatedAt: timeNow);
                            existingUsers.add(newUser);
                            usersCount++;
                            existingUsers.sort((a, b) =>
                                b.getUpdatedAt.compareTo(a.getUpdatedAt));
                            //incomingRequests.remove(userData);
                            //incomingRequestsCount--;
                            Utility.createErrorSnackBar(_navigatorContext,
                                error: "Success!");
                          });
                          _enableButton();
                        }, onError: (e) {
                          debugPrint("ERROR IN REQ ACEEPT");
                          Utility.createErrorSnackBar(_navigatorContext);
                          _enableButton();
                        });
                      }, onError: (e) {
                        debugPrint("ERROR IN REQ ACEEPT");
                        Utility.createErrorSnackBar(_navigatorContext);
                        _enableButton();
                      });
                    }
                  }, onError: (e) {
                    debugPrint("ERROR IN REQ ACEEPT");
                    Utility.createErrorSnackBar(_navigatorContext);
                    _enableButton();
                  });
                }
              }, onError: (e) {
                debugPrint("ERROR IN REQ ACCEPT");
                Utility.createErrorSnackBar(_navigatorContext);
                _enableButton();
              });
            }
          }, onError: (e) {
            Utility.createErrorSnackBar(_navigatorContext);
            _enableButton();
          });
        }
      }
    }, onError: (e) {
      Utility.createErrorSnackBar(_navigatorContext);
      _enableButton();
    });
  }

  _removeAddUserRequest(userData) async {
    if (_flatId == null) await _getFromSharedPref();

    setState(() {
      _isButtonDisabled = true;
    });

    debugPrint("IN REMOVE ADD USER REQUEST" +
        userData.userId.toString() +
        _flatId.toString());

    var userId = userData.userId.toString().trim();
    Firestore.instance
        .collection("joinflat")
        .where("user_id", isEqualTo: userId)
        .where("flat_id", isEqualTo: _flatId)
        .where("request_from_flat", isEqualTo: 1)
        .getDocuments()
        .then((joinRequest) {
      if (joinRequest == null || joinRequest.documents.length == 0) {
        Utility.createErrorSnackBar(_navigatorContext);
        _enableButtonOnly();
      } else {
        var req = joinRequest.documents[0].documentID;
        if (joinRequest.documents[0].data["status"] == 0) {
          Firestore.instance.collection("joinflat").document(req).delete().then(
              (snapshot) {
            setState(() {
              Utility.createErrorSnackBar(_navigatorContext, error: "Success!");
              addUsersRequests.remove(userData);
              addUserRequestCount--;
            });
            _enableButtonOnly();
          }, onError: (e) {
            Utility.createErrorSnackBar(_navigatorContext);
            _enableButtonOnly();
          });
        } else {
          Utility.createErrorSnackBar(_navigatorContext);
          _enableButtonOnly();
        }
      }
    }, onError: (e) {
      Utility.createErrorSnackBar(_navigatorContext);
      _enableButtonOnly();
    });
  }

  void _updateUsersView() async {
    if (_flatId == null) await _getFromSharedPref();
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
          this.usersCount = responseArray.length;
          this.existingUsers = responseArray;
        });
      }
    }, onError: (e) {
      debugPrint("ERROR IN UPDATE USERS VIEW");
      Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  void _updateAddUserView() async {
    if (_flatId == null) await _getFromSharedPref();

    Firestore.instance
        .collection("joinflat")
        .where("flat_id", isEqualTo: _flatId)
        .where("status", isEqualTo: 0)
        .where("request_from_flat", isEqualTo: 1)
        .getDocuments()
        .then((joinRequests) {
      if (joinRequests == null || joinRequests.documents.length == 0) {
        //no requests
      } else {
        joinRequests.documents.sort(
            (a, b) => b.data['updated_at'].compareTo(a.data['updated_at']));
        List<FlatAddUsersResponse> usersToFetch = new List();
        for (int i = 0; i < joinRequests.documents.length; i++) {
          FlatAddUsersResponse f = new FlatAddUsersResponse();
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
              this.addUserRequestCount = usersToFetch.length;
              this.addUsersRequests = usersToFetch;
            });
          });
        }

        /*for (int i = 0; i < usersToFetch.length; i++) {
          debugPrint(usersToFetch[i].userId);
          Firestore.instance
              .collection("user")
              .document(usersToFetch[i].userId.trim()).get().then((userData){
            if (userData.exists) {
              usersToFetch[i].name = userData.data['name'];
              usersToFetch[i].phone = userData.data['phone'];
              debugPrint("###" + usersToFetch[i].name);
            }
          });
        }
        Firestore.instance.runTransaction((transaction) async {
          debugPrint("IN TRANSACTION");
          for (int i = 0; i < usersToFetch.length; i++) {
            debugPrint(usersToFetch[i].userId);
            DocumentSnapshot userData = await transaction.get(Firestore.instance
                .collection("user")
                .document(usersToFetch[i].userId.trim()));

            if (userData.exists) {
              usersToFetch[i].name = userData.data['name'];
              usersToFetch[i].phone = userData.data['phone'];
              debugPrint("###" + usersToFetch[i].name);
            }
          }
        }).whenComplete(() {
          debugPrint("IN WHEN COMPLETE TRANSACTION");
          setState(() {
            this.addUserRequestCount = usersToFetch.length;
            this.addUsersRequests = usersToFetch;
          });
        }).catchError((e) {
          debugPrint("SERVER TRANSACTION ERROR");
          Utility.createErrorSnackBar(_navigatorContext);
        });*/
      }
    }, onError: (e) {
      debugPrint("ERROR IN ADD USERS VIEW");
      Utility.createErrorSnackBar(_navigatorContext);
    });
  }

  void _updateUserDetails() async {
    var _userId = await Utility.getUserId();
    var _userName = await Utility.getUserName();
    var _userPhone = await Utility.getUserPhone();
    if (_userName == null ||
        _userName == "" ||
        _userPhone == null ||
        _userPhone == "") {
      Firestore.instance.collection("user").document(_userId).get().then(
          (snapshot) {
        if (snapshot.exists) {
          setState(() {
            userName = snapshot.data['name'];
            userPhone = snapshot.data['phone'];
          });
          Utility.addToSharedPref(userName: userName);
          Utility.addToSharedPref(userPhone: userPhone);
        }
      }, onError: (e) {
        Utility.createErrorSnackBar(_navigatorContext);
      });
    } else {
      userName = await Utility.getUserName();
      userPhone = await Utility.getUserPhone();
    }
  }

  Widget getContacts(context) {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(globals.flat)
            .document(_flatId.toString().trim())
            .collection(globals.flatContacts)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> contactSnapshot) {
          if (!contactSnapshot.hasData ||
              contactSnapshot.data.documents.length == 0) {
            contactHeight = 50.0;
            return emptyCard();
          }
          contactHeight = 90.0 * contactSnapshot.data.documents.length;

          return ListView.builder(
              itemCount: contactSnapshot.data.documents.length,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int position) {
                var contactChar = getUserAvatarChar(contactSnapshot
                    .data.documents[position]["name"]
                    .toString()[0]
                    .toUpperCase());

                return Container(

                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 2.0, right: 8.0, left: 8.0),
                    child: SizedBox(
                      height: 80.0,
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          elevation: 5.0,
                          child: Slidable(
                            key: new Key(position.toString()),
                            enabled: true,
                            dismissal: SlidableDismissal(
                              child: SlidableDrawerDismissal(),
                              closeOnCanceled: true,
                              onWillDismiss: (actionType) {
                                return showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return new AlertDialog(
                                      title: new Text('Delete'),
                                      content: new Text('Item will be deleted'),
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
                              },
                              onDismissed: (actionType) {
                                Firestore.instance
                                    .collection(globals.flat)
                                    .document(_flatId)
                                    .collection(globals.flatContacts)
                                    .document(contactSnapshot
                                    .data.documents[position].documentID)
                                    .delete();
                              },
                            ),
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            actions: <Widget>[
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
                                        content: new Text('Item will be deleted'),
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
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(_flatId)
                                        .collection(globals.flatContacts)
                                        .document(contactSnapshot
                                        .data.documents[position].documentID)
                                        .delete();
                                    state.dismiss();
                                  }
                                },
                              ),
                            ],
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
                                        content: new Text('Item will be deleted'),
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
                                    Firestore.instance
                                        .collection(globals.flat)
                                        .document(_flatId)
                                        .collection(globals.flatContacts)
                                        .document(contactSnapshot
                                        .data.documents[position].documentID)
                                        .delete();
                                    state.dismiss();
                                  }
                                },
                              ),
                            ],
                            child: ListTile(
                              leading: GestureDetector(
                                child: CircleAvatar(
                                  child: CircleAvatar(
                                    backgroundColor: Utility.userIdColor(
                                        contactSnapshot
                                            .data.documents[position]["name"]
                                            .toString()),
                                    child: Text(
                                      contactChar,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontFamily: 'Roboto',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    contactName.text = contactSnapshot
                                        .data.documents[position]["name"]
                                        .toString();
                                    phone.text = contactSnapshot
                                        .data.documents[position]["phone"]
                                        .toString()
                                        .trim();
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (_) => new Form(
                                          key: _formKey1,
                                          child: AlertDialog(
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                              new BorderRadius.circular(10.0),
                                              side: BorderSide(
                                                width: 1.0,
                                                color: Colors.indigo[900],
                                              ),
                                            ),
                                            title: new Text("Edit contact",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16.0)),
                                            content: Container(
                                                width: double.maxFinite,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                    2.5,
                                                child: ListView(
                                                  children: <Widget>[
                                                    TextFormField(
                                                      autofocus: true,
                                                      keyboardType:
                                                      TextInputType.text,
                                                      style: textStyle,
                                                      controller: contactName,
                                                      validator: (String value) {
                                                        if (value.isEmpty)
                                                          return "Please enter Name";
                                                        if (value.length > 20)
                                                          return "Name too long!!";
                                                        return null;
                                                      },
                                                      decoration: InputDecoration(
                                                          labelText:
                                                          "Contact Name",
                                                          labelStyle: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 13.0,
                                                              fontFamily:
                                                              'Montserrat',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w700),
                                                          hintText: "Maid",
                                                          hintStyle: TextStyle(
                                                              color: Colors.grey),
                                                          errorStyle: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 12.0,
                                                              fontFamily:
                                                              'Montserrat',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w700),
                                                          border:
                                                          InputBorder.none),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            top: 10.0,
                                                            bottom: 10.0),
                                                        child: TextFormField(
                                                          keyboardType:
                                                          TextInputType
                                                              .number,
                                                          style: textStyle,
                                                          controller: phone,
                                                          validator:
                                                              (String value) {
                                                            if (value.isEmpty)
                                                              return "Please enter Phone Number";
                                                            return null;
                                                          },
                                                          decoration: InputDecoration(
                                                              labelText:
                                                              "Phone Number",
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13.0,
                                                                  fontFamily:
                                                                  'Montserrat',
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                              hintText:
                                                              "9005489765",
                                                              hintStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              errorStyle: TextStyle(
                                                                  color:
                                                                  Colors.red,
                                                                  fontSize: 12.0,
                                                                  fontFamily:
                                                                  'Montserrat',
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                              border: InputBorder
                                                                  .none),
                                                        )),
                                                    Padding(
                                                        padding: EdgeInsets.only(
                                                            top: _minimumPadding,
                                                            bottom:
                                                            _minimumPadding),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            children: <Widget>[
                                                              OutlineButton(
                                                                  shape:
                                                                  new RoundedRectangleBorder(
                                                                      borderRadius: new BorderRadius.circular(
                                                                          10.0),
                                                                      side:
                                                                      BorderSide(
                                                                        width:
                                                                        1.0,
                                                                        color:
                                                                        Colors.indigo[900],
                                                                      )),
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      8.0),
                                                                  textColor: Colors
                                                                      .blue,
                                                                  child: Text(
                                                                      'Save',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                          14.0,
                                                                          fontFamily:
                                                                          'Montserrat',
                                                                          fontWeight:
                                                                          FontWeight.w700)),
                                                                  onPressed: () {
                                                                    if (_formKey1
                                                                        .currentState
                                                                        .validate()) {
                                                                      setState(
                                                                              () {});
                                                                      _addOrUpdateFlatContact(
                                                                          _navigatorContext,
                                                                          2,
                                                                          phoneExisting: contactSnapshot
                                                                              .data
                                                                              .documents[position]["phone"]); //2 is update
                                                                      Navigator.of(
                                                                          context,
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
                                                                        .circular(
                                                                        10.0),
                                                                    side:
                                                                    BorderSide(
                                                                      width: 1.0,
                                                                      color: Colors
                                                                          .indigo[
                                                                      900],
                                                                    ),
                                                                  ),
                                                                  padding:
                                                                  const EdgeInsets.all(
                                                                      8.0),
                                                                  textColor:
                                                                  Colors.blue,
                                                                  child: Text(
                                                                      'Cancel',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .red,
                                                                          fontSize:
                                                                          14.0,
                                                                          fontFamily:
                                                                          'Montserrat',
                                                                          fontWeight:
                                                                          FontWeight.w700)),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                        true)
                                                                        .pop();
                                                                  })
                                                            ]))
                                                  ],
                                                )),
                                          )));
                                },
                              ),
                              title: CommonWidgets.textBox(
                                  contactSnapshot.data.documents[position]["name"]
                                      .toString(),
                                  15.0,
                                  color: Colors.black),
                              subtitle: CommonWidgets.textBox(
                                  contactSnapshot
                                      .data.documents[position]["phone"]
                                      .toString(),
                                  12.0,
                                  color: Colors.black),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  var ph = contactSnapshot
                                      .data.documents[position]["phone"]
                                      .toString()
                                      .trim();
                                  debugPrint(ph);
                                  _launchURL("tel:" + ph);
                                },
                              ),
                              onTap: () {},
                            ),
                          )),
                    ),
                  ),
                );
              });
        });
  }

  String getUserAvatarChar(name) {
    List alphabets = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];

    if (!alphabets.contains(name)) {
      name = "S";
    }

    return name;
  }

  ListView _getExistingUsers() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: this.usersCount,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int position) {
          return SizedBox(
            width: 100,
            height: 105,
            child: Card(
              color: Colors.white30,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],),
                      child: CircleAvatar(
                        backgroundColor: Utility.userIdColor(
                            this.existingUsers[position].userId),
                        child: Align(
                          child: Text(
                            userName == ""
                                ? "S"
                                : this
                                .existingUsers[position]
                                .name[0]
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 30.0,
                              fontFamily: 'Satisfy',
                              color: Colors.white,
                            ),
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.5),
                      child: Text(
                        this.existingUsers[position].name,
                        style:
                            TextStyle(fontSize: 14.0, fontFamily: 'Montserrat'),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // TODO fix
  ListView _getExistingAddUserRequests() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: this.addUserRequestCount,
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
                        addUsersRequests[index].name,
                        maxLines: 1,
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
                        addUsersRequests[index].phone,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Container(
                      height: 25.0,
                    ),
                    new Expanded(
                      child: new Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: ButtonTheme(
                            height: 20.0,
                            minWidth: 125.0,
                            child: RaisedButton(
                                elevation: 0.0,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(0.0),
                                  side: BorderSide(
                                    width: 0.5,
                                    color: Colors.black,
                                  ),
                                ),
                                color: Colors.white,
                                textColor: Theme.of(context).primaryColorDark,
                                child: (_progressCircleState == 0)
                                    ? setUpButtonChild("Accept",
                                        color: Colors.red, icon: Icons.delete)
                                    : setUpButtonChild("Waiting"),
                                onPressed: () {
                                  if (_isButtonDisabled == false) {
                                    debugPrint(addUsersRequests[index]
                                        .userId
                                        .toString());
                                    var noteToRemove = addUsersRequests[index];
                                    setState(() {
                                      addUsersRequests.removeAt(index);
                                      addUserRequestCount--;
                                    });
                                    _removeAddUserRequest(noteToRemove);
                                  } else
                                    Utility.createErrorSnackBar(
                                        _navigatorContext,
                                        error:
                                            "Waiting for Request Call to Complete!");
                                })),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // utilities
  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    _flatId = await prefs.get(globals.flatId);
    _flatId = _flatId.toString().trim();
  }

  _enableButton() {
    setState(() {
      _isButtonDisabled = false;
      _progressCircleState = 0;
    });
  }

  _enableButtonOnly() {
    setState(() {
      _isButtonDisabled = false;
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

  Widget emptyCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 60.0,
        child: Card(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
            side: BorderSide(
              width: 0.5,
              color: Colors.black,
            ),
          ),
          color: Colors.white,
          elevation: 0.0,
          child: Center(
            child: Container(
              child: Center(
                child: Text(
                  "It's good to have some contacts handy here.",
                  style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.black38,
                        fontSize: 13.0,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToProfileOptions() async {
    Map result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ProfileOptions(userName, userPhone, flatName, displayId)),
    );
    if (result.containsKey("editedData") &&
        result["editedData"].contains("name")) {
      _updateUsersView();
    }
  }

  Widget swipeBackground() {
    return Container(
      color: Colors.red[600],
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                Expanded(
                  flex: 10,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void fetchFlatName(context) async {
    if (_flatId == null || _flatId == "") _getFromSharedPref();
    Utility.getFlatName().then((flatName) {
      if (flatName == null ||
          flatName == "" ||
          displayId == "" ||
          displayId == null) {
        Firestore.instance
            .collection(globals.flat)
            .document(_flatId)
            .get()
            .then((flat) {
          if (flat != null) {
            Utility.addToSharedPref(flatName: flat['name'].toString());
            Utility.addToSharedPref(displayId: flat['display_id'].toString());
            setState(() {
              displayId = flat['display_id'].toString();
            });
          }
        });
      }
    });
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
