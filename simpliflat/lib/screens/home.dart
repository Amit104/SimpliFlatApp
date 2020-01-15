import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/screens/profile/profile.dart';
import 'package:simpliflat/screens/tasks/task_list.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/noticeboard.dart';
import 'package:simpliflat/screens/models/DatabaseHelper.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'activity/flat_activity.dart';
import 'lists/shopping_list.dart';

class Home extends StatefulWidget {
  final flatId;

  Home(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _Home(this.flatId);
  }
}

class _Home extends State<Home> {
  int _selectedIndex = 1;
  final flatId;

  _Home(this.flatId);

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _notificationNavigate(message) async {
    debugPrint("resume called" + message['data']['screen']);

    ///NEW NOTIFICATION NOTICEBOARD
    if (message['data']['screen'] == globals.noticeBoard) {
      var _flatId = await Utility.getFlatId();
      var _userId = await Utility.getUserId();
      List<Map<String, dynamic>> offlineDocuments = await _query();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return Notice(_flatId, _userId, offlineDocuments);
        }),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    var notificationToken;
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
      debugPrint("lanuch called");
      _notificationNavigate(message);
      return null;
    }, onMessage: (Map<String, dynamic> message) {
      debugPrint("message called ");
      _notificationNavigate(message);
      return null;
    }, onResume: (Map<String, dynamic> message) async {
      _notificationNavigate(message);
    });

    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(alert: true, badge: true, sound: true));

    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("IOS Setting resgistered");
    });
    Utility.getToken().then((token) {
      if (token == null || token == "") {
        firebaseMessaging.getToken().then((token) async {
          debugPrint("TOKEN = " + token);
          notificationToken = token;
          if (token == null) {
          } else {
            var userId = await Utility.getUserId();
            Firestore.instance
                .collection(globals.user)
                .document(userId)
                .updateData({'notification_token': notificationToken}).then(
                    (updated) {
              Utility.addToSharedPref(notificationToken: notificationToken);
            });
          }
        });
      }
    });
  }

  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
          return null;
        },
        child: Scaffold(
          body: Center(
            child: _selectedIndex == 0
                ? Profile()
                : (_selectedIndex == 1
                    ? TaskList(flatId)
                    : (_selectedIndex == 2 ? ShoppingLists(flatId) : FlatActivity(flatId))),
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('My Flat')),
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.tasks_1), title: Text('Tasks')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), title: Text('Lists')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.done_all), title: Text('Activity')),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.black,
            fixedColor: Colors.indigo[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed ,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new FloatingActionButton(
            onPressed: () async {
              var _flatId = await Utility.getFlatId();
              List<Map<String, dynamic>> offlineDocuments = await _query();
              navigateToNotice(_flatId, offlineDocuments);
            },
            tooltip: 'Noticeboard',
            backgroundColor: Colors.indigo[900],
            child: new Icon(Icons.arrow_drop_up),
          ),
        ));
  }

  Future<List<Map<String, dynamic>>> _query() async {
    final allRows = await dbHelper.queryRows(globals.noticeBoard);
    return allRows;
  }

  void navigateToNotice(
      var flatId, List<Map<String, dynamic>> offlineDocuments) async {
    var _userId = await Utility.getUserId();
    Navigator.push(context, _createRoute(flatId, _userId, offlineDocuments));
  }

  Route _createRoute(flatId, userId, offlineDocuments) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          Notice(flatId, userId, offlineDocuments),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
