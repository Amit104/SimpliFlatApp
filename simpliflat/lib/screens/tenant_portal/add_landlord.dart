import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../../main.dart';

class AddLandlord extends StatefulWidget {
  final flatId;

  AddLandlord(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _AddLandlord(flatId);
  }
}

class _AddLandlord extends State<AddLandlord> {
  var buttonText;
  var displayText;
  TextEditingController flatname = TextEditingController();
  final flatId;
  String landlordId;
  TextEditingController contactName = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController addUserForm = TextEditingController();
  var _formKey1 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  String lastRequest = "checking";
  Color ccard, ctext;

  _AddLandlord(this.flatId);

  @override
  Widget build(BuildContext context) {
    if(lastRequest == "checking")
      _checkJoinStatus();

    return WillPopScope(onWillPop: () {
      moveToLastScreen(context, -1);
      return null;
    }, child: Scaffold(
        appBar: AppBar(
          title: Text("Add Landlord"),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldContext) {
      return checkLandlord(scaffoldContext);
    })));
  }

  Widget checkLandlord(_navigatorContext) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    var deviceSize = MediaQuery.of(context).size;
    if (lastRequest != "checking") {
      return Column(
        children: <Widget>[
          Container(
            height: 50.0,
          ),
          SizedBox(
            width: deviceSize.width * 0.88,
            child: Card(
                color: ccard,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: (ccard == Colors.white)
                      ? Text(lastRequest,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Montserrat', color: ctext))
                      : ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: ctext,
                    ),
                    title: Text(
                      lastRequest,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: ctext,
                      ),
                    ),
                  ),
                )),
          ),
          Container(
            height: 10.0,
          ),
          SizedBox(
              height: 185,
              width: deviceSize.width * 0.88,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    contactName.text = '';
                    phone.text = '';
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
                              title: new Text("Add Landlord",
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
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                          style: textStyle,
                                          controller: addUserForm,
                                          validator: (String value) {
                                            if (value.isEmpty)
                                              return "Please enter Phone number ";
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              labelText: "Phone Number",
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700),
                                              hintText: "9005489765",
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  textColor: Colors.black,
                                                  child: Text('Add',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                  onPressed: () {
                                                    if (_formKey1.currentState
                                                        .validate()) {
                                                      setState(() {
                                                        debugPrint(
                                                            "STARTING API CALL");
                                                      });
                                                      _inviteLandlordAPI(
                                                          _navigatorContext,
                                                          addUserForm.text);
                                                      addUserForm.clear();
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
                              ))));
                },
                child: new Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    color: Colors.black87,
                    elevation: 2.0,
                    child: Container(
                      width: deviceSize.width * 0.88,
                      decoration: BoxDecoration(
                        // Box decoration takes a gradient
                        gradient: LinearGradient(
                          // Where the linear gradient begins and ends
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          // Add one stop for each color. Stops should increase from 0 to 1
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            // Colors are easy thanks to Flutter's Colors class.
                            Colors.red[900],
                            Colors.red[800],
                            Colors.red[700],
                            Colors.red[600],
                          ],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            textInCard("Add a landlord", FontWeight.w700, 24.0,
                                28.0, 40.0),
                            textInCard(
                                "Search for your landlord", null, 14.0, 28.0, 20.0),
                            textInCard(
                                "and send a request.", null, 14.0, 28.0, 7.0),
                          ]),
                    )),
              )),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _checkJoinStatus() {
    Firestore.instance
        .collection(globals.requestsLandlord)
        .where("flat_id", isEqualTo: flatId)
        .where("request_from_flat", isEqualTo: 1)
        .getDocuments()
        .then((requests) {
      debugPrint("AFTER JOIN REQ");
      if (requests.documents != null && requests.documents.length != 0) {
        if(requests.documents[0]['status'] == 0) {
          if(mounted)
            setState(() {
              lastRequest = "Your last request is pending. Wait or make a new one.";
              ccard = Colors.purple[100];
              ctext = Colors.purple[600];
            });

        }
        if(requests.documents[0]['status'] == -1) {
          if(mounted)
            setState(() {
              lastRequest = "Your last join request was denied by the landlord!";
              ccard = Colors.red[100];
              ctext = Colors.red[600];
            });
        }
      } else {
        debugPrint("IN ELSE FLAT NULL");
        if(mounted)
          setState(() {
            lastRequest = "Lets get started! You can only make one request at a time.";
            ccard = Colors.white;
            ctext = Colors.indigo[900];
          });
      }
    }, onError: (e) {
      debugPrint("CALL ERROR");
      if(mounted)
        setState(() {
          lastRequest = "Lets get started! You can only make one request at a time.";
          ccard = Colors.white;
          ctext = Colors.indigo[900];
        });
      if(mounted)
        Utility.createErrorSnackBar(context);
    }).catchError((e) {
      debugPrint("SERVER ERROR");
      if(mounted)
        setState(() {
          lastRequest = "Lets get started! You can only make one request at a time.";
          ccard = Colors.white;
          ctext = Colors.indigo[900];
        });
      if(mounted)
        Utility.createErrorSnackBar(context);
    });
  }

  void _inviteLandlordAPI(scaffoldContext, phoneNumber) async {
    var uID = await Utility.getUserId();
    debugPrint("UserId is " + uID.toString());
    var phone = "+91" + phoneNumber.replaceFirst("+91", "");

    Firestore.instance
        .collection(globals.landlord)
        .where("phone", isEqualTo: phone)
        .limit(1)
        .getDocuments()
        .then((landlordUser) {
      if (landlordUser.documents != null &&
          landlordUser.documents.length != 0) {
        var landlordUserId = landlordUser.documents[0].documentID;
        if(landlordUser.documents[0]['flat_id'] != null) {
          _setErrorState(scaffoldContext, "Landlord already in a flat",
              textToSend: "Landlord already in a flat");
          return;
        }
        debugPrint("landlordUser  = " + landlordUserId);
        //check if we have a request from this landlord
        Firestore.instance
            .collection(globals.requestsLandlord)
            .where("user_id", isEqualTo: landlordUserId)
            .where("flat_id", isEqualTo: flatId)
            .where("request_from_flat", isEqualTo: 0)
            .where("status", isEqualTo: 0)
            .limit(1)
            .getDocuments()
            .then((incomingReq) {
          var now = new DateTime.now();
          if (incomingReq.documents != null &&
              incomingReq.documents.length != 0) {
            List<DocumentReference> toRejectList = new List();
            DocumentReference toAccept;
            debugPrint("LANDLORD REQUEST TO FLAT EXISTS!");
            //reject other requests
            Firestore.instance
                .collection(globals.requestsLandlord)
                .where('user_id', isEqualTo: landlordUserId)
                .getDocuments()
                .then((toBeRejected) {
              if (toBeRejected.documents != null &&
                  toBeRejected.documents.length != 0) {
                for (int i = 0; i < toBeRejected.documents.length; i++) {
                  var doc = Firestore.instance
                      .collection(globals.requestsLandlord)
                      .document(toBeRejected.documents[i].documentID);
                  debugPrint("doc+" + toBeRejected.documents[i].documentID);
                  toRejectList.add(doc);
                }
              }

              // accept current request
              Firestore.instance
                  .collection(globals.requestsLandlord)
                  .where("user_id", isEqualTo: landlordUserId)
                  .where("flat_id", isEqualTo: flatId)
                  .where("request_from_flat", isEqualTo: 0)
                  .getDocuments()
                  .then((toAcceptData) {
                if (toAcceptData.documents != null &&
                    toAcceptData.documents.length != 0) {
                  toAccept = Firestore.instance
                      .collection(globals.requestsLandlord)
                      .document(toAcceptData.documents[0].documentID);
                }
                //perform actual batch operations
                var batch = Firestore.instance.batch();
                var timeNow = DateTime.now();
                for (int i = 0; i < toRejectList.length; i++) {
                  batch.updateData(
                      toRejectList[i], {'status': -1, 'updated_at': timeNow});
                }
                batch
                    .updateData(toAccept, {'status': 1, 'updated_at': timeNow});

                //update user
                var userRef =
                    Firestore.instance.collection("user").document(uID);
                batch.updateData(userRef, {'flat_id': flatId});

                batch.commit().then((res) {
                  debugPrint("ADDED LANDLORD");
                  Utility.addToSharedPref(landlordId: landlordUserId);
                  setState(() {
                    _navigateToTenant();
                    debugPrint("CALL SUCCCESS");
                  });
                }, onError: (e) {
                  _setErrorState(scaffoldContext, "CALL ERROR");
                }).catchError((e) {
                  _setErrorState(scaffoldContext, "SERVER ERROR");
                });
              }, onError: (e) {
                _setErrorState(scaffoldContext, "CALL ERROR");
              }).catchError((e) {
                _setErrorState(scaffoldContext, "SERVER ERROR");
              });
            }, onError: (e) {
              _setErrorState(scaffoldContext, "CALL ERROR");
            }).catchError((e) {
              _setErrorState(scaffoldContext, "SERVER ERROR");
            });
          } else {
            debugPrint("LANDLORD REQUEST TO FLAT DOES NOT EXIST!");
            Map<String, dynamic> newReq = {
              'user_id': landlordUserId,
              'flat_id': flatId,
              'request_from_flat': 1,
              'status': 0,
              'created_at': now,
              'updated_at': now
            };
            Map<String, dynamic> updatedReq = {
              'user_id': landlordUserId,
              'flat_id': flatId,
              'request_from_flat': 1,
              'status': 0,
              'updated_at': now
            };
            Firestore.instance
                .collection(globals.requestsLandlord)
                .where("flat_id", isEqualTo: flatId)
                .where("request_from_flat", isEqualTo: 1)
                .getDocuments()
                .then((oldRequests) {
                  var batch = Firestore.instance.batch();
                  if(oldRequests != null && oldRequests.documents.length != 0) {
                    for(var doc in oldRequests.documents) {
                      batch.updateData(doc.reference, {'status':-1});
                    }
                  }

                  Firestore.instance
                      .collection(globals.requestsLandlord)
                      .where("user_id", isEqualTo: landlordUserId)
                      .where("request_from_flat", isEqualTo: 1)
                      .limit(1)
                      .getDocuments()
                      .then((checker) {
                    debugPrint("CHECKING REQUEST EXISTS OR NOT");
                    if (checker.documents == null || checker.documents.length == 0) {
                      debugPrint("CREATING REQUEST");

                      var reqRef = Firestore.instance
                          .collection(globals.requestsLandlord)
                          .document();
                      batch.setData(reqRef, newReq);

                      batch.commit().then((res) async {
                        debugPrint("Request Created");
                        _setErrorState(scaffoldContext, "Request created!", textToSend: "Request created!");
                      }, onError: (e) {
                        _setErrorState(scaffoldContext, "CALL ERROR");
                      }).catchError((e) {
                        _setErrorState(scaffoldContext, "SERVER ERROR");
                      });
                    } else {
                      debugPrint("UPDATING REQUEST");
                      var reqRef = Firestore.instance
                          .collection(globals.requestsLandlord)
                          .document(checker.documents[0].documentID);
                      batch.updateData(reqRef, updatedReq);
                      batch.commit().then((res) async {
                        debugPrint("Request Updated");
                        _setErrorState(scaffoldContext, "Request created!", textToSend: "Request created!");
                      }, onError: (e) {
                        _setErrorState(scaffoldContext, "CALL ERROR");
                      }).catchError((e) {
                        _setErrorState(scaffoldContext, "SERVER ERROR");
                      });
                    }
                  }, onError: (e) {
                    _setErrorState(scaffoldContext, "CALL ERROR");
                  }).catchError((e) {
                    _setErrorState(scaffoldContext, "SERVER ERROR");
                  });
            });

          }
        }, onError: (e) {
          _setErrorState(scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(scaffoldContext, "SERVER ERROR");
        });
      } else {
        _setErrorState(scaffoldContext, "Landlord User does not exist",
            textToSend: "Landlord User does not exist");
      }
    }, onError: (e) {
      _setErrorState(scaffoldContext, "CALL ERROR");
    }).catchError((e) {
      _setErrorState(scaffoldContext, "SERVER ERROR");
    });
  }

  Widget textInCard(text, weight, size, padLeft, padTop) {
    return Padding(
      padding: EdgeInsets.only(top: padTop, left: padLeft),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: size,
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: weight,
        ),
      ),
    );
  }

  void _setErrorState(scaffoldContext, error, {textToSend}) {
    setState(() {
      debugPrint(error);
      if (textToSend != null && textToSend != "")
        Utility.createErrorSnackBar(scaffoldContext, error: textToSend);
      else
        Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void moveToLastScreen(BuildContext context, flag) {
    Navigator.pop(context, flag);
  }

  void _navigateToTenant() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TenantPortal(flatId)));
  }
}
