import 'package:flutter/material.dart';

class SignUpBackground extends StatelessWidget {
  var progress;
  var level;

  SignUpBackground(this.level) {
    if (level == 1)
      progress = 0.02;
    else if (level == 2)
      progress = 0.5;
    else
      progress = 1.0;
  }

  Widget topHalf(BuildContext context) {
    return new Flexible(
        flex: 2,
        child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(children: <Widget>[
              LinearProgressIndicator(value: progress
               ),
              Container(margin: EdgeInsets.only(top: 5.0),color: Colors.white70,),
              Text("Step ${level}",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Montserrat',
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w700))
            ])));
  }

  final bottomHalf = new Flexible(
    flex: 3,
    child: new Container(
      color: Colors.white70,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[topHalf(context), bottomHalf],
    );
  }
}
