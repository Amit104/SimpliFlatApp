import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../main.dart';
import '../../utility.dart';


class SearchFlat extends StatefulWidget {
  final flatId, buildingData, blockName, blockId;

  SearchFlat(this.flatId, this.buildingData, this.blockId, this.blockName);

  @override
  State<StatefulWidget> createState() {
    return _SearchFlat(flatId, buildingData, blockId, blockName);
  }
}

class _SearchFlat extends State<SearchFlat> {
  var _navigatorContext;
  final flatId, buildingData, blockName, blockId;
  final globalKey = new GlobalKey<ScaffoldState>();

  _SearchFlat(this.flatId, this.buildingData, this.blockId, this.blockName);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(blockName),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(
          builder: (BuildContext scaffoldContext) {
            _navigatorContext = scaffoldContext;
            return StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection(globals.building).document(buildingData.documentID).collection(globals.block).document(blockId).collection(globals.ownerFlat).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return LoadingContainerVertical(3);
                if (snapshot.data.documents.length == 0)
                  return Container(
                    child: Center(
                      child: CommonWidgets.textBox("Error!", 22),
                    ),
                  );

                snapshot.data.documents.sort(
                    (a, b) => a['flatName'].compareTo(b['flatName']));

                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListItem(
                        snapshot.data.documents[index], index);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItem(DocumentSnapshot list, index) {
    TextStyle textStyle = Theme.of(_navigatorContext).textTheme.subhead;

    return Padding(
      padding: const EdgeInsets.only(
        right: 8.0,
        left: 8.0,
        bottom: 3.0,
      ),
      child: SizedBox(
        width: MediaQuery.of(_navigatorContext).size.width * 0.85,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: Icon(
                Icons.group_add,
                color: Colors.green,
              ),
              title: Text(list['flatName'].toString().trim(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  )),
              onTap: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text('Request'),
                      content: new Text(
                          'Send a request to - ' + buildingData['buildingName'].toString().trim() + " " + blockName + list['flatName'].toString().trim(), style: TextStyle(fontSize: 14.0,),),
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
                              _inviteLandlordAPI(_navigatorContext);
                            }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _inviteLandlordAPI(scaffoldContext) async {
    var flatName = await Utility.getFlatName();
    var uID = await Utility.getUserId();
    debugPrint("UserId is " + uID.toString());
    List landlordFlatList = new List();
    /*Firestore.instance
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
              batch.updateData(toAccept, {'status': 1, 'updated_at': timeNow});

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
                debugPrint("ADDED LANDLORD");
                Utility.addToSharedPref(landlordId: landlordUserId);
                setState(() {
                  _backHome();
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
              if (oldRequests != null && oldRequests.documents.length != 0) {
                for (var doc in oldRequests.documents) {
                  batch.updateData(doc.reference, {'status': -1});
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
                if (checker.documents == null ||
                    checker.documents.length == 0) {
                  debugPrint("CREATING REQUEST");

                  var reqRef = Firestore.instance
                      .collection(globals.requestsLandlord)
                      .document();
                  batch.setData(reqRef, newReq);

                  batch.commit().then((res) async {
                    debugPrint("Request Created");
                    _setErrorState(scaffoldContext, "Request created!",
                        textToSend: "Request created!");
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
                    _setErrorState(scaffoldContext, "Request created!",
                        textToSend: "Request created!");
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
    });*/
  }

  void _backHome() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyApp()),
            (Route<dynamic> route) => false);
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

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
