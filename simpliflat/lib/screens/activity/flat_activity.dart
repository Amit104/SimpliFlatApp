import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FlatActivity extends StatefulWidget {
  final flatId;

  FlatActivity(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return FlatActivityState(this.flatId);
  }
}

//TODO - add activity
class FlatActivityState extends State<FlatActivity> {
  var _navigatorContext;
  final flatId;

  FlatActivityState(this.flatId);

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
          title: Text("Activity"),
          elevation: 0.0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;
          return Container(
            width: 100,
            height: 100,
            child: Text("Activity"),
          );
        }),
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, "");
  }
}
