import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_taxi/utils/core.dart' as utils;

class DrawerBuilder extends StatefulWidget {
  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
        /*  Container(
            height: 240,
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //Driver image here
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/person.png',
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Customer Name here'),
                  SizedBox(
                    height: 5.0,
                  )
                  //driver details after name here
                ],
              ),
              decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage('assets/images/person.png'),
                //   fit: BoxFit.contain
                // ),
                color: Colors.yellow,
              ),
            ),
          ), */
          UserAccountsDrawerHeader(
            accountName: Text("User Account  name"),
            accountEmail: Text("mobile number"),
            //pick photo from gallery
            currentAccountPicture: GestureDetector(
              onTap: ()=> print("User profile pic clicked"),
              child: CircleAvatar(
                backgroundImage: NetworkImage(utils.profileTestImage),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.yellowAccent
            ),
          ),
          ListTile(
            leading: Icon(AntDesign.home),
            title: Text('Home'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(Ionicons.md_time),
            title: Text('History'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(AntDesign.sharealt),
            title: Text("Share"),
            onTap: () {
              //Share up option
            },
          ),
          ListTile(
            leading: Icon(AntDesign.logout),
            title: Text("Logout"),
            onTap: () {
              //log out from the app
            },
          )
        ],
      ),
    );
  }
}
