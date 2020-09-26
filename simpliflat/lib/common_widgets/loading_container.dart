import 'package:flutter/material.dart';
import 'dart:async';

class LoadingContainerVertical extends StatefulWidget{
  final count;
  final width;
  LoadingContainerVertical(this.count, {this.width});

  @override
  State<StatefulWidget> createState() {
    return _LoadingContainerVertical(count, width: width);
  }
}

class _LoadingContainerVertical extends State<LoadingContainerVertical> {
  final count;
  final width;
  var _color = Colors.grey[200];

  _LoadingContainerVertical(this.count, {this.width});

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() {
          _color = Colors.white;
        });
        Timer(Duration(milliseconds: 500), () {
          if(mounted) {
            setState(() {
              _color = Colors.grey[200];
            });
          }
        });
      }

    });
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder:(BuildContext context, int position) {
        return Column(
          children: <Widget>[
            buildContainer(context),
          ],
        );},
      itemCount: count,
    );
  }

  Widget buildContainer(context) {
    return AnimatedContainer(
      margin: EdgeInsets.all(10.0),
      width: width==null?MediaQuery.of(context).size.width - 10.0:width,
      height: 35.0,
      color: _color,
      duration: Duration(milliseconds: 500),
    );
  }

}

class LoadingContainerHorizontal extends StatefulWidget{
  final h;
  LoadingContainerHorizontal(this.h);
  @override
  State<StatefulWidget> createState() {
    return _LoadingContainerHorizontal(h);
  }

}
class _LoadingContainerHorizontal extends State<LoadingContainerHorizontal>{
  final h;
  var _color = Colors.grey[200];
  _LoadingContainerHorizontal(this.h);

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() {
          _color = Colors.white;
        });
        Timer(Duration(milliseconds: 500), () {
          if(mounted) {
            setState(() {
              _color = Colors.grey[200];
            });
          }
        });
      }

    });

    return ListView.builder(
      itemBuilder:(BuildContext context, int position) {
        return Row(
          children: <Widget>[
            buildContainer(context, h),
          ],
        );},
      scrollDirection: Axis.horizontal,
      itemCount: 7,
    );

  }

  Widget buildContainer(context, h) {
    return AnimatedContainer(
      width: MediaQuery.of(context).size.width/7,
      height: h,
      color: _color,
      margin: EdgeInsets.all(7.0),
      duration: Duration(milliseconds: 500),
    );
  }
}