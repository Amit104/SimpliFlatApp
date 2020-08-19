import 'package:flutter/material.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../../../main.dart';
import 'SearchBlock.dart';

class SearchBuilding extends StatefulWidget {
  final flatId;

  SearchBuilding(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _SearchBuilding(flatId);
  }
}

class _SearchBuilding extends State<SearchBuilding> {
  var _navigatorContext;
  final flatId;
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();
  bool _isSearching;
  String _searchText = "";

  _SearchBuilding(this.flatId) {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _controller.text;
        });
      }
    });
  }

  Icon icon = new Icon(
    Icons.search,
    color: Colors.indigo,
  );

  Widget appBarTitle = new Text(
    "Search your building",
    style: new TextStyle(color: Colors.indigo),
  );

  @override
  void initState() {
    super.initState();
    _isSearching = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: Builder(
          builder: (BuildContext scaffoldContext) {
            _navigatorContext = scaffoldContext;
            return StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection(globals.building).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return LoadingContainerVertical(3);
                if (snapshot.data.documents.length == 0)
                  return Container(
                    child: Center(
                      child: CommonWidgets.textBox("Error!", 22),
                    ),
                  );

                if (_searchText != null && _searchText != "")
                  snapshot.data.documents.removeWhere((s) =>
                      !s.data['buildingName'].toString().contains(_searchText));

                snapshot.data.documents.sort(
                    (a, b) => b['buildingName'].compareTo(a['buildingName']));

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

  Widget buildAppBar(BuildContext context) {
    return new AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
      new IconButton(
        icon: icon,
        onPressed: () {
          setState(() {
            if (this.icon.icon == Icons.search) {

              this.icon = new Icon(
                Icons.close,
                color: Colors.white,
              );
              this.appBarTitle = new TextField(
                controller: _controller,
                style: new TextStyle(
                  color: Colors.indigo,
                ),
                decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search, color: Colors.indigo),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.indigo)),
                onChanged: searchOperation,
                autofocus: true,
              );
              _handleSearchStart();
            } else {
              _handleSearchEnd();
            }
          });
        },
      ),
    ]);
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
              title: Text(list['buildingName'].toString().trim(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  )),
              subtitle: Text( "pincode - " + list['zipcode'].toString().trim(),
                  style: TextStyle(
                    fontSize: 11.0,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    color: Colors.black54,
                  )),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SearchBlock(flatId, list)));
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.indigo,
      );
      this.appBarTitle = new Text(
        "Search your building",
        style: new TextStyle(color: Colors.indigo),
      );
      _isSearching = false;
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    if (mounted)
      setState(() {
        _searchText = searchText;
      });
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
