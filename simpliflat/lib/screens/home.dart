import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/screens/profile/profile.dart';
import 'package:simpliflat/screens/profile/user_profile.dart';
import 'package:simpliflat/screens/tasks/task_list.dart';
import 'package:simpliflat/screens/utility.dart';
import 'package:simpliflat/screens/noticeboard.dart';
import 'package:simpliflat/screens/models/DatabaseHelper.dart';
import 'package:simpliflat/screens/globals.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dashboard.dart';
import 'lists/shopping_list.dart';
import 'package:simpliflat/screens/Calendar/googlecalendar.dart';
import 'tenant_portal/tenant_portal.dart';

class Home extends StatefulWidget {
  final flatId;

  Home(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _Home(this.flatId);
  }
}

class _Home extends State<Home> {
  int _selectedIndex = 0;

  //profile details
  final flatId;
  String flatName = "Hey!";
  String displayId = "";
  String userName = "";
  String userPhone = "";
  String landlordId;

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

  // Initialise Firestore notifications
  @override
  void initState() {
    super.initState();
    _updateUserDetails();
    fetchFlatName(context);
    _getLandlord();
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

    // notification token check.
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
                ? Dashboard(flatId)
                : (_selectedIndex == 1
                    ? TaskList(flatId, false)
                    : (_selectedIndex == 2
                        ? ShoppingLists(flatId)
                        : UserProfile())),
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), title: Text('Dashboard')),
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.tasks_1), title: Text('Tasks')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), title: Text('Lists')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('My Flat')),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.indigo[900],
            fixedColor: Colors.red[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new FloatingActionButton(
            onPressed: () async {
              var _flatId = flatId;
              if (flatId == null || flatId == "")
                _flatId = await Utility.getFlatId();
              List<Map<String, dynamic>> offlineDocuments = await _query();
              navigateToNotice(_flatId, offlineDocuments);
            },
            tooltip: 'Noticeboard',
            backgroundColor: Colors.red[900],
            child: new Icon(Icons.arrow_drop_up),
          ),
        ));
  }

  // get offline notices
  Future<List<Map<String, dynamic>>> _query() async {
    final allRows = await dbHelper.queryRows(globals.noticeBoard);
    return allRows;
  }

  void navigateToNotice(
      var flatId, List<Map<String, dynamic>> offlineDocuments) async {
    var _userId = await Utility.getUserId();
    Navigator.push(context, _createRoute(flatId, _userId, offlineDocuments));
  }

  //animated transition to noticeboard
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

  // Navigation for bottom navigation buttons
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //update user info if missing in shared preferences
  void _updateUserDetails() async {
    var _userId = await Utility.getUserId();
    var _userName = await Utility.getUserName();
    var _userPhone = await Utility.getUserPhone();
    if (_userName == null ||
        _userName == "" ||
        _userPhone == null ||
        _userPhone == "") {
      Firestore.instance.collection(globals.user).document(_userId).get().then(
          (snapshot) {
        if (snapshot.exists) {
          if (mounted)
            setState(() {
              userName = snapshot.data['name'];
              userPhone = snapshot.data['phone'];
            });
          Utility.addToSharedPref(userName: userName);
          Utility.addToSharedPref(userPhone: userPhone);
        }
      }, onError: (e) {});
    } else {
      userName = await Utility.getUserName();
      userPhone = await Utility.getUserPhone();
    }
  }

  // update flat info if missing in shared preferences
  void fetchFlatName(context) async {
    Utility.getFlatName().then((name) {
      if (flatName == null ||
          flatName == "" ||
          displayId == "" ||
          displayId == null) {
        Firestore.instance
            .collection(globals.flat)
            .document(flatId)
            .get()
            .then((flat) {
          if (flat != null) {
            Utility.addToSharedPref(flatName: flat['name'].toString());
            Utility.addToSharedPref(displayId: flat['display_id'].toString());
            if (mounted)
              setState(() {
                displayId = flat['display_id'].toString();
                flatName = flat['name'].toString().trim();
                if (flatName == null || flatName == "") flatName = "Hey!";
              });
          }
        });
      }
      if (name != null) {
        if (mounted)
          setState(() {
            flatName = name;
          });
      } else {
        if (mounted)
          setState(() {
            flatName = "Hey there!";
          });
      }
    });
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void _getLandlord() async {
    landlordId = await Utility.getLandlordId();
    if (landlordId != null) debugPrint("shared pref " + landlordId);
    try {
      await Firestore.instance.runTransaction((transaction) async {
        var flat = await transaction
            .get(Firestore.instance.collection(globals.flat).document(flatId));
        if (flat != null && flat['landlord_id'] != null) {
          //add landlord name too
          debugPrint("online landlord" + flat['landlord_id'].toString().trim());
          var landlord = await transaction.get(Firestore.instance
              .collection(globals.landlord)
              .document(flat['landlord_id']));
          globals.landlordIdValue = flat['landlord_id'].toString().trim();
          globals.landlordNameValue = landlord['name'].toString().trim();
          Utility.addToSharedPref(
              landlordId: flat['landlord_id'].toString().trim(),
              landlordName: landlord['name'].toString().trim());

          if (mounted)
            setState(() {
              landlordId = flat["landlord_id"].toString().trim();
            });
        } else if (flat != null &&
            (flat['landlord_id'] == null || flat['landlord_id'] == "")) {
          debugPrint("online empty landlord ");
          Utility.removeLandlordId();
        }
        String apartmentName = flat.data['apartment_name'];
        String apartmentNumber = flat.data['apartment_number'];
        String zipcode = flat.data['zipcode'];
        Utility.addToSharedPref(
            apartmentName: apartmentName,
            apartmentNumber: apartmentNumber,
            zipcode: zipcode);
      });
    } catch (e) {}
  }
}
