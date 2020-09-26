import 'package:flutter/material.dart';
import 'package:simpliflat/screens/signup/signUpName.dart';
import 'dart:async';
import 'package:simpliflat/screens/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:simpliflat/screens/widgets/common.dart';

class SignUpOTP extends StatefulWidget {
  final phone;
  final bool navigateToName;

  SignUpOTP(this.phone, this.navigateToName);

  @override
  State<StatefulWidget> createState() {
    return _SignUpOTPUser(phone);
  }
}

class _SignUpOTPUser extends State<SignUpOTP> {
  var phone;

  _SignUpOTPUser(this.phone) {
    verifyPhone();
  }

  var _formKey = GlobalKey<FormState>();
  var _progressCircleState = 0;
  var _isButtonDisabled = false;
  final _minpad = 5.0;
  String smsCode;
  String verificationId;
  BuildContext _scaffoldContext;
  TextEditingController otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    var deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "OTP Verification",
            style: TextStyle(
              color: Color(0xff373D4C),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xff373D4C),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0.0,
          centerTitle: true,
        ),
        //resizeToAvoidBottomPadding: false,
        body: Builder(builder: (BuildContext scaffoldContext) {
          _scaffoldContext = scaffoldContext;
          return Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 60.0,
                ),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Opacity(
                        opacity: 1,
                        child: SizedBox(
                          width: deviceSize.width,
                          child: new Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Colors.white,
                            elevation: 0.0,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Text(
                                        "Please enter the OTP!",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
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
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontSize: 35.0,
                                          color: Colors.black,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w700,
                                        ),
                                        controller: otp,
                                        validator: (String value) {
                                          if (value.isEmpty)
                                            return "Please enter OTP";
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          //labelText: "OTP",
                                          hintText: "000000",
                                          //labelStyle: TextStyle(
                                          //    color: Colors.white),
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          errorStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.0,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          ),
                                          border: new UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black),
                                          ),
                                          focusedBorder:
                                              new UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black),
                                          ),
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
                                      flex: 8,
                                      child: ButtonTheme(
                                          height: 50.0,
                                          child: RaisedButton(
                                              shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        25.0),
                                                side: BorderSide(
                                                  width: 0.0,
                                                ),
                                              ),
                                              color: Color(0xff2079FF),
                                              textColor: Theme.of(context)
                                                  .primaryColorDark,
                                              child: setUpButtonChild(),
                                              onPressed: () {
                                                if (_formKey.currentState
                                                        .validate() &&
                                                    _isButtonDisabled ==
                                                        false) {
                                                  setState(() {
                                                    _progressCircleState = 1;
                                                    _isButtonDisabled = true;
                                                    debugPrint(
                                                        "STARTING API CALL");
                                                  });
                                                  this.smsCode =
                                                      otp.text.trim();

                                                  if (!(widget
                                                      .navigateToName)) {
                                                    signIn();
                                                  }

                                                  FirebaseAuth.instance
                                                      .currentUser()
                                                      .then((user) {
                                                    if (user != null) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      navigateToSignUpName();
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop();
                                                      signIn();
                                                    }
                                                  });
                                                }
                                              })),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Container(height: 10.0),
                                CommonWidgets.getDotIndicator(10, 20, 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        }));
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential cred) {
      debugPrint('verified');
      if (!(widget.navigateToName)) {
        Navigator.pop(context, {'success': true});
      } else {
        navigateToSignUpName();
      }
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      debugPrint('${exception.message}');
      setState(() {
        _isButtonDisabled = false;
        _progressCircleState = 0;
      });
      Utility.createErrorSnackBar(_scaffoldContext,
          error: "Phone verification failed");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  Future<void> signIn() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      if (user != null)
        navigateToSignUpName();
      else {
        Utility.createErrorSnackBar(_scaffoldContext,
            error: "Phone verification failed");
        setState(() {
          _isButtonDisabled = false;
          _progressCircleState = 0;
          debugPrint("CALL FAILED");
        });
      }
    }).catchError((e) {
      Utility.createErrorSnackBar(_scaffoldContext,
          error: "Phone verification failed");
      setState(() {
        _isButtonDisabled = false;
        _progressCircleState = 0;
        debugPrint("CALL FAILED LAST");
      });
    });
  }

  void navigateToSignUpName() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) {
        return SignUpName(phone);
      }),
    );
  }

  Widget setUpButtonChild() {
    if (_progressCircleState == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "VERIFY",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
          new Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
        ],
      );
    } else if (_progressCircleState == 1) {
      return Container(
        margin: EdgeInsets.all(5.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  @override
  void dispose() {
    otp.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }
}
