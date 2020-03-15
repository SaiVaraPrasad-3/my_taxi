import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_taxi/screens/home.dart';
import 'package:my_taxi/utils/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'loginUtils.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState () => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  Dio dio = new Dio();
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build (BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent));
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            headerSection(),
            bodySection(),
//              forgetPasswordSection(),
          ],
        ),
      ),
    );
  }



  signUp(String phoneNumber, pass, name, lastName, email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      "name": name,
      "lastname": lastName,
      "contact_no": phoneNumber,
      "password": pass,
      "email": email == '' ? "Not available": email
    };

    debugPrint(data.toString());
    try {
//    var jsonResponse = null;
//    var response = await http.post("${_localhost()}/taxi/user/login", body: data);
      Response response = await dio.post (
          "${localhost (
          )}/taxi/user/register", data: data );
//    print(response.data);
//    print(response.statusCode);
      if (response.statusCode == 200) {
//      jsonResponse = json.decode(response.data);
        print (
            "============================" );
        print (
            response.data );
        print (
            response.data['token'] );
        if (response.data != null) {
          setState (
                  ( ) {
                _isLoading = false;
              } );
          sharedPreferences.setString (
              "token", response.data['token']
          );
          sharedPreferences.setInt (
            "id", response.data['id'],
          );
          Navigator.of (
              context ).pop (
          );
          Navigator.of (
              context ).pushAndRemoveUntil (
              MaterialPageRoute (
                  builder: ( BuildContext context ) =>
                      MyHomePage (
                        title: "My Taxi", ) ), (
              Route<dynamic> route ) => false );
        }
      }
    }on DioError catch(error) {
      setState (
              ( ) {
            _isLoading = true;
          } );
      final snackBar = SnackBar(content: Text(error.response.data),
        duration: const Duration(seconds: 5),);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }






  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();


  Container headerSection () {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height / 5,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf45d27),
              Color(0xFFf5851f)
            ],
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(90)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: Icon(Icons.local_taxi,
              size: 70,
              color: Colors.white,
            ),
          ),
          Spacer(),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 32,
                  right: 32
              ),
              child: Text('Register User',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Container bodySection () {
    return Container(
        height: MediaQuery
            .of(context)
            .size
            .height ,
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: <Widget>[

            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1.2,
              height: 45,
              padding: EdgeInsets.only(
                  top: 4, left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(50)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5
                    )
                  ]
              ),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.smartphone,
                    color: Colors.grey,
                  ),
                  hintText: 'Mobile Number',
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1.2,
              height: 45,
              margin: EdgeInsets.only(top: 25),
              padding: EdgeInsets.only(
                  top: 4, left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(50)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5
                    )
                  ]
              ),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.person,
                    color: Colors.grey,
                  ),
                  hintText: 'Name',
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1.2,
              height: 45,
              margin: EdgeInsets.only(top: 25),
              padding: EdgeInsets.only(
                  top: 4, left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(50)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5
                    )
                  ]
              ),
              child: TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.person_outline,
                    color: Colors.grey,
                  ),
                  hintText: 'Last Name',
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1.2,
              height: 45,
              margin: EdgeInsets.only(top: 25),
              padding: EdgeInsets.only(
                  top: 4, left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(50)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5
                    )
                  ]
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.vpn_key,
                    color: Colors.grey,
                  ),
                  hintText: 'Password',
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1.2,
              height: 45,
              margin: EdgeInsets.only(top: 25, bottom: 25),
              padding: EdgeInsets.only(
                  top: 4, left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(50)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5
                    )
                  ]
              ),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.email,
                    color: Colors.grey,
                  ),
                  hintText: 'Email (optional)',
                ),
              ),
            ),
            RaisedGradientButton(
              child: Text(
                'Sign Up'.toUpperCase(),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight
                    .bold),
              ),
              gradient: LinearGradient(
                colors: <Color>[Colors.green, Colors.black],
              ),
//
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                signUp(phoneController.text, passwordController.text, nameController.text, lastNameController.text, emailController.text);
              },
            ),
            switchAuth(),
//             ),
          ],
        )
    );
  }
  Container switchAuth () {
    return Container(
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
//      margin: EdgeInsets.only(top: 15.0),
      child: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text("Already Registered?  Sign In",
            style:
            TextStyle(
              color: Colors.blueGrey,
              decoration: TextDecoration.underline,
//                decorationColor: Colors.black
            )
        ),
      ),
    );
  }


//
//
//
//
//  Container buttonSection() {
//    return Container(
//      width: MediaQuery.of(context).size.width,
//      height: 40.0,
//      padding: EdgeInsets.symmetric(horizontal: 15.0),
//      margin: EdgeInsets.only(top: 15.0),
//      child: RaisedButton(
//        onPressed: phoneController.text == "" || passwordController.text == "" || nameController.text == ""|| lastNameController.text == "" ? null : () {
//          setState(() {
//            _isLoading = true;
//          });
//          signUp(phoneController.text, passwordController.text, nameController.text, lastNameController.text, emailController.text);
//        },
//        elevation: 0.0,
//        color: Colors.purple,
//        child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
//        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//      ),
//    );
//  }
//
//
//  Container buttonSectionTwo() {
//    return Container(
////      height: 40.0,
////      padding: EdgeInsets.symmetric(horizontal: 15.0),
////      margin: EdgeInsets.only(top: 15.0),
//      child: FlatButton(
//        onPressed: () => Navigator.of(context).pop(),
//        child: Text("Already registered?  Sign In",
//            style:
//            TextStyle(
//                color: Colors.white70,
//                decoration: TextDecoration.underline,
//                decorationColor: Colors.yellow
//            )
//        ),
//      ),
//    );
//  }
//
//  Container textSection() {
//    return Container(
//      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
//      child: Column(
//        children: <Widget>[
//          TextFormField(
//            controller: phoneController,
//            cursorColor: Colors.white,
//
//            style: TextStyle(color: Colors.white70),
//            decoration: InputDecoration(
//              icon: Icon(Icons.phone, color: Colors.white70),
//              hintText: "Phone Number",
//              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
//              hintStyle: TextStyle(color: Colors.white70),
//            ),
//          ),
//          SizedBox(height: 20.0),
//          TextFormField(
//            controller: nameController,
//            cursorColor: Colors.white,
//
//            style: TextStyle(color: Colors.white70),
//            decoration: InputDecoration(
//              icon: Icon(Icons.person, color: Colors.white70),
//              hintText: "Name",
//              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
//              hintStyle: TextStyle(color: Colors.white70),
//            ),
//          ),
//          SizedBox(height: 20.0),
//          TextFormField(
//            controller: lastNameController,
//            cursorColor: Colors.white,
//            style: TextStyle(color: Colors.white70),
//            decoration: InputDecoration(
//              icon: Icon(Icons.person, color: Colors.white70),
//              hintText: "Last Name",
//              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
//              hintStyle: TextStyle(color: Colors.white70),
//            ),
//          ),
//          SizedBox(height: 20.0),
//          TextFormField(
//            controller: passwordController,
//            cursorColor: Colors.white,
//            obscureText: true,
//            style: TextStyle(color: Colors.white70),
//            decoration: InputDecoration(
//              icon: Icon(Icons.lock, color: Colors.white70),
//              hintText: "Password",
//              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
//              hintStyle: TextStyle(color: Colors.white70),
//            ),
//          ),
//          SizedBox(height: 20.0),
//          TextFormField(
//            controller: emailController,
//            cursorColor: Colors.white,
//
//            style: TextStyle(color: Colors.white70),
//            decoration: InputDecoration(
//              icon: Icon(Icons.email, color: Colors.white70),
//              hintText: "Email (optional)",
//              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
//              hintStyle: TextStyle(color: Colors.white70),
//            ),
//          ),
//          SizedBox(height: 20.0),
//        ],
//      ),
//    );
//  }
//
//  Container headerSection() {
//    return Container(
//      margin: EdgeInsets.only(top: 50.0),
//      padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 30.0),
//      child: Text("My Taxi",
//          style: TextStyle(
//              color: Colors.white70,
//              fontSize: 40.0,
//              fontWeight: FontWeight.bold)),
//    );
//  }
//
}
