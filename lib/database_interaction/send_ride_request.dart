import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_taxi/utils/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../screens/home.dart';


class RideRequest {
  Dio dio = new Dio();

  sendRideRequest(initLat, initLong, destLat, destLong) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var id = sharedPreferences.getInt("id");
    var data =
    {
      "init_lat": initLat,
      "init_long": initLong,
      "dest_lat": destLat,
      "dest_long": destLong,
      "rider_id": id,
      "pending": "1"
    };
    debugPrint(data.toString());
    try {
      Response response = await dio.post ("${localhost ()}/taxi/pendingrequests/update", data: data );

      if (response.statusCode == 200){
        print("============================");
        print(response.data);
      }
    }on DioError catch(error) {
      print(error);
    }
  }
}