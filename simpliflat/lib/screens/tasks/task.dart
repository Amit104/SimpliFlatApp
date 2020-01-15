import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/Res/strings.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:simpliflat/screens/models/models.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskDetail();
  }
}

class TaskDetail extends State<Task> {
  static const _priorities = ["High", "Low"];

  TextEditingController tc = TextEditingController();
  TextEditingController dc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropdownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropdownStringItem,
                      child: Text(dropdownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: 'Low',
                  onChanged: (valueSelected) {
                    setState(() {
                      debugPrint('User selected something');
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: tc,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed');
                },
                decoration: InputDecoration(
                    labelText: 'Task',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: dc,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Something changed');
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('Saved');
                          });
                        }),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                      child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete');
                            });
                          }))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
