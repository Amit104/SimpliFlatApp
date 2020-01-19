import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat/screens/models/DatabaseHelper.dart';

class DocumentManager extends StatefulWidget {
  final _flatId;

  DocumentManager(this._flatId);

  @override
  State<StatefulWidget> createState() {
    return _DocumentManager(_flatId);
  }
}

class _DocumentManager extends State<DocumentManager> {
  final _flatId;
  var _navigatorContext;
  var currentUserId;
  var date = DateFormat("yyyy-MM-dd");
  TextEditingController note = TextEditingController();
  TextEditingController addNote = TextEditingController();

  final dbHelper = DatabaseHelper.instance;

  _DocumentManager(this._flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document Manager"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Builder(
        builder: (BuildContext scaffoldC) {
          _navigatorContext = scaffoldC;

          return Container();
        },
      ),
    );
  }

}
