import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:simpliflat/models/user_login_info.dart';
import 'package:simpliflat/screens/home.dart';
import 'package:simpliflat/screens/signup/create_or_join.dart';
import 'package:simpliflat/screens/signup/signupPhoneNumber.dart';
import 'package:simpliflat/screens/start_navigation.dart';
import 'package:simpliflat/services/startup_service.dart';
import 'package:simpliflat/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StartupService.getUserLoginInfo(),
        builder: (BuildContext context, AsyncSnapshot<UserLoginInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            UserLoginInfo userLoginInfo = snapshot.data;
            return userLoginInfo.flag.index == 0
                ? SignUpPhone()
                : (userLoginInfo.flag.index == 1
                    ? CreateOrJoin(userLoginInfo.requestStatus.index,
                        userLoginInfo.incomingRequests)
                    : Home(userLoginInfo.flatId));
          }
          return SplashScreen();
        });
  }
}
