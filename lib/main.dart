import 'package:flutter/material.dart';
import 'package:my_taxi/screens/auth_screen.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "my taxi",
      // routes: <String, WidgetBuilder>{
      //   '/homepage': (BuildContext context) => MyHomePage(),
      //   '/loginpage': (BuildContext context)=> MyApp(),
      // },
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: "My Taxi"),
      // home: MyAppPage(title: "Sign Up"),
    );
  }
}
