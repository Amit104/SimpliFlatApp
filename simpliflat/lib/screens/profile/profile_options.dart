import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat/main.dart';
import 'package:share/share.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

class ProfileOptions extends StatefulWidget {
  var userName;
  var userPhone;
  var flatName;
  var displayId;

  ProfileOptions(this.userName, this.userPhone, this.flatName, this.displayId);

  @override
  State<StatefulWidget> createState() => new _ProfileOptions();
}

class _ProfileOptions extends State<ProfileOptions> {
  var uID;
  var flatId;
  Set editedData = Set();
  var _formKey1 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  BuildContext _scaffoldContext;
  TextEditingController textField = TextEditingController();
  var userName;
  var userPhone;
  String apartmentName;
  String apartmentNumber;
  String zipCode;

  void initPrefs() async {
    await _getFromSharedPref();
    setState() {
      userName = widget.userName;
      userPhone = widget.userPhone;
    }

    _updateUserDetails();
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
          if (mounted) {
            setState(() {
              userName = snapshot.data['name'];
              userPhone = snapshot.data['phone'];
            });
          }
          Utility.addToSharedPref(userName: userName);
          Utility.addToSharedPref(userPhone: userPhone);
        }
      }, onError: (e) {});
    } else {
      userName = await Utility.getUserName();
      userPhone = await Utility.getUserPhone();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    initPrefs();
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(Strings.profileOptions),
              elevation: 0.0,
            ),
            body: Builder(builder: (BuildContext scaffoldC) {
              _scaffoldContext = scaffoldC;
              return userName != null
                  ? Center(
                      child: ListView(children: <Widget>[
                      Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: ListTile(
                            title: Text(
                              widget.flatName,
                            ),
                            leading: Icon(
                              Icons.home,
                              color: Colors.redAccent,
                            ),
                            trailing: Text(
                              "EDIT",
                              style: TextStyle(
                                  color: Colors.indigo[900],
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0),
                            ),
                            onTap: () {}),
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: ListTile(
                            title: Text(
                              widget.displayId,
                            ),
                            leading: GestureDetector(
                              child: Icon(
                                Icons.share,
                                color: Colors.indigo[900],
                              ),
                              onTap: () {
                                Share.share(
                                    'Check out Simpliflat. You can join my flat with using ID - ' +
                                        widget.displayId,
                                    subject: 'Check out Simpliflat!');
                              },
                            ),
                            onTap: () {}),
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: ListTile(
                          title: Text(
                            userName,
                          ),
                          leading: Icon(
                            Icons.account_circle,
                            color: Colors.orange,
                          ),
                          trailing: GestureDetector(
                              child: Text(
                                "EDIT",
                                style: TextStyle(
                                    color: Colors.indigo[900],
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.0),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => _getEditPrompt(
                                        textStyle,
                                        "Name",
                                        _changeUserName,
                                        _userNameValidator,
                                        TextInputType.text,
                                        userName));
                              }),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        elevation: 2.0,
                        child: ListTile(
                            title: Text(
                              userPhone,
                            ),
                            leading: Icon(
                              Icons.phone,
                              color: Colors.blue,
                            ),
                            onTap: () {}),
                      ),
                      getFlatDetailsWidget(),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(40.0),
                            side: BorderSide(
                              width: 0.5,
                              color: Colors.indigo[900],
                            ),
                          ),
                          color: Colors.white,
                          textColor: Colors.indigo[900],
                          onPressed: () {
                            showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return new AlertDialog(
                                  title: new Text('Leave Flat'),
                                  content: new Text(
                                      'Are you sure you want to leave this flat?'),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    new FlatButton(
                                        child: new Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          _exitFlat();
                                        }),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Exit Flat'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(40.0),
                            side: BorderSide(
                              width: 0.5,
                              color: Colors.indigo[900],
                            ),
                          ),
                          color: Colors.white,
                          textColor: Colors.indigo[900],
                          onPressed: () {
                            showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return new AlertDialog(
                                  title: new Text('Log out'),
                                  content: new Text(
                                      'Are you sure you want to log out?'),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    new FlatButton(
                                        child: new Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                          _signOut();
                                        }),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Logout'),
                        ),
                      ),
                    ]))
                  : Center(child: CircularProgressIndicator());
            })));
  }

  bool firstCall = false;
  Future<Map> getFlatData() async {
    if (!firstCall) {
      apartmentName = await Utility.getApartmentName();
      apartmentNumber = await Utility.getApartmentNumber();
      zipCode = await Utility.getZipcode();

      firstCall = true;
    }

    return {
      'apartmentName': apartmentName,
      'apartmentNumber': apartmentNumber,
      'zipCode': zipCode
    };
  }

  Widget getFlatDetailsWidget() {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Card(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
              color: Colors.blue[100],
              child: ListTile(
                title: Text('Flat Details'),
                trailing: Icon(Icons.pin_drop),
              )),
          FutureBuilder(
            future: getFlatData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingContainerVertical(1);
              }
              Map data = snapshot.data;

              return Column(
                children: [
                  ListTile(
                    title: data['apartmentName'] == null ||
                            data['apartmentName'] == ''
                        ? Text(
                            'Building/Flat Name',
                            style: TextStyle(color: Colors.grey[400]),
                          )
                        : Text(data['apartmentName']),
                    trailing: GestureDetector(
                        child: Text(
                          "EDIT",
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              fontSize: 14.0),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => _getEditPrompt(
                                  textStyle,
                                  "Building/Flat Name",
                                  _changeApartmentName,
                                  null,
                                  TextInputType.text,
                                  apartmentName));
                        }),
                  ),
                  ListTile(
                    title: data['apartmentNumber'] == null ||
                            data['apartmentNumber'] == ''
                        ? Text(
                            'Flat Number',
                            style: TextStyle(color: Colors.grey[400]),
                          )
                        : Text(data['apartmentNumber']),
                    trailing: GestureDetector(
                        child: Text(
                          "EDIT",
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              fontSize: 14.0),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => _getEditPrompt(
                                  textStyle,
                                  "Apartment Number",
                                  _changeApartmentNumber,
                                  null,
                                  TextInputType.text,
                                  apartmentNumber));
                        }),
                  ),
                  ListTile(
                    title: data['zipCode'] == null || data['zipCode'] == ''
                        ? Text(
                            'Zipcode',
                            style: TextStyle(color: Colors.grey[400]),
                          )
                        : Text(data['zipCode']),
                    trailing: GestureDetector(
                        child: Text(
                          "EDIT",
                          style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                              fontSize: 14.0),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => _getEditPrompt(
                                  textStyle,
                                  "Zipcode",
                                  _changeZipcode,
                                  null,
                                  TextInputType.text,
                                  zipCode));
                        }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, {'editedData': editedData});
  }

  _getFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    uID = await prefs.get(globals.userId);
    flatId = await prefs.get(globals.flatId);
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    _backHome();
  }

  void _exitFlat() async {
    var batch = Firestore.instance.batch();

    //update joinflat
    var data = {"status": -1};
    Firestore.instance
        .collection(globals.requests)
        .where("user_id", isEqualTo: uID)
        .where("flat_id", isEqualTo: flatId)
        .limit(1)
        .getDocuments()
        .then((checker) {
      debugPrint("CHECKING REQUEST EXISTS OR NOT");
      if (checker.documents != null && checker.documents.length != 0) {
        debugPrint("UPDATING REQUEST");

        var reqRef = Firestore.instance
            .collection(globals.requests)
            .document(checker.documents[0].documentID);
        batch.updateData(reqRef, data);

        var userRef = Firestore.instance.collection(globals.user).document(uID);
        batch.updateData(userRef, {"flat_id": null});

        batch.commit().then((res) async {
          debugPrint("Exit flat");

          //remove sharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(globals.flatId);

          _backHome();
        }, onError: (e) {
          _setErrorState(_scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(_scaffoldContext, "SERVER ERROR");
        });
      } else {
        var userRef = Firestore.instance.collection(globals.user).document(uID);
        batch.updateData(userRef, {"flat_id": null});

        batch.commit().then((res) async {
          debugPrint("Exit flat");

          //remove sharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(globals.flatId);

          _backHome();
        }, onError: (e) {
          _setErrorState(_scaffoldContext, "CALL ERROR");
        }).catchError((e) {
          _setErrorState(_scaffoldContext, "SERVER ERROR");
        });
      }
    }, onError: (e) {}).catchError((e) {});
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

  void _backHome() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  Form _getEditPrompt(textStyle, fieldName, editHandler, validatorCallback,
      keyboardType, initialFieldValue) {
    textField.text = initialFieldValue;
    return new Form(
        key: _formKey1,
        child: AlertDialog(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
              side: BorderSide(
                width: 1.0,
                color: Colors.indigo[900],
              ),
            ),
            title: new Text("Edit " + fieldName,
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
                          top: _minimumPadding, bottom: _minimumPadding),
                      child: TextFormField(
                        autofocus: true,
                        keyboardType: keyboardType,
                        style: textStyle,
                        controller: textField,
                        validator: (String value) {
                          if (value.isEmpty) return "Please enter a value";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: fieldName,
                            labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                            hintText: "Enter " + fieldName,
                            hintStyle: TextStyle(color: Colors.grey),
                            errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700),
                            border: InputBorder.none),
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          top: _minimumPadding, bottom: _minimumPadding),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OutlineButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.black,
                                child: Text('Save',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700)),
                                onPressed: () {
                                  if (_formKey1.currentState.validate()) {
                                    editHandler(textField);
                                  }
                                }),
                            OutlineButton(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                textColor: Colors.black,
                                child: Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700)),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                })
                          ]))
                ],
              ),
            )));
  }

  String _userNameValidator(String name) {
    if (name.isEmpty) {
      return "Cannot be empty";
    } else if (name == userName) {
      return "Cannot be the same name";
    }
    return null;
  }

  _changeApartmentName(textField) async {
    String name = textField.text;
    setState(() {
      apartmentName = name;
    });
    var data = {"apartment_name": name};
    Firestore.instance
        .collection("flat")
        .document(flatId)
        .updateData(data)
        .then((updated) {
      apartmentName = name;

      Utility.addToSharedPref(apartmentName: name);
    });
    textField.clear();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      debugPrint("Apartment name changed");
    });
  }

  _changeApartmentNumber(textField) async {
    String number = textField.text;
    setState(() {
      apartmentNumber = number;
    });
    var data = {"apartment_number": number};
    Firestore.instance
        .collection("flat")
        .document(flatId)
        .updateData(data)
        .then((updated) {
      apartmentNumber = number;

      Utility.addToSharedPref(apartmentNumber: number);
    });
    textField.clear();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      debugPrint("Apartment number changed");
    });
  }

  _changeZipcode(textField) async {
    String zcode = textField.text;
    setState(() {
      zipCode = zcode;
    });
    var data = {"zipcode": zcode};
    Firestore.instance
        .collection("flat")
        .document(flatId)
        .updateData(data)
        .then((updated) {
      zipCode = zcode;

      Utility.addToSharedPref(zipcode: zcode);
    });
    textField.clear();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      debugPrint("zipcode changed");
    });
  }

  _changeUserName(textField) async {
    String name = textField.text;
    var data = {"name": name};
    Firestore.instance
        .collection("user")
        .document(uID)
        .updateData(data)
        .then((updated) {
      userName = name;
      editedData.add("name");
      Utility.addToSharedPref(userName: name);
    });
    textField.clear();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      debugPrint("Username changed");
    });
  }
}
