import 'package:flutter/material.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/signup/create_or_join.dart';
import 'package:simpliflat/screens/signup/signupPhoneNumber.dart';
import 'package:flutter/services.dart';

class StartNavigation extends StatelessWidget {
  final flag;
  final requestDenied;
  final List incomingRequests;
  final flatId;

  StartNavigation(this.flag, this.requestDenied, this.incomingRequests, this.flatId);

  @override
  Widget build(BuildContext context) {
    debugPrint("Flag in navigation screen is " + flag.toString());
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen(context);
      },
      child: flag == 1
          ? SignUpPhone()
          : (flag == 2
              ? CreateOrJoin(requestDenied, incomingRequests)
              : Home(flatId)),
    );
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
