import 'package:flutter/material.dart';
import 'package:simpliflat/screens/signup/create_or_join.dart';
import 'package:simpliflat/screens/signup/signupBackground.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpName extends StatefulWidget {
  final phone;

  SignUpName(this.phone);

  @override
  State<StatefulWidget> createState() {
    return _SignUpNameUser(phone);
  }
}

class _SignUpNameUser extends State<SignUpName> {
  var _formKey = GlobalKey<FormState>();
  var _progressCircleState = 0;
  var _isButtonDisabled = false;
  var phone;
  final _minpad = 5.0;
  String smsCode;
  String verificationId;
  BuildContext _scaffoldContext;
  TextEditingController name = TextEditingController();

  _SignUpNameUser(this.phone);

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(title: Text("Name please"), elevation: 0.0),
        //resizeToAvoidBottomPadding: false,
        body: Stack(children: <Widget>[
          SignUpBackground(3),
          Builder(builder: (BuildContext scaffoldContext) {
            _scaffoldContext = scaffoldContext;
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
                          //
                          opacity: 1,
                          child: SizedBox(
                              height: max(deviceSize.height / 2, 270),
                              width: deviceSize.width * 0.85,
                              child: new Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: Column(children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 60.0,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Text(
                                            "What should I call you?",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 18.0),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 35.0,
                                      ),
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
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 30.0,
                                                fontWeight: FontWeight.w700),
                                            controller: name,
                                            validator: (String value) {
                                              if (value.isEmpty)
                                                return "Please enter Name";
                                              return null;
                                            },
                                            onFieldSubmitted: (v) {
                                              _submitForm();
                                            },
                                            decoration: InputDecoration(
                                                //labelText: "Name",
                                                hintText: "Rahul",
                                                //labelStyle: TextStyle(
                                                //    color: Colors.white),
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                                errorStyle: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12.0,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight:
                                                        FontWeight.w700),
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
                                      padding: EdgeInsets.only(top: 30.0),
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
                                              height: 40.0,
                                              child: RaisedButton(
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
                                                  color: Colors.white,
                                                  textColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  child: setUpButtonChild(),
                                                  onPressed: () {
                                                    _submitForm();
                                                  })),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ]))),
                        ),
                      ),
                    ],
                  ),
                ));
          }),
        ]));
  }

  void _submitForm() {
    if (_formKey.currentState.validate() && _isButtonDisabled == false) {
      setState(() {
        _progressCircleState = 1;
        _isButtonDisabled = true;
        debugPrint("STARTING API CALL");
      });
      _addUserHandler(_scaffoldContext);
    }
  }

  void _serverError(scaffoldContext) {
    setState(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
      debugPrint("SERVER ERROR");
      Utility.createErrorSnackBar(scaffoldContext);
    });
  }

  void _onSuccess({userId, flatId, displayId}) {
    Utility.addToSharedPref(
        userId: userId, flatId: flatId, displayId: displayId);
    setState(() {
      _isButtonDisabled = false;
      _progressCircleState = 2;
      debugPrint("CALL SUCCCESS");
    });
  }

  void _addUserHandler(scaffoldContext) async {
    var timeNow = DateTime.now();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Firestore _firestore = Firestore.instance;

    FirebaseUser user = await _auth.currentUser();
    var userData = {
      'phone': phone,
      'name': name.text,
      "updated_at": timeNow,
      "created_at": timeNow,
      'flat_id': null,
      'notification_token': ''
    };
    debugPrint('phone = ' + phone);
    Firestore.instance
        .collection("user")
        .where("phone", isEqualTo: phone.trim())
        .limit(1)
        .getDocuments()
        .then((snapshot) {
      if (snapshot == null || snapshot.documents.length == 0) {
        debugPrint("IN NEW USER");
        DocumentReference ref =
            _firestore.collection("user").document(user.uid);
        ref.setData(userData).then((addedUser) {
          var userId = user.uid;
          _onSuccess(userId: userId);
          navigateToCreateOrJoin();
        }, onError: (e) {
          _serverError(scaffoldContext);
        });
      } else {
        Map<String, dynamic> existingUser = snapshot.documents[0].data;
        if (existingUser['flat_id'] == null || existingUser['flat_id'] == "") {
          debugPrint("userId = " + snapshot.documents[0].documentID);
          _onSuccess(userId: snapshot.documents[0].documentID);
          navigateToCreateOrJoin();
        } else {
          debugPrint("userId = " + snapshot.documents[0].documentID);
          debugPrint("flatid = " + existingUser['flat_id']);
          _onSuccess(
              userId: snapshot.documents[0].documentID,
              flatId: existingUser['flat_id']);
          navigateToHome(existingUser['flat_id']);
        }
      }
    }, onError: (e) {
      debugPrint("ERROR");
      _serverError(scaffoldContext);
    });
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return new Text(
        "Let's Go!",
        style: const TextStyle(
            color: Colors.indigo,
            fontSize: 16.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700),
      );
    } else if (_progressCircleState == 1) {
      return Container(
        margin: EdgeInsets.all(3.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[900]),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void navigateToCreateOrJoin() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return CreateOrJoin(2, null);
    }), ModalRoute.withName('/'))
        .whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  void navigateToHome(flatId) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return Home(flatId);
    }), ModalRoute.withName('/'))
        .whenComplete(() {
      _progressCircleState = 0;
      _isButtonDisabled = false;
    });
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }
}
