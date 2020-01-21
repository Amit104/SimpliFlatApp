import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/start_navigation.dart';
import 'dart:async';
import 'package:simpliflat/screens/utility.dart';

class FlatIncomingReq {
  DocumentReference ref;
  String displayId;

  FlatIncomingReq(this.ref, this.displayId);

  DocumentReference get docRef {
    return ref;
  }

  set docRef(dRef) {
    ref = dRef;
  }

  String get displayIdFlat {
    return displayId;
  }

  set displayIdFlat(display) {
    displayId = display;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  var _navigatorContext;

  @override
  Widget build(BuildContext context) {
    _checkPrefsAndNavigate();

    //splash screen code
    return MaterialApp(
      title: 'SimpliFlat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.indigo[900],
        fontFamily: 'Montserrat',
      ),
      home: WillPopScope(onWillPop: () {
        moveToLastScreen();
      }, child: Scaffold(body: Builder(builder: (BuildContext contextScaffold) {
        _navigatorContext = contextScaffold;
        return Stack(fit: StackFit.expand, children: <Widget>[
          new DecoratedBox(
            decoration: new BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundColor: Colors.indigo[900],
                            radius: 50.0,
                            child: Icon(Icons.home,
                                color: Colors.white, size: 50.0)),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        Text(
                          "SIMPLIFLAT",
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 21.0,
                            fontFamily: 'Montserrat',
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.indigo[900]),
                    ),
                  ],
                ),
              )
            ],
          )
        ]);
      }))),
    );
  }

  void _checkPrefsAndNavigate() {
    var userId;
    var flatId;
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      Timer(Duration(milliseconds: 2000), () {
        userId = sp.get(globals.userId);
        flatId = sp.get(globals.flatId);
        if (userId != null) userId = userId.toString();
        if (flatId != null) flatId = flatId.toString();

        userId == null
            ? debugPrint("User Id is null")
            : debugPrint("User Id is = " + userId);
        flatId == null
            ? debugPrint("Flat Id is null")
            : debugPrint("Flat Id is = " + flatId);

        if (userId == null)
          _navigate(_navigatorContext, 1);
        else if (flatId == null || flatId == "null" || flatId == "") {
          debugPrint("IN FLAT NULL");

          Firestore.instance
              .collection("joinflat")
              .where("user_id", isEqualTo: userId)
              .getDocuments()
              .then((requests) {
            debugPrint("AFTER JOIN REQ");
            if (requests.documents != null && requests.documents.length != 0) {
              bool userRequested = false;
              String statusForUserReq = "";
              List<String> incomingRequests = new List<String>();

              List<FlatIncomingReq> flatIdGetDisplay = new List();
              requests.documents.sort((a, b) =>
                  a.data['updated_at'].compareTo(b.data['updated_at']) > 0
                      ? 1
                      : -1);
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
                        Firestore.instance
                            .collection("flat")
                            .document(reqFlatId),
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
                  incomingRequests.add(flatIdGetDisplay[i].displayId);
                }
                debugPrint("IN NAVIGATE");
                debugPrint(incomingRequests.length.toString());
                if (userRequested) {
                  userId = userId.toString();
                  flatId = flatId.toString();
                  if (statusForUserReq == "1") {
                    Utility.addToSharedPref(flatId: flatId);
                    _navigate(_navigatorContext, 3, flatId: flatId);
                  } else if (statusForUserReq == "-1") {
                    _navigate(_navigatorContext, 2,
                        requestDenied: -1, incomingRequests: incomingRequests);
                  } else {
                    _navigate(_navigatorContext, 2,
                        requestDenied: 0, incomingRequests: incomingRequests);
                  }
                } else {
                  _navigate(_navigatorContext, 2,
                      requestDenied: 2, incomingRequests: incomingRequests);
                }
              }).catchError((e) {
                debugPrint("SERVER TRANSACTION ERROR");
                Utility.createErrorSnackBar(_navigatorContext);
              });
            } else {
              debugPrint("IN ELSE FLAT NULL");
              _navigate(_navigatorContext, 2, requestDenied: 2);
            }
          }, onError: (e) {
            debugPrint("CALL ERROR");
            Utility.createErrorSnackBar(_navigatorContext);
          }).catchError((e) {
            debugPrint("SERVER ERROR");
            debugPrint(e.toString());
            Utility.createErrorSnackBar(_navigatorContext);
          });
        } else {
          debugPrint("IN ELSE");
          _navigate(_navigatorContext, 3, flatId: flatId);
        }
      });
    });
  }

  // flag indicate -
  // 1 : User is new - SignUp()
  // 2 : CreateOrJoin() page with request status
  // 3 : Home()
  void _navigate(context, flag, {flatId,
      requestDenied = 2, List<String> incomingRequests}) {
    debugPrint("Flag for navigation is " + flag.toString());
    Navigator.pushReplacement(
      _navigatorContext,
      new MaterialPageRoute(builder: (context) {
        return StartNavigation(flag, requestDenied, incomingRequests, flatId);
      }),
    );
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
