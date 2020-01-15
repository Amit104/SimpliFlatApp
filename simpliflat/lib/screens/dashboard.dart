import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpliflat/screens/widgets/loading_container.dart';

class Dashboard extends StatefulWidget {
  final flatId;

  Dashboard(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return DashboardState(this.flatId);
  }
}

class DashboardState extends State<Dashboard> {
  var _navigatorContext;
  final flatId;

  DashboardState(this.flatId);

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
          title: Text("SimpliFlat"),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
            ],
          );
        }),
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, true);
  }
}
