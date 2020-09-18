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
import 'landlord_onboarding/SearchBuilding.dart';

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
  var _isButtonDisabled = false;
  var _progressCircleState = 0;
  List incomingRequests;
  var _navigatorContext;

  _AddLandlord(this.flatId);

  @override
  Widget build(BuildContext context) {
    if (lastRequest == "checking") _checkJoinStatus();
    if (incomingRequests == null) getIncomingRequests();
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen(context, -1);
          return null;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Add Landlord"),
              elevation: 0.0,
              centerTitle: true,
            ),
            body: Builder(builder: (BuildContext scaffoldContext) {
              _navigatorContext = scaffoldContext;
              return checkLandlord(scaffoldContext);
            })));
  }

  Widget checkLandlord(_navigatorContext) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    var deviceSize = MediaQuery.of(context).size;
    if (lastRequest != "checking") {
      return ListView(
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
                          style:
                              TextStyle(fontFamily: 'Montserrat', color: ctext))
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

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => SearchBuilding(flatId)));
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
                            Colors.indigo[900],
                            Colors.indigo[800],
                            Colors.indigo[700],
                            Colors.indigo[600],
                          ],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            textInCard("Add a landlord", FontWeight.w700, 24.0,
                                28.0, 40.0),
                            textInCard("Search for your flat", null, 14.0,
                                28.0, 20.0),
                            textInCard(
                                "and send a request.", null, 14.0, 28.0, 7.0),
                          ]),
                    )),
              )),
          Container(
            height: 35.0,
          ),
          Row(
            children: (incomingRequests == null || incomingRequests.length == 0)
                ? <Widget>[Container(margin: EdgeInsets.all(5.0))]
                : <Widget>[
                    Expanded(child: Container()),
                    Text("Incoming Requests",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Montserrat',
                            color: Colors.black)),
                    Expanded(flex: 15, child: Container()),
                  ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Container(
              height: (incomingRequests == null || incomingRequests.length == 0)
                  ? 5.0
                  : MediaQuery.of(context).size.height / 2,
              child: (incomingRequests == null || incomingRequests.length == 0)
                  ? null
                  : new ListView.builder(
                      itemCount: incomingRequests.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildIncomingRequests(context, index)),
            ),
          ),
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
        if (requests.documents[0]['status'] == 0) {
          if (mounted)
            setState(() {
              lastRequest =
                  "Your last request is pending. Wait or make a new one.";
              ccard = Colors.purple[100];
              ctext = Colors.purple[600];
            });
        }
        if (requests.documents[0]['status'] == -1) {
          if (mounted)
            setState(() {
              lastRequest =
                  "Your last join request was denied by the landlord!";
              ccard = Colors.red[100];
              ctext = Colors.red[600];
            });
        }
      } else {
        debugPrint("IN ELSE FLAT NULL");
        if (mounted)
          setState(() {
            lastRequest =
                "Lets get started! You can only make one request at a time.";
            ccard = Colors.white;
            ctext = Colors.indigo[900];
          });
      }
    }, onError: (e) {
      debugPrint("CALL ERROR");
      if (mounted)
        setState(() {
          lastRequest =
              "Lets get started! You can only make one request at a time.";
          ccard = Colors.white;
          ctext = Colors.indigo[900];
        });
      if (mounted) Utility.createErrorSnackBar(context);
    }).catchError((e) {
      debugPrint("SERVER ERROR");
      if (mounted)
        setState(() {
          lastRequest =
              "Lets get started! You can only make one request at a time.";
          ccard = Colors.white;
          ctext = Colors.indigo[900];
        });
      if (mounted) Utility.createErrorSnackBar(context);
    });
  }

  //build incoming requests list
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
                String request = incomingRequests[index]['phone'];
                setState(() {
                  incomingRequests.removeAt(index);
                });
                _respondToJoinRequest(context, request, -1);
              },
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    incomingRequests[index]['name'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    incomingRequests[index]['phone'],
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11.0,
                      fontFamily: 'Montserrat',
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
                            _respondToJoinRequest(_navigatorContext,
                                incomingRequests[index]['phone'], 1);
                          else {
                            setState(() {
                              _progressCircleState = 1;
                            });
                            Utility.createErrorSnackBar(_navigatorContext,
                                error: "Waiting for Request Call to Complete!");
                          }
                        })),
              ),
            )),
      ),
    );
  }

  void _respondToJoinRequest(scaffoldContext, phone, didAccept) async {
    setState(() {
      _isButtonDisabled = true;
    });
    var flatName = await Utility.getFlatName();
    List landlordFlatList = new List();
    var userId = await Utility.getUserId();
    var timeNow = DateTime.now();
    Firestore.instance
        .collection(globals.landlord)
        .where("phone", isEqualTo: phone)
        .limit(1)
        .getDocuments()
        .then((landlordUser) {
      if (landlordUser.documents != null &&
          landlordUser.documents.length != 0) {
        if (landlordUser.documents[0]['flat_id'] != null) {
          landlordFlatList = landlordUser.documents[0]['flat_id'];
        }
        var landlordUserId = landlordUser.documents[0].documentID;
        debugPrint("landlordUserId = " + landlordUserId);
        //check if we have a request from this landlord
        if (didAccept == 1) {
          Firestore.instance
              .collection(globals.requestsLandlord)
              .where("user_id", isEqualTo: landlordUserId)
              .where("flat_id", isEqualTo: flatId)
              .where("request_from_flat", isEqualTo: 0)
              .limit(1)
              .getDocuments()
              .then((incomingReq) {
            var now = new DateTime.now();
            if (incomingReq.documents != null &&
                incomingReq.documents.length != 0) {
              List<DocumentReference> toRejectList = new List();
              DocumentReference toAccept;
              debugPrint("LANDLORD REQUEST TO FLAT EXISTS!");
              //reject other requests to and from flat
              Firestore.instance
                  .collection(globals.requestsLandlord)
                  .where('flat_id', isEqualTo: flatId)
                  .getDocuments()
                  .then((toBeRejected) {
                if (toBeRejected.documents != null &&
                    toBeRejected.documents.length != 0) {
                  for (int i = 0; i < toBeRejected.documents.length; i++) {
                    var doc = Firestore.instance
                        .collection(globals.requestsLandlord)
                        .document(toBeRejected.documents[i].documentID);
                    if (!(toBeRejected.documents[i]['user_id'] ==
                            landlordUserId &&
                        toBeRejected.documents[i]['request_from_flat'] == 0)) {
                      debugPrint("doc+" + toBeRejected.documents[i].documentID);
                      toRejectList.add(doc);
                    }
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
                  for (int i = 0; i < toRejectList.length; i++) {
                    batch.updateData(
                        toRejectList[i], {'status': -1, 'updated_at': timeNow});
                  }
                  batch.updateData(
                      toAccept, {'status': 1, 'updated_at': timeNow});

                  //update user
                  landlordFlatList.add(flatId.toString().trim());
                  var landlordUserRef = Firestore.instance
                      .collection(globals.landlord)
                      .document(landlordUserId);
                  batch.updateData(landlordUserRef, {'flat_id': landlordFlatList});

                  //update flat landlord
                  var flatRef = Firestore.instance
                      .collection(globals.flat)
                      .document(flatId);
                  batch.updateData(flatRef, {'landlord_id': landlordUserId});

                  batch.commit().then((res) {
                    debugPrint("ADDED TO FLAT");
                    Utility.addToSharedPref(landlordId: landlordUserId);
                    setState(() {
                      _navigateToTenant();
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
              .collection(globals.requestsLandlord)
              .where("user_id", isEqualTo: landlordUserId)
              .where("flat_id", isEqualTo: flatId)
              .where("request_from_flat", isEqualTo: 0)
              .getDocuments()
              .then((toRejectData) {
            if (toRejectData.documents != null &&
                toRejectData.documents.length != 0) {
              toReject = Firestore.instance
                  .collection(globals.requestsLandlord)
                  .document(toRejectData.documents[0].documentID);
            }
            //perform actual batch operations
            var batch = Firestore.instance.batch();
            batch.updateData(toReject, {'status': -1, 'updated_at': timeNow});
            batch.commit().then((res) {
              setState(() {
                _isButtonDisabled = false;
              });
              _setErrorState(scaffoldContext, "Success!",
                  textToSend: "Success!");
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

  void getIncomingRequests() {
    Firestore.instance
        .collection(globals.requestsLandlord)
        .where("flat_id", isEqualTo: flatId)
        .where("request_from_flat", isEqualTo: 0)
        .getDocuments()
        .then((requests) {
      debugPrint("FETCHING INCOMING REQ");
      if (requests.documents != null && requests.documents.length != 0) {
        List<FlatIncomingReq> usersToGet = new List();
        requests.documents.sort((a, b) =>
            a.data['updated_at'].compareTo(b.data['updated_at']) > 0 ? 1 : -1);
        for (int i = 0; i < requests.documents.length; i++) {
          debugPrint("doc + " + requests.documents[i].documentID);
          var data = requests.documents[i].data;
          var reqStatus = data['status'];

          if (reqStatus.toString() == "0")
            usersToGet.add(FlatIncomingReq(
                Firestore.instance
                    .collection(globals.landlord)
                    .document(data['user_id']),
                ''));
        }
        //get data for landlords with incoming requests
        Firestore.instance.runTransaction((transaction) async {
          for (int i = 0; i < usersToGet.length; i++) {
            DocumentSnapshot userData =
                await transaction.get(usersToGet[i].ref);
            if (userData.exists)
              usersToGet[i].displayId =
                  userData.data['name'] + ";" + userData.data['phone'];
          }
        }).whenComplete(() {
          if (incomingRequests == null) {
            incomingRequests = new List();
            debugPrint("IN WHEN COMPLETE TRANSACTION");
            for (int i = 0; i < usersToGet.length; i++) {
              var data = {
                'name': usersToGet[i].displayId.split(";")[0].trim(),
                'phone': usersToGet[i].displayId.split(";")[1].trim()
              };
              if (mounted && !incomingRequests.contains(data))
                setState(() {
                  incomingRequests.add(data);
                });
            }
            debugPrint("IN NAVIGATE");
            debugPrint(incomingRequests.length.toString());
          }
        }).catchError((e) {
          debugPrint("SERVER TRANSACTION ERROR");
          debugPrint(e.toString());
        });
      } else {
        setState(() {
          incomingRequests = new List();
        });
      }
    }, onError: (e) {
      debugPrint("CALL ERROR");
      Utility.createErrorSnackBar(_navigatorContext);
    }).catchError((e) {
      debugPrint("SERVER ERROR");
      debugPrint(e.toString());
      Utility.createErrorSnackBar(_navigatorContext);
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
      _isButtonDisabled = false;
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

  Widget setUpButtonChild(buttonText) {
    if (_progressCircleState == 0) {
      return new Text(
        buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10.0,
          fontFamily: 'Montserrat',
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
}
