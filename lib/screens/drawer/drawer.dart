import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_taxi/authentication/login.dart';
import 'package:my_taxi/screens/confirm_booking_screen.dart';
import 'package:my_taxi/screens/home.dart';
import 'package:my_taxi/screens/customer_care.dart';
import 'package:my_taxi/states/db_data.dart';
import 'package:my_taxi/utils/core.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';
import '../ride_history.dart';
import '../customer_care.dart';

class DrawerBuilder extends StatefulWidget {
  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {

  DatabaseData _dbData = DatabaseData();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
           // pick photo from gallery
            currentAccountPicture: GestureDetector(
              onTap: ()=> print("User profile pic clicked"),
              child: ClipOval(
                 child: Image.network(utils.profileTestImage),
              )
            ),
            accountName:
//                      Text("Name"),
                    myFutureBuilderUserName(),
            accountEmail:
//                    Text("Number"),
                    myFutureBuilderUserNumber(),
            decoration: BoxDecoration(
              color: Colors.yellow.shade200
            ),
          ),
          ListTile(
            leading: Icon(AntDesign.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Ionicons.md_time),
            title: Text('History'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RideHistory()),
              );
            },
          ),
          ListTile(
            leading: Icon(AntDesign.customerservice),
            title: Text("Customer Care"),
            onTap: () {
              //Share up option
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerCare()),
              );
            },
          ),
          ListTile(
            leading: Icon(AntDesign.logout),
            title: Text("Logout"),
            onTap: () async{
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              //log out from the app
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: Icon(AntDesign.rest),
            title: Text("Test"),
            onTap: () async{
//              Navigator.of(context).pop();
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => ConfirmBooking()),
//              );
            },
          )
        ],
      ),
    );
  }

  myFutureBuilderUserName (){
    return FutureBuilder(
      future: _dbData.getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.data == null){
          return  Text("Loading...");
        } else {
          var name = snapshot.data[0][0]['first_name'].toString();
          var lastName = snapshot.data[0][0]['last_name'].toString();
          var contact_no =snapshot.data[0][0]['contact_no'].toString();
          return Text("$name $lastName"
              ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26.0)
          );
        }
      },
    );
  }
  myFutureBuilderUserNumber (){
    return FutureBuilder(
      future: _dbData.getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.data == null){
          return  Text("Loading...");
        }
        else
          {
            var contactNo =snapshot.data[0][0]['contact_no'].toString();
            print(contactNo);
            return Text("$contactNo",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0));
        }
      },
    );
  }
}

