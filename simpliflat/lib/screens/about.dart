import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/widgets/loading_container.dart';

class About extends StatefulWidget {
  About();

  @override
  State<StatefulWidget> createState() => new _About();
}

class _About extends State<About> {
  var _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return WillPopScope(
      onWillPop: () {
        _moveToLastScreen(context);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("About Us"),
          elevation: 0.0,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          _scaffoldContext = scaffoldC;
          return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection(globals.about)
                .snapshots(),
            builder:
                (context, AsyncSnapshot<QuerySnapshot> aboutSnapshot) {
              if (!aboutSnapshot.hasData)
                return LoadingContainerVertical(3);
              var about = aboutSnapshot.data.documents[0]['data'];
              return Html(
                data: about,
              );
            },
          );
        }),
      ),
    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext);
  }
}
