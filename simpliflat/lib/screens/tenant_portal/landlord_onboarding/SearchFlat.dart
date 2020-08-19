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
                              _inviteLandlordAPI(_navigatorContext, list);
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

  void _inviteLandlordAPI(scaffoldContext, ownerFlatData) async {
    var flatName = await Utility.getFlatName();
    var userPhone = await Utility.getUserPhone();
    var userName = await Utility.getUserName();
    var uID = await Utility.getUserId();

    //check if we have a request from this landlord
    Firestore.instance
        .collection(globals.requestsLandlord)
        .where("building_id", isEqualTo: buildingData.documentID)
        .where("block_id", isEqualTo: blockId)
        .where("owner_flat_id", isEqualTo: ownerFlatData.documentID)
        .where("tenant_flat_id", isEqualTo: flatId)
        .where("request_from_tenant", isEqualTo: 0)
        .where("status", isEqualTo: 0)
        .limit(1)
        .getDocuments()
        .then((incomingReq) {
      var now = new DateTime.now();
      if (incomingReq.documents != null &&
          incomingReq.documents.length != 0) {
        debugPrint("LANDLORD REQUEST TO FLAT EXISTS!");
        if(mounted)
          _setErrorState(scaffoldContext, "A request from this flat already exists!");
        ///TODO: accept current request
      } else {
        debugPrint("LANDLORD REQUEST TO FLAT DOES NOT EXIST!");
        Map<String, dynamic> newReq = {
          'building_id' : buildingData.documentID,
          'block_id' : blockId,
          'owner_flat_id' : ownerFlatData.documentID,
          'tenant_flat_id': flatId,
          'request_from_tenant': 1,
          'status': 0,
          'created_at': now,
          'updated_at': now,
          'created_by' : { "user_id" : uID, 'name' : userName, 'phone' : userPhone },
          'tenant_flat_name' : flatName,
          'building_details' : {'building_name' : buildingData['buildingName'],'building_zipcode' : buildingData['zipcode'],'building_address' : buildingData['buildingAddress']} ,
        };
        Map<String, dynamic> updatedReq = {
          'building_id' : buildingData.documentID,
          'block_id' : blockId,
          'owner_flat_id' : ownerFlatData.documentID,
          'tenant_flat_id': flatId,
          'request_from_tenant': 1,
          'status': 0,
          'updated_at': now,
          'created_by' : { "user_id" : uID, 'name' : userName, 'phone' : userPhone },
          'tenant_flat_name' : flatName,
          'building_details' : {'building_name' : buildingData['buildingName'],'building_zipcode' : buildingData['zipcode'],'building_address' : buildingData['buildingAddress']} ,
        };
        Firestore.instance
            .collection(globals.requestsLandlord)
            .where("tenant_flat_id", isEqualTo: flatId)
            .where("request_from_tenant", isEqualTo: 1)
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
              .where("building_id", isEqualTo: buildingData.documentID)
              .where("block_id", isEqualTo: blockId)
              .where("owner_flat_id", isEqualTo: ownerFlatData.documentID)
              .where("tenant_flat_id", isEqualTo: flatId)
              .where("request_from_tenant", isEqualTo: 1)
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
                _backHome();
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
                _backHome();
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
