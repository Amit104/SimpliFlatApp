import 'package:flutter/material.dart';
import 'package:simpliflat/icons/icons_custom_icons.dart';
import 'package:simpliflat/screens/tasks/task_list.dart';
import 'document_manager.dart';
import 'message_board.dart';

class TenantPortal extends StatefulWidget {
  final flatId;

  TenantPortal(this.flatId);

  @override
  State<StatefulWidget> createState() {
    return _TenantPortal(this.flatId);
  }
}

class _TenantPortal extends State<TenantPortal> {
  int _selectedIndex = 0;

  //profile details
  final flatId;
  String flatName = "Hey!";
  String displayId = "";
  String userName = "";
  String userPhone = "";
  var userId;

  _TenantPortal(this.flatId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen(context);
          return null;
        },
        child: Scaffold(
          body: Center(
            child: _selectedIndex == 0
                ? TaskList(flatId)
                : (_selectedIndex == 1
                    ? MessageBoard(flatId)
                    : DocumentManager(flatId)),
          ),
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(IconsCustom.tasks_1), title: Text('Tasks')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), title: Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_drive_file), title: Text('Documents')),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.indigo[900],
            fixedColor: Colors.red[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ));
  }

  // Navigation for bottom navigation buttons
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  moveToLastScreen(_navigatorContext) {
    Navigator.pop(_navigatorContext, true);
  }
}
