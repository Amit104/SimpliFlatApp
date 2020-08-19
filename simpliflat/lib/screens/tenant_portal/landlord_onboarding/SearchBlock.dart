import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SearchFlat.dart';


class SearchBlock extends StatefulWidget {
  final flatId, buildingData;

  SearchBlock(this.flatId, this.buildingData);

  @override
  State<StatefulWidget> createState() {
    return _SearchBlock(flatId, buildingData);
  }
}

class _SearchBlock extends State<SearchBlock> {
  var _navigatorContext;
  final flatId, buildingData;
  final globalKey = new GlobalKey<ScaffoldState>();

  _SearchBlock(this.flatId, this.buildingData);

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
          title: Text(buildingData['buildingName'].toString().trim()),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(
          builder: (BuildContext scaffoldContext) {
            _navigatorContext = scaffoldContext;
            return StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection(globals.building).document(buildingData.documentID).collection(globals.block).snapshots(),
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
                    (a, b) => a['blockName'].compareTo(b['blockName']));

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
                Icons.group,
                color: Colors.green,
              ),
              title: Text(list['blockName'].toString().trim(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  )),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SearchFlat(flatId, buildingData, list.documentID, list['blockName'].toString().trim())));
              },
            ),
          ),
        ),
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
