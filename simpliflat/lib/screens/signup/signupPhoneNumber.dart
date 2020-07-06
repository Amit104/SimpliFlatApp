import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat/screens/signup/signupBackground.dart';
import 'package:simpliflat/screens/signup/signupOTP.dart';
import 'dart:math';

class SignUpPhone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpPhoneUser();
  }
}

class _SignUpPhoneUser extends State<SignUpPhone> {
  var _formKey = GlobalKey<FormState>();
  var _progressCircleState = 0;
  var _isButtonDisabled = false;
  final _minpad = 5.0;
  String smsCode;
  String verificationId;
  BuildContext _scaffoldContext;
  TextEditingController phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
          elevation: 0.0,
        ),
        //resizeToAvoidBottomPadding: false,
        body: Stack(children: <Widget>[
          SignUpBackground(1),
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
                              height: max(deviceSize.height / 2, 300),
                              width: deviceSize.width * 0.85,
                              child: new Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0)),
                                  color: Colors.white,
                                  elevation: 2.0,
                                  child: Column(children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 50.0,
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
                                            "What's Your Phone Number",
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
                                        top: 5.0,
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
                                            "By signing-up I agree to Terms and condition. ",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Montserrat',
                                                fontSize: 12.0),
                                          ),

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
                                          child: Center(
                                            child: TextFormField(
                                              autofocus: true,
                                              keyboardType:
                                              TextInputType.number,
                                              style: TextStyle(
                                                  fontSize: 30.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Montserrat'),
                                              controller: phone,
                                              validator: (String value) {
                                                if (value.isEmpty)
                                                  return "Please enter Phone Number";
                                                if (value.length != 10)
                                                  return "Please enter Valid 10 digit number";
                                                return null;
                                              },
                                              onFieldSubmitted: (v) {
                                                _submitForm();
                                              },
                                              decoration: InputDecoration(
                                                //labelText: "Phone Number",
                                                  hintText: "9001236320",
                                                  //labelStyle: TextStyle(
                                                  //    color: Colors.black),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  errorStyle: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12.0,
                                                      fontFamily: 'Montserrat'),
                                                  border: InputBorder.none),
                                            ),
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
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) {
          return SignUpOTP("+1" + phone.text.trim(), true);
        }),
      ).whenComplete(() {
        setState(() {
          _progressCircleState = 0;
          _isButtonDisabled = false;
        });
      });
    }
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return new Text(
        "Proceed",
        style: const TextStyle(
          color: Colors.indigo,
          fontSize: 16.0,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
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

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}