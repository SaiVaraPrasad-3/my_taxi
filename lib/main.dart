import 'package:flutter/material.dart';
import 'package:my_taxi/authentication/login.dart';
import 'package:my_taxi/authentication/signup.dart';
import 'package:my_taxi/screens/auth_screen.dart';
import 'package:my_taxi/screens/customer_care.dart';
import 'package:my_taxi/screens/ride_history.dart';
import 'package:my_taxi/screens/splash_screen.dart';
import 'package:my_taxi/states/app_state.dart';
import 'package:provider/provider.dart';
import './screens/home.dart';

void main() async{
  /// to ensure the app starts from AppState
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(
    MultiProvider(providers:
     [
       ChangeNotifierProvider.value(value: AppState(),)
     ],
       child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  //This widget is the root of the application
  @override
  Widget build(BuildContext context) {
    final _title = "My Taxi";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
       routes: <String, WidgetBuilder>{
         '/homepage': (BuildContext context) => MyHomePage(title: _title,),
         '/login': (BuildContext context) => LoginPage(),
         '/signup': (BuildContext context) => SignUpPage(),
         '/history': (BuildContext context) => RideHistory(),
         '/customercare': (BuildContext context) => CustomerCare(),
       },
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
//      home: LoginPage(),
       home: SplashScreen(),
    );
  }
}
