import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:my_taxi/authentication/login.dart';
import 'package:my_taxi/maps/maps.dart';
import 'package:my_taxi/states/app_state.dart';
import 'package:my_taxi/states/db_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../utils/credentials.dart';
import './drawer/drawer.dart';
import 'package:flutter_icons/flutter_icons.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}): super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DatabaseData dbData  = DatabaseData();


  /// to check if the use is logged in
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
      }

      /// this method will check if the user is logged in or not
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  /// to change icon of drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    bool test=false;
    return Scaffold(
      body: MapClass(),
      key: _scaffoldKey,
      /// this button opens the drawer
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(top: 65,
            left: 30,
            child: Container(height: 45.0,
              width: 45.0,
              child: FittedBox(child: ClipOval(
                child: Material(color: Colors.yellow.shade100, // button color
                  child: InkWell(splashColor: Colors.orange,
                    // inkwell color
                    child: SizedBox(
                        width: 56,height: 56,child: Icon(Icons.menu)),
                    onTap: ()=> _scaffoldKey.currentState.openDrawer(),),),)
                //               RaisedButton(
                //
                //                 child: Icon(Icons.menu),
                ////                 backgroundColor: Colors.grey[200],s
                //                 onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
                //                 ),
              ),)),
      ],),
//      bottomSheet: SolidBottomSheet
      drawer: DrawerBuilder(),);
  }
}




