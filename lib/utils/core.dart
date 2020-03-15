import 'package:flutter/material.dart';


const Color orange = Colors.orange;
const Color white = Colors.white;
const Color yellow = Colors.yellow;

const sedanTypeUrl = "http://192.168.43.85:7000/taxi/type/photo/sedan";
const vanTypeUrl = "http://192.168.43.85:7000/taxi/type/photo/van";
const flashTypeUrl = "http://192.168.43.85:7000/taxi/type/photo/flash";


const profileTestImage = "http://192.168.43.85:7000/taxi/profile";
const driverTestImage = "http://192.168.43.85:7000/taxi/profile/driver";


///"https://content-static.upwork.com/uploads/2014/10/02123010/profilephoto_goodcrop.jpg";
/// ip version4 we use to be able to access through physical mobile device
/// https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRu5trhUbXDbD2aQdTKFUERRxeYQH-98QIX59tug8132E-gz6Oo
String localhost () => 'http://192.168.43.85:7000';

// While working with local host we use the following code snippet
//String localhost() {
//  if (Platform.isAndroid)
//    return 'http://10.0.2.2:7000';
//  else // for iOS simulator
//    return 'http://localhost:7000';
//}