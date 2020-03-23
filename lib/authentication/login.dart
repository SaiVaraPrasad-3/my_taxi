import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_taxi/utils/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:toast/toast.dart';
import 'loginUtils.dart';
import 'package:provider/provider.dart';
import '../screens/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = false;
  Dio dio = new Dio();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));

    return Scaffold(
      key: _scaffoldKey,
//      resizeToAvoidBottomInset: false,
      body: _isLoading ? Center( child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              headerSection(),

              bodySection(),
            ],
          ),
        ),
      ),
    );

//    return Scaffold(
//      body: Container(
//        decoration: BoxDecoration(
//          gradient: LinearGradient(
//              colors: [Colors.yellow, Colors.greenAccent],
//              begin: Alignment.topCenter,
//              end: Alignment.bottomCenter),
//        ),
//        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
//          children: <Widget>[
//            headerSection(),
//            textSection(),
//            buttonSection(),
//            buttonSectionTwo(),
//          ],
//        ),
//      ),
//    );
  }

  signIn(String phoneNumber, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var data = {
      'contact_no': phoneNumber,
      'password': pass
    };

    debugPrint(data.toString());
    try {
      var jsonResponse = null;
//    var response = await http.post("${_localhost()}/taxi/user/login", body: data);
      Response response = await dio.post ("${localhost ()}/taxi/user/login", data: data );
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
            "token", response.data['token'],
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
//      final snackBar = SnackBar(content: Text(error.response.data),
//        duration: const Duration(seconds: 5),);
//      _scaffoldKey.currentState.showSnackBar(snackBar);
      Toast.show(error.response.data, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: phoneController.text == "" || passwordController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          signIn(phoneController.text, passwordController.text);
        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container headerSection(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/2.5,
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
              size: 90,
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
              child: Text('Login',
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
  Container bodySection(){
    return Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 2,
        width: MediaQuery
            .of(context)
            .size
            .width,
        padding: EdgeInsets.only(top: 62),
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
              margin: EdgeInsets.only(top: 32),
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

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16, right: 32
                ),
                child: Text('Forgot Password ?',
                  style: TextStyle(
                      color: Colors.grey
                  ),
                ),
              ),
            ),
            Spacer(),

            RaisedGradientButton(
              child: Text(
                'Login'.toUpperCase(),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight
                    .bold),
              ),
              gradient: LinearGradient(
                colors: <Color>[Colors.green, Colors.black],
              ),
//
              onPressed: phoneController.text == "" ||
                  passwordController.text == "" ? null : () {
                setState(() {
                  _isLoading = true;
                });
                signIn(phoneController.text, passwordController.text);
              },
            ),
            SizedBox(height: 1),
            forgetPasswordSection(),

//             ),
          ],
        )
    );
  }
  Container forgetPasswordSection() {
    return Container(
//      height: 40.0,
//      padding: EdgeInsets.symmetric(horizontal: 15.0),
//      margin: EdgeInsets.only(top: 15.0),
      child: FlatButton(
        onPressed: () => Navigator.of(context).pushNamed('/signup'),
        child: Text("New User?  Sign Up",
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
//          SizedBox(height: 30.0),
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
//        ],
//      ),
//    );
//  }

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


}





/*
*  Container(
                      width: MediaQuery.of(context).size.width/1.2,
                      height: 45.0,
//                            padding: EdgeInsets.symmetric(horizontal: 15.0),
//                            margin: EdgeInsets.only(top: 15.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFf45d27),
                            Color(0xFFf5851f)
                          ]
                        ),
                          borderRadius: BorderRadius.all(
                              Radius.circular(50)
                          )
                      ),
                      child: RaisedButton(
                        onPressed: phoneController.text == "" || passwordController.text == "" ? null : () {
                          setState(() {
                            _isLoading = true;
                          });
                          signIn(phoneController.text, passwordController.text);
                        },
                        elevation: 0.0,

                        color: Colors.yellow[400],
                        child: Text("Sign In", style: TextStyle(color: Colors.black)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                      ),
                    ),

                    Spacer(),*/

//Container(
//                      height: 45,
//                      width: MediaQuery.of(context).size.width/1.2,
//                      decoration: BoxDecoration(
//                          gradient: LinearGradient(
//                            colors: [
//                              Color(0xFFf45d27),
//                              Color(0xFFf5851f)
//                            ],
//                          ),
//                          borderRadius: BorderRadius.all(
//                              Radius.circular(50)
//                          )
//                      ),
//                      child: Center(
//                        child: FlatButton(
//                          child: Text('Login'.toUpperCase(),
//                            style: TextStyle(
//                                color: Colors.white,
//                                fontWeight: FontWeight.bold
//                            ),
//                          ),
//                          onPressed: phoneController.text == "" || passwordController.text == "" ? null : () {
//                            setState(() {
//                              _isLoading = true;
//                            });
//                            signIn(phoneController.text, passwordController.text);
//                          },
//                        ),
//                      ),
//