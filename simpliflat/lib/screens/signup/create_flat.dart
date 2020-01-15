import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CreateFlat extends StatefulWidget {
  final flag;

  CreateFlat(this.flag);

  @override
  State<StatefulWidget> createState() {
    return _CreateUserFlat(flag);
  }
}

class _CreateUserFlat extends State<CreateFlat> {
  var _formKey = GlobalKey<FormState>();
  var _progressCircleState = 0;
  var _isButtonDisabled = false;
  final _minpad = 5.0;
  var buttonText;
  var displayText;
  TextEditingController flatname = TextEditingController();
  final flag;

  _CreateUserFlat(this.flag);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    if (flag == 0) {
      buttonText = "Create Flat";
      displayText = "Name";
    } else {
      buttonText = "Join Flat";
      displayText = "ID";
    }
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen(context, -1);
        },
        child: Scaffold(
            //resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(buttonText),
              elevation: 0.0,
            ),
            body: Builder(builder: (BuildContext scaffoldContext) {
              return Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 50.0, left: _minpad * 2, right: _minpad * 2),
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(_minpad),
                          child: Opacity(
                            opacity: 1,
                            child: SizedBox(
                              height: max(deviceSize.height / 2, 350),
                              width: deviceSize.width * 0.85,
                              child: new Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                color: Colors.black87,
                                elevation: 2.0,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 50.0,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(),
                                          flex: 1,
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            "Enter Flat " + displayText,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(),
                                          flex: 1,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 12.0,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(),
                                          flex: 1,
                                        ),
                                        Expanded(
                                          child: Text(
                                            displayText
                                                        .toString()
                                                        .trim()
                                                        .toLowerCase() ==
                                                    "name"
                                                ? "Let's start fresh. You can add members later"
                                                : "Get the flat ID from your friend's profile page.",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'Montserrat',
                                                fontSize: 16.0),
                                            maxLines: null,
                                          ),
                                          flex: 7,
                                        ),
                                        Expanded(
                                          child: Container(),
                                          flex: 1,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 35.0,
                                          right: 20.0,
                                          left: deviceSize.width / 8),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: TextFormField(
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                fontSize: 30.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Montserrat'),
                                            controller: flatname,
                                            validator: (String value) {
                                              if (value.isEmpty)
                                                return "Please enter Flat " +
                                                    displayText;
                                            },
                                            onFieldSubmitted: (v) {
                                              _submit(scaffoldContext);
                                            },
                                            decoration: InputDecoration(
                                                //labelText: "Flat " + displayText,
                                                hintText: displayText
                                                            .toString()
                                                            .trim()
                                                            .toLowerCase() ==
                                                        "name"
                                                    ? "Rockerz"
                                                    : "pop-695daw4",
                                                hintStyle: TextStyle(
                                                  color: Colors.white30,
                                                ),
                                                //labelStyle: textStyle,
                                                errorStyle: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12.0),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 40.0),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: ButtonTheme(
                                              height: 60.0,
                                              minWidth: 150.0,
                                              child: RaisedButton(
                                                  shape:
                                                      new RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(10.0),
                                                    side: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  color: Colors.white,
                                                  textColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  child: setUpButtonChild(),
                                                  onPressed: () {
                                                    _submit(scaffoldContext);
                                                  })),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            })));
  }

  void _submit(scaffoldContext) {
    if (_formKey.currentState.validate() && _isButtonDisabled == false) {
      setState(() {
        _progressCircleState = 1;
        _isButtonDisabled = true;
        debugPrint("STARTING API CALL");
      });
      if (flag == 0) {
        //create flat
        _createFlatAPI(scaffoldContext);
      } else {
        //join flat
        _joinFlatAPI(scaffoldContext);
      }
    }
  }

  void _createFlatAPI(scaffoldContext) async {
    var uuid = new Uuid();

    var flatName = flatname.text;
    var uID = await _getFromSharedPref();
    var displayId = flatName + "-" + uuid.v1().toString().substring(0, 6);
    debugPrint("UserId is " + uID.toString());
    debugPrint("DisplayId is " + displayId.toString());
    var timeNow = DateTime.now();
    var newFlat = {
      'name': flatName,
      'display_id': displayId.toString().toLowerCase(),
      "updated_at": timeNow,
      "created_at": timeNow,
    };

    //not providing document id here will generate a new id
    var createReq = Firestore.instance.collection("flat").document();
    var updateUser = Firestore.instance.collection("user").document(uID);

    //we have to get all document IDs to be updated. We cannot do bulk update in a transaction
    Firestore.instance
        .collection("joinflat")
        .where("user_id", isEqualTo: uID)
        .getDocuments()
        .then((req) {
      List<DocumentReference> removeReq = new List();
      if (req.documents != null && req.documents.length != 0) {
        for (int i = 0; i < req.documents.length; i++) {
          DocumentReference doc = Firestore.instance
              .collection("joinflat")
              .document(req.documents[i].documentID);
          removeReq.add(doc);
          debugPrint("doc + " + req.documents[i].documentID);
        }
      }
      Firestore.instance.runTransaction((transaction) async {
        //create a new flat
        await transaction.set(createReq, newFlat);

        //update user to include in the flat
        await transaction.update(updateUser,
            {'flat_id': createReq.documentID, 'updated_at': timeNow});

        // set status of any existing requests to or from user to -1
        for (int i = 0; i < removeReq.length; i++) {
          await transaction
              .update(removeReq[i], {'status': -1, 'updated_at': timeNow});
        }
      }).then((value) {
        debugPrint("Completed flat creation");
        Utility.addToSharedPref(
            flatId: createReq.documentID.toString(),
            displayId: displayId.toLowerCase().toString());
        setState(() {
          _isButtonDisabled = false;
          _progressCircleState = 2;
          debugPrint("CALL SUCCCESS");
        });
        _navigateToHome(createReq.documentID.toString().trim());
      }).catchError((e) {
        _setErrorState(scaffoldContext, "SERVER ERROR");
      });
    }, onError: (e) {
      _setErrorState(scaffoldContext, "CALL ERROR");
    }).catchError((e) {
      _setErrorState(scaffoldContext, "SERVER ERROR");
    });
  }

  void _joinFlatAPI(scaffoldContext) async {
    var flatName = flatname.text;
    var uID = await _getFromSharedPref();
    debugPrint("UserId is " + uID.toString());

    Firestore.instance
        .collection("flat")
        .where("display_id", isEqualTo: flatName)
        .limit(1)
        .getDocuments()
        .then((flat) {
      if (flat.documents != null && flat.documents.length != 0) {
        var flatId = flat.documents[0].documentID;
        var displayId = flat.documents[0].data['display_id'];
        debugPrint("display_Id = " + displayId);
        //check if we have a request from this flat
        Firestore.instance
            .collection("joinflat")
            .where("user_id", isEqualTo: uID)
            .where("flat_id", isEqualTo: flatId)
            .where("request_from_flat", isEqualTo: 1)
            .where("status", isEqualTo: 0)
            .limit(1)
            .getDocuments()
            .then((incomingReq) {
          var now = new DateTime.now();
          if (incomingReq.documents != null &&
              incomingReq.documents.length != 0) {
            List<DocumentReference> toRejectList = new List();
            DocumentReference toAccept;
            debugPrint("FLAT REQUEST TO USER EXISTS!");
            //reject other requests
            Firestore.instance
                .collection("joinflat")
                .where('user_id', isEqualTo: uID)
                .getDocuments()
                .then((toBeRejected) {
              if (toBeRejected.documents != null &&
                  toBeRejected.documents.length != 0) {
                for (int i = 0; i < toBeRejected.documents.length; i++) {
                  var doc = Firestore.instance
                      .collection("joinflat")
                      .document(toBeRejected.documents[i].documentID);
                  debugPrint("doc+" + toBeRejected.documents[i].documentID);
                  toRejectList.add(doc);
                }
              }

              // accept current request
              Firestore.instance
                  .collection("joinflat")
                  .where("user_id", isEqualTo: uID)
                  .where("flat_id", isEqualTo: flatId)
                  .where("request_from_flat", isEqualTo: 1)
                  .getDocuments()
                  .then((toAcceptData) {
                if (toAcceptData.documents != null &&
                    toAcceptData.documents.length != 0) {
                  toAccept = Firestore.instance
                      .collection("joinflat")
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
                  debugPrint("ADDED TO FLAT");
                  Utility.addToSharedPref(flatId: flatId, displayId: displayId);
                  setState(() {
                    _navigateToHome(flatId);
                    _isButtonDisabled = false;
                    _progressCircleState = 2;
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
            debugPrint("FLAT REQUEST TO USER DOES NOT EXIST!");
            Map<String, dynamic> newReq = {
              'user_id': uID,
              'flat_id': flatId,
              'request_from_flat': 0,
              'status': 0,
              'created_at': now,
              'updated_at': now
            };
            Map<String, dynamic> updatedReq = {
              'user_id': uID,
              'flat_id': flatId,
              'request_from_flat': 0,
              'status': 0,
              'updated_at': now
            };
            Firestore.instance
                .collection("joinflat")
                .where("user_id", isEqualTo: uID)
                .where("request_from_flat", isEqualTo: 0)
                .limit(1)
                .getDocuments()
                .then((checker) {
              debugPrint("CHECKING REQUEST EXISTS OR NOT");
              if (checker.documents == null || checker.documents.length == 0) {
                debugPrint("CREATING REQUEST");
                Firestore.instance.collection("joinflat").add(newReq).then(
                    (addedReq) {
                  setState(() {
                    _isButtonDisabled = false;
                    _progressCircleState = 2;
                    debugPrint("CALL SUCCCESS");
                    moveToLastScreen(context, 0);
                  });
                }, onError: (e) {
                  _setErrorState(scaffoldContext, "CALL ERROR");
                }).catchError((e) {
                  _setErrorState(scaffoldContext, "SERVER ERROR");
                });
              } else {
                debugPrint("UPDATING REQUEST");
                Firestore.instance
                    .collection("joinflat")
                    .document(checker.documents[0].documentID)
                    .updateData(updatedReq)
                    .then((updatedData) {
                  setState(() {
                    _isButtonDisabled = false;
                    _progressCircleState = 2;
                    debugPrint("CALL SUCCCESS");
                    moveToLastScreen(context, 0);
                  });
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
          }
        }, onError: (e) {
          _setErrorState(scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(scaffoldContext, "SERVER ERROR");
        });
      } else {
        _setErrorState(scaffoldContext, "Flat does not exist",
            textToSend: "Flat does not exist");
      }
    }, onError: (e) {
      _setErrorState(scaffoldContext, "CALL ERROR");
    }).catchError((e) {
      _setErrorState(scaffoldContext, "SERVER ERROR");
    });
  }

  void _setErrorState(scaffoldContext, error, {textToSend}) {
    setState(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
      debugPrint(error);
      if (textToSend != null && textToSend != "")
        Utility.createErrorSnackBar(scaffoldContext, error: textToSend);
      else
        Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    var uID = await prefs.get(globals.userId);
    return uID;
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return new Text(
        buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
      );
    } else if (_progressCircleState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void _navigateToHome(flatId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return Home(flatId);
      }),
    ).whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  @override
  void dispose() {
    flatname.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context, flag) {
    Navigator.pop(context, flag);
  }
}
