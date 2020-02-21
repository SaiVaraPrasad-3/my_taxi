import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_taxi/utils/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseData {

  /// Make http request to the server and fetch logged in user details
  Future<List> getUserDetails () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("==================================================++++============================");
    var id = sharedPreferences.getInt("id");
    print(id);
    print(sharedPreferences.getString("token"));
    http.Response response = await http.get("${localhost()}/taxi/riders/$id");
    var jsonData = json.decode(response.body);
    List user = [];
    user.add(jsonData);
    return user;
  }

  /// Make http request to the server and fetch prices
  Future<dynamic> makeGetRequestForPrices() async {
    http.Response response = await http.get("${localhost()}/taxi/location/price");
    return json.decode(response.body);
  }


  /// Make http request to the server and fetch logged in user history of riders;
  Future<List> historyOfRides () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("==================================================++++============================");
    var id = sharedPreferences.getInt("id");
    print(id);
    print(sharedPreferences.getString("token"));
    http.Response response = await http.get("${localhost()}/taxi/rides/$id");
    var jsonData = json.decode(response.body);
    List user = [];
    user.add(jsonData);
    return user;
  }


}

