import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'dart:async';

class CommonWidgets {
  static Widget optionText(String message, BuildContext context, {List list}) {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      height: (list == null || list.length == 0)
          ? 5.0
          : MediaQuery.of(context).size.height / 20.0,
      child: (list == null || list.length == 0)
          ? null
          : textBox(message, 15.0, fontStyle: FontStyle.italic),
    );
  }

  static Widget textBox(String text, double fontSize,
      {String fontFamily = 'Montserrat', fontStyle = FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.indigo}) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          fontStyle: fontStyle),
    );
  }

  static Widget swipeBackground() {
    return Container(
      color: Colors.red[600],
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                Expanded(
                  flex: 10,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

}