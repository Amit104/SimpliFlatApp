import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat/screens/signup/signupOTP.dart';
import 'package:simpliflat/screens/widgets/common.dart';


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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "SIGNUP",
            style: TextStyle(
              color: Color(0xff373D4C),
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
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
                                        "Welcome to SimpliFlat!",
                                        style: TextStyle(
                                            color: Color(0xff2079FF),
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 26.0),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 5.0,
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
                                        "Please insert your phone number to continue",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0),
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
                                      flex: 2,
                                      child: Container(
                                        child: Text(
                                          "+91",
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Center(
                                        child: TextFormField(
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                          ),
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
                                            border: new UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder:
                                                new UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.black),
                                            ),
                                            hintText: "9001236320",
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0,
                                              fontFamily: 'Roboto',
                                            ),
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
                                                _submitForm();
                                              })),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                Container(height: 10.0),
                                CommonWidgets.getDotIndicator(20,10,10),
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
          return SignUpOTP("+91" + phone.text.trim(), true);
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CONTINUE",
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
    phone.dispose();
    super.dispose();
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
