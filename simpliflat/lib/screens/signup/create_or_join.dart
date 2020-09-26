import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/main.dart';
import 'package:simpliflat/screens/signup/create_flat.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'dart:async';
import 'dart:math';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateOrJoin extends StatefulWidget {
  var requestDenied;
  var lastRequestStatus;
  List incomingRequests;
  Color ccard, ctext;
  var userId;

  CreateOrJoin(requestDenied, incomingRequests) {
    this.requestDenied = requestDenied;
    this.incomingRequests = incomingRequests;
    if (requestDenied == -1) {
      lastRequestStatus = "Your last join request was denied!";
      ccard = Colors.red[100];
      ctext = Colors.red[600];
    } else if (requestDenied == 0) {
      lastRequestStatus =
          "Your last request is pending. Wait or join new flat.";
      ccard = Colors.purple[100];
      ctext = Colors.purple[600];
    } else {
      lastRequestStatus =
          "Lets get started! You can only be in one flat at a time";
      ccard = Colors.white;
      ctext = Colors.indigo[900];
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _CreateOrJoinBody(lastRequestStatus, ccard, ctext, incomingRequests);
  }
}

class _CreateOrJoinBody extends State<CreateOrJoin> {
  String lastRequestStatus;
  var _progressCircleState = 0;
  Color ccard, ctext;
  List incomingRequests;
  BuildContext scaffoldContext;
  var _isButtonDisabled = false;
  var flatId;

  var _buttonColor;

  _CreateOrJoinBody(
      this.lastRequestStatus, this.ccard, this.ctext, this.incomingRequests);

  @override
  void initState() {
    super.initState();
    _buttonColor = Colors.blue;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<dynamic> _handleRefresh() async {
    var userId = await Utility.getUserId();
    var flatId;
    _checkFlatAccept();
    return Firestore.instance
        .collection("joinflat")
        .where("user_id", isEqualTo: userId)
        .getDocuments()
        .then((requests) {
      debugPrint("AFTER JOIN REQ");
      if (requests.documents != null && requests.documents.length != 0) {
        bool userRequested = false;
        String statusForUserReq = "";
        List<String> incomingRequestsTemp = new List<String>();

        List<FlatIncomingReq> flatIdGetDisplay = new List();
        requests.documents.sort((a, b) =>
            a.data['updated_at'].compareTo(b.data['updated_at']) > 0 ? 1 : -1);
        for (int i = 0; i < requests.documents.length; i++) {
          debugPrint("doc + " + requests.documents[i].documentID);
          var data = requests.documents[i].data;
          var reqFlatId = data['flat_id'];
          var reqStatus = data['status'];
          var reqFromFlat = data['request_from_flat'];

          if (reqFromFlat.toString() == "0") {
            userRequested = true;
            statusForUserReq = reqStatus.toString();
            flatId = reqFlatId.toString();
          } else {
            // case where flat made a request to add user
            // show all these flats to user on next screen - Create or join
            debugPrint(reqFlatId);
            if (reqStatus.toString() == "0")
              flatIdGetDisplay.add(FlatIncomingReq(
                  Firestore.instance.collection("flat").document(reqFlatId),
                  ''));
          }
        }

        //get Display IDs for flats with incoming requests
        Firestore.instance.runTransaction((transaction) async {
          for (int i = 0; i < flatIdGetDisplay.length; i++) {
            DocumentSnapshot flatData =
                await transaction.get(flatIdGetDisplay[i].ref);
            if (flatData.exists)
              flatIdGetDisplay[i].displayId = flatData.data['display_id'];
          }
        }).whenComplete(() {
          debugPrint("IN WHEN COMPLETE TRANSACTION");
          for (int i = 0; i < flatIdGetDisplay.length; i++) {
            incomingRequestsTemp.add(flatIdGetDisplay[i].displayId);
          }

          setState(() {
            incomingRequests = incomingRequestsTemp;
          });
          debugPrint("IN NAVIGATE");
          debugPrint(incomingRequestsTemp.length.toString());
          if (userRequested) {
            userId = userId.toString();
            flatId = flatId.toString();
            if (statusForUserReq == "1") {
              Utility.addToSharedPref(flatId: flatId);
              _navigateToHome(flatId);
            } else if (statusForUserReq == "-1") {
              setState(() {
                lastRequestStatus = "Your last join request was denied!";
              });
            } else {
              setState(() {
                lastRequestStatus =
                    "Your last request is pending. Wait or join new flat.";
              });
            }
          } else {
            setState(() {
              lastRequestStatus =
                  "Lets get started! You can only be in one flat at a time";
            });
          }
        }).catchError((e) {
          debugPrint("SERVER TRANSACTION ERROR");
          Utility.createErrorSnackBar(scaffoldContext);
        });
      } else {
        debugPrint("IN ELSE FLAT NULL");
        setState(() {
          lastRequestStatus =
              "Lets get started! You can only be in one flat at a time";
        });
      }
    }, onError: (e) {
      debugPrint("CALL ERROR");
      Utility.createErrorSnackBar(scaffoldContext);
    }).catchError((e) {
      debugPrint("SERVER ERROR");
      debugPrint(e.toString());
      Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    if (flatId == null) _checkFlatAccept();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "FIND A FLAT",
            style: TextStyle(
              color: Color(0xff373D4C),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          scaffoldContext = scaffoldC;
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 4.1 * MediaQuery.of(context).size.height / 5,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: deviceSize.width * 0.95,
                          child: Card(
                              color: ccard,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: (ccard == Colors.white)
                                    ? Text(lastRequestStatus,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                            color: ctext))
                                    : ListTile(
                                        leading: Icon(
                                          Icons.warning,
                                          color: ctext,
                                        ),
                                        title: Text(
                                          lastRequestStatus,
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            color: ctext,
                                          ),
                                        ),
                                      ),
                              )),
                        ),
                      ),
                      Container(margin: EdgeInsets.all(10.0)),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(),
                            flex: 2,
                          ),
                          InkWell(
                            onTap: () {},
                            child: SizedBox(
                                height: 225,
                                width: deviceSize.width * 0.42,
                                child: GestureDetector(
                                  onTap: () {
                                    navigateToCreate(context, 0);
                                  },
                                  child: new Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      color: Colors.black87,
                                      elevation: 2.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: Color(0xff6C67D3)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 28.0,
                                                    top: 40.0,
                                                  ),
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    size: 30.0,
                                                    color: Colors.white,
                                                  )),
                                              textInCard(
                                                  "CREATE",
                                                  FontWeight.w700,
                                                  21.0,
                                                  28.0,
                                                  10.0),
                                              textInCard(
                                                  "A FLAT",
                                                  FontWeight.normal,
                                                  21.0,
                                                  28.0,
                                                  3.0),
                                              textInCard("Create a new flat",
                                                  null, 14.0, 28.0, 8.0),
                                              textInCard("and invite your",
                                                  null, 14.0, 28.0, 4.0),
                                              textInCard("flatmates", null,
                                                  14.0, 28.0, 4.0),
                                            ]),
                                      )),
                                )),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 3,
                          ),
                          InkWell(
                            splashColor: Colors.white,
                            onTap: () {},
                            child: SizedBox(
                                height: 225,
                                width: deviceSize.width * 0.42,
                                child: GestureDetector(
                                  onTap: () {
                                    navigateToCreate(context, 1).then((flag) {
                                      setState(() {
                                        if (flag == 0) {
                                          lastRequestStatus =
                                              "Your last request is pending. wait or join new flat.";
                                          ccard = Colors.purple[100];
                                          ctext = Colors.purple[700];
                                        }
                                      });
                                    });
                                  },
                                  child: new Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      color: Color(0xff2079FF),
                                      elevation: 2.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 28.0,
                                                    top: 40.0,
                                                  ),
                                                  child: Icon(
                                                    Icons.play_circle_outline,
                                                    size: 30.0,
                                                    color: Colors.white,
                                                  )),
                                              textInCard(
                                                  "JOIN",
                                                  FontWeight.w700,
                                                  21.0,
                                                  28.0,
                                                  10.0),
                                              textInCard(
                                                  "A FLAT",
                                                  FontWeight.normal,
                                                  21.0,
                                                  28.0,
                                                  3.0),
                                              textInCard("Search for your",
                                                  null, 14.0, 28.0, 8.0),
                                              textInCard("flat and send a",
                                                  null, 14.0, 28.0, 4.0),
                                              textInCard("request", null, 14.0,
                                                  28.0, 4.0),
                                            ]),
                                      )),
                                )),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 2,
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(15.0),
                      ),
                      Row(
                        children: (incomingRequests == null ||
                                incomingRequests.length == 0)
                            ? <Widget>[Container(margin: EdgeInsets.all(5.0))]
                            : <Widget>[
                                Expanded(child: Container()),
                                Text("Requests",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff2079FF))),
                                Expanded(flex: 15, child: Container()),
                              ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: Container(
                          height: (incomingRequests == null ||
                                  incomingRequests.length == 0)
                              ? 5.0
                              : MediaQuery.of(context).size.height / 2,
                          child: (incomingRequests == null ||
                                  incomingRequests.length == 0)
                              ? null
                              : new ListView.builder(
                                  itemCount: incomingRequests.length,
                                  itemBuilder: (BuildContext context,
                                          int index) =>
                                      buildIncomingRequests(context, index)),
                        ),
                      ),
                    ],
                  ),
                ),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    side: BorderSide(
                      width: 0.0,
                    ),
                  ),
                  color: Color(0xff2079FF),
                  textColor: Colors.white,
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return new AlertDialog(
                          title: new Text('Sign out'),
                          content:
                              new Text('Are you sure you want to sign out?'),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            new FlatButton(
                                child: new Text('Yes'),
                                onPressed: () async {
                                  Navigator.of(context).pop(true);
                                  await FirebaseAuth.instance.signOut();
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MyApp()),
                                      (Route<dynamic> route) => false);
                                }),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }));
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

  //build incoming flat requests list
  Widget buildIncomingRequests(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Card(
            color: Colors.white,
            elevation: 1.0,
            child: Dismissible(
              key: ObjectKey(incomingRequests[index]),
              background: swipeBackground(),
              onDismissed: (direction) {
                String request = incomingRequests[index];
                setState(() {
                  incomingRequests.removeAt(index);
                });
                _respondToJoinRequest(scaffoldContext, request, -1);
              },
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    incomingRequests[index],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                trailing: ButtonTheme(
                    height: 25.0,
                    minWidth: 30.0,
                    child: RaisedButton(
                        elevation: 0.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.white,
                        textColor: Theme.of(context).primaryColorDark,
                        child: (_progressCircleState == 0)
                            ? setUpButtonChild("Accept")
                            : setUpButtonChild("Waiting"),
                        onPressed: () {
                          if (_isButtonDisabled == false)
                            _respondToJoinRequest(
                                scaffoldContext, incomingRequests[index], 1);
                          else {
                            setState(() {
                              _progressCircleState = 1;
                            });
                            Utility.createErrorSnackBar(scaffoldContext,
                                error: "Waiting for Request Call to Complete!");
                          }
                        })),
              ),
            )),
      ),
    );
  }

  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the counter key. If it does not exist, return 0.
    var uID = await prefs.get(globals.userId);
    return uID;
  }

  Widget setUpButtonChild(buttonText) {
    if (_progressCircleState == 0) {
      return new Text(
        buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10.0,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
      );
    } else if (_progressCircleState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      );
    } else {
      return Icon(Icons.check, color: Colors.black);
    }
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
          fontFamily: 'Roboto',
          fontWeight: weight,
        ),
      ),
    );
  }

  void _respondToJoinRequest(scaffoldContext, displayFlatId, didAccept) async {
    setState(() {
      _buttonColor = Colors.lightBlueAccent;
      _isButtonDisabled = true;
    });
    var userId = await _getFromSharedPref();
    var timeNow = DateTime.now();
    Firestore.instance
        .collection("flat")
        .where("display_id", isEqualTo: displayFlatId)
        .limit(1)
        .getDocuments()
        .then((flat) {
      if (flat.documents != null && flat.documents.length != 0) {
        var flatId = flat.documents[0].documentID;
        var displayId = flat.documents[0].data['display_id'];
        debugPrint("display_Id = " + displayId);
        //check if we have a request from this flat
        if (didAccept == 1) {
          Firestore.instance
              .collection("joinflat")
              .where("user_id", isEqualTo: userId)
              .where("flat_id", isEqualTo: flatId)
              .where("request_from_flat", isEqualTo: 1)
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
                  .where('user_id', isEqualTo: userId)
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
                    .where("user_id", isEqualTo: userId)
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
                  for (int i = 0; i < toRejectList.length; i++) {
                    batch.updateData(
                        toRejectList[i], {'status': -1, 'updated_at': timeNow});
                  }
                  batch.updateData(
                      toAccept, {'status': 1, 'updated_at': timeNow});

                  //update user
                  var userRef =
                      Firestore.instance.collection("user").document(userId);
                  batch.updateData(userRef, {'flat_id': flatId});

                  batch.commit().then((res) {
                    debugPrint("ADDED TO FLAT");
                    Utility.addToSharedPref(
                        flatId: flatId, displayId: displayId);
                    setState(() {
                      _navigateToHome(flatId);
                      _isButtonDisabled = false;
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
            }
          });
        } else if (didAccept == -1) {
          DocumentReference toReject;
          Firestore.instance
              .collection("joinflat")
              .where("user_id", isEqualTo: userId)
              .where("flat_id", isEqualTo: flatId)
              .where("request_from_flat", isEqualTo: 1)
              .getDocuments()
              .then((toRejectData) {
            if (toRejectData.documents != null &&
                toRejectData.documents.length != 0) {
              toReject = Firestore.instance
                  .collection("joinflat")
                  .document(toRejectData.documents[0].documentID);
            }
            //perform actual batch operations
            var batch = Firestore.instance.batch();

            batch.updateData(toReject, {'status': -1, 'updated_at': timeNow});

            batch.commit().then((res) {
              setState(() {
                _isButtonDisabled = false;
              });
            }, onError: (e) {
              _setErrorState(scaffoldContext, "CALL ERROR");
            }).catchError((e) {
              _setErrorState(scaffoldContext, "SERVER ERROR");
            });
          });
        }
      }
    });
  }

  _checkFlatAccept() async {
    var userId = await Utility.getUserId();
    Firestore.instance.collection(globals.user).document(userId).get().then(
        (user) {
      if (user != null && user['flat_id'] != null && user['flat_id'] != "") {
        Utility.addToSharedPref(flatId: user['flat_id'].toString().trim());
        _navigateToHome(user['flat_id'].toString().trim());
      } else {
        flatId = "";
      }
    }, onError: (e) {}).catchError((e) {});
  }

  void _setErrorState(scaffoldContext, error, {textToSend}) {
    setState(() {
      _isButtonDisabled = false;
      debugPrint(error);
      if (textToSend != null && textToSend != "")
        Utility.createErrorSnackBar(scaffoldContext, error: textToSend);
      else
        Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  void _navigateToHome(flatId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return Home(flatId);
      }),
    );
  }

  Future<int> navigateToCreate(BuildContext context, createOrJoin) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateFlat(createOrJoin);
      }),
    );
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
