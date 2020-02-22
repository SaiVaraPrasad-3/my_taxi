import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_taxi/authentication/login.dart';
import 'package:my_taxi/screens/home.dart';
import 'package:my_taxi/states/db_data.dart';
import 'package:my_taxi/utils/core.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';
import '../ride_history.dart';

class DrawerBuilder extends StatefulWidget {
  @override
  _DrawerBuilderState createState() => _DrawerBuilderState();
}

class _DrawerBuilderState extends State<DrawerBuilder> {



  List data;
  List user = [];
  var userDetails;
  DatabaseData dbData = DatabaseData();




  @override
  Widget build(BuildContext context) {

//    return FutureBuilder(
//      future: dbData.getUserDetails(),
//      builder: (BuildContext context, AsyncSnapshot snapshot){
//        print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
//        print(snapshot.data);
//        if(snapshot.data == null){
//          return Container(
//              child: Center(
//                  child: Text("Loading...")
//              )
//          );
//        } else {
//          return ListView.builder(
//            itemCount: snapshot.data.length,
//            itemBuilder: (BuildContext context, int index) {
//              var name = snapshot.data[index][0]['first_name'].toString();
//              var lastname = snapshot.data[index][0]['last_name'].toString();
//              var contact_no =snapshot.data[index][0]['contact_no'].toString();
//              return ListTile(
//                        leading: CircleAvatar(
//                          child: Icon(Icons.image),
//                        ),
//                        title: Text("$name $lastname"),
//                        subtitle: Text(contact_no),
//                        onTap: (){},
//                      );
//
////                ListTile(
////                leading: CircleAvatar(
////                  child: Icon(Icons.image),
////                ),
////                title: Text("$name $lastname"),
////                subtitle: Text(contact_no),
////                onTap: (){},
////              );
//            },
//          );
//        }
//      },
//    );




    return Drawer(


//        child: FutureBuilder(
//          future: dbData.getUserDetails(),
//          builder: (BuildContext context, AsyncSnapshot snapshot){
//            print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
//            print(snapshot.data);
//            if(snapshot.data == null){
//              return Container(
//                  child: Center(
//                      child: Text("Loading...")
//                  )
//              );
//            } else {
//              return ListView.builder(
//                itemCount: snapshot.data.length,
//                itemBuilder: (BuildContext context, int index) {
//                  var name = snapshot.data[index][0]['first_name'].toString();
//                  var lastname = snapshot.data[index][0]['last_name'].toString();
//                  var contact_no =snapshot.data[index][0]['contact_no'].toString();
//                  return ListTile(
//                    leading: CircleAvatar(
//                      child: Icon(Icons.image),
//                    ),
//                    title: Text("$name $lastname"),
//                    subtitle: Text(contact_no),
//                    onTap: (){},
//                  );
//
////                ListTile(
////                leading: CircleAvatar(
////                  child: Icon(Icons.image),
////                ),
////                title: Text("$name $lastname"),
////                subtitle: Text(contact_no),
////                onTap: (){},
////              );
//                },
//              );
//            }
//          },
//        )




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

            //pick photo from gallery
            currentAccountPicture: GestureDetector(
              onTap: ()=> print("User profile pic clicked"),
              child: CircleAvatar(
                backgroundImage: NetworkImage(utils.profileTestImage),
              ),
            ),
            accountName:
                    myFutureBuilderUserName(),
            accountEmail:
                    myFutureBuilderUserNumber(),
            decoration: BoxDecoration(
              color: Colors.yellowAccent
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
            leading: Icon(AntDesign.sharealt),
            title: Text("Share"),
            onTap: () {
              //Share up option
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
          )
        ],
      ),
    );
  }

  myFutureBuilderUserName (){
    return FutureBuilder(
      future: dbData.getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.data == null){
          return  Text("Loading...");
        } else {
          return
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var name = snapshot.data[index][0]['first_name'].toString();
                var lastname = snapshot.data[index][0]['last_name'].toString();
                var contact_no =snapshot.data[index][0]['contact_no'].toString();
                return Text("$name $lastname",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26.0));
              },
            );
        }
      },
    );
  }
  myFutureBuilderUserNumber (){
    return FutureBuilder(
      future: dbData.getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.data == null){
          return  Text("Loading...");
        }
        else
          {
          return
            ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var contactNo =snapshot.data[index][0]['contact_no'].toString();
                print(contactNo);
                return Text("$contactNo",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14.0));
              },
            );
        }
      },
    );
  }




}

