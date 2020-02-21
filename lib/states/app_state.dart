import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:my_taxi/requests/google_maps_requests.dart';
import 'package:my_taxi/utils/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/credentials.dart';
import 'package:http/http.dart' as http;
import '../utils/core.dart' as utils;
import 'package:flutter_icons/flutter_icons.dart';
import 'db_data.dart';


class AppState with ChangeNotifier{

  DatabaseData dbData = DatabaseData();


  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  final Set<Marker> _markers = {};
  //the lines that draw from one point to another
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  //static const _initialPosition = LatLng(12.97, 77.58);
  MapType _currentMapType = MapType.normal;
  MapType get currentMapType => _currentMapType;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  get confirmBooking => _confirmBooking;
  get onMapTypeButtonPressed => _onMapTypeButtonPressed;
  Map googleDistanceMatrixData;

  var distance;


  List locationPrice ;
  var price;
  var timeBetweenAddresses;
  var timeValue;
  List availableCarDriverDetails;


  /// we will store the complete details of the  selected car and it's owner details in this variable with owner name and contact number
  /// it data will be driven from availableCarDriverDetails variable
  var selectedTaxiCompleteDetails;
  var carType = "";
  var driverName = "";
  var driverLastName = "";
  var taxiNumberPlate = "";
  var driverContactNumber;
  var selectedTaxiPrice;

  /*
  *real time location update on google map,
  *  the link:
  * https://medium.com/flutter-community/implement-real-time-location-updates-on-google-maps-in-flutter-235c8a09173e
  * */


  AppState(){
    _getUserLocation();
    _loadingInitialPosition();
  }



/// ! To get location auto complete
    Future<void> getLocationAutoComplete(BuildContext context) async {
    Prediction p = await PlacesAutocomplete.show(
    context: context,

    apiKey: "AIzaSyDAtArPLH5n0-F1cgXnhomLZXA7Rbes0AY",
    mode: Mode.overlay, // Mode.fullscreen
    language: "en",
    // location: ,

    components: [new Component(Component.country, "eg")]);
    destinationController.text = p.description;
    notifyListeners();
    }




/// ! TO GET THE USERS LOCATION
  void _getUserLocation() async{
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);

    print("initial position is : ${_initialPosition.toString()}");
//    print(placemark.toString());
    locationController.text = placemark[0].name;
    notifyListeners();
  }

  /// ! to Create route
  void createRoute(String encodedPoly){
   /// remove all previous routes
      _polyLines.clear();
      _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: _convertToLanLng(_decodePoly(encodedPoly)),
        color: Colors.blue,));
      notifyListeners();
  }

  /// Add a marker on the map for destination address
  void _addMarker(LatLng location, String address, context) {
    ///clear all previous markers
      _markers.clear();
      _markers.add(Marker(markerId: MarkerId(_lastPosition.toString()),
          draggable: true,
          position: location,
          infoWindow: InfoWindow(
              title: address,
              snippet: "go here"
          ),

          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: ((value) {
            print(value.latitude);
            print(value.longitude);
            sendRequest("NULL", context, value);
          })


      ));
      notifyListeners();
  }


  ///Converts the list of doubles to latlng returned from _decodePoly method
  /// Create latlng list
  List<LatLng> _convertToLanLng(List points){
    List<LatLng> result = <LatLng>[];
    for(int i = 0; i< points.length; i++){
      if(i % 2 != 0){
        result.add(LatLng(points[i-1],points[i]));
      }
    }
    return result;
  }


  // Decode poly
  //Route decode algorithm
  //Method to decode api provided by Google to get routes
  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

///*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  ///Send requests
  void sendRequest(String intendedLocation, context, LatLng markerLatLng ) async {
    double latitude;
    double longitude;

    if(intendedLocation == "NULL"){
      latitude = markerLatLng.latitude;
      longitude = markerLatLng.longitude;
    }
    else {
      List<Placemark> placemark = await Geolocator ( ).placemarkFromAddress (
          intendedLocation );
      latitude = placemark[0].position.latitude;
      longitude = placemark[0].position.longitude;
    }


    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation, context);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination);



    /// get distance between two locations
    distance = await _calculateDistance(_initialPosition, destination);

    /// get duration between initial position and destination from google distance matrix api
    timeBetweenAddresses = await _calculateTimeBetweenAddresses(_initialPosition, destination);
    timeValue = timeBetweenAddresses['rows'][0]['elements'][0]['duration']['text'];


    ///   get prices here
    locationPrice = await dbData.makeGetRequestForPrices();
    ///Local price (Goa rate) with rounding off the values
    price = (locationPrice[0]['price_per_km'] * distance).toStringAsFixed(0);
    selectedTaxiPrice = price;

    ///   get list of available cars and their drivers
    availableCarDriverDetails = await _makeGetRequestForTaxiAndDrivers();


   /* for debugging purpose

    print("======================================   { Taxi and Driver Details }  ============================================================");
    print(availableCarDriverDetails);

    print("********************************************************************");
    print(price);
    print(timeValue);

    */


    /// to select default car if customer doesn't select any car type
    /// default selected car will be first car from the list of cars available
    selectedTaxiCompleteDetails = availableCarDriverDetails[0];
    carType = selectedTaxiCompleteDetails["CarType"];
    driverName = selectedTaxiCompleteDetails["DriverName"];
    driverLastName = selectedTaxiCompleteDetails["DriverLastName"];
    taxiNumberPlate = selectedTaxiCompleteDetails["NumberPlate"];
    driverContactNumber = selectedTaxiCompleteDetails["PhoneNumber"];



    print("===================================================================");
    print("Distance inside sendRequest method $distance");
    _confirmBooking(context);


//      //Send initial and distination poisition from here to driver app (Send the rout to the driver app)
    //write route inside the map, actually add polyLines on the map
    createRoute(route);

    /// Zoom camera position to the destination address
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: destination,
          tilt: 50.0,
          bearing: 20.0,
          zoom: 16.0,
        ),
      ),
    );
//    _settingModalBottomSheet(context);
    notifyListeners();
  }

  /// ON CAMERA MOVE
  void onCameraMove(CameraPosition position) {
      // position.target is used for mobile location
      _lastPosition = position.target;
      notifyListeners();
  }

  /// ON CREATE
  void onCreated(GoogleMapController controller) {
      _mapController = controller;
      notifyListeners();
  }
  //  LOADING INITIAL POSITION

  void _loadingInitialPosition()async{
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if(_initialPosition == null){
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }

  //Change Map mode normal satellite
  void _onMapTypeButtonPressed() {
    _currentMapType = _currentMapType == MapType.normal
        ? MapType.hybrid
        : MapType.normal;
        notifyListeners();
  }


  //Calculate distance between initial position and destination
  Future<double> _calculateDistance(LatLng initialPosition, LatLng destination) async{
    double distanceInMeters = await Geolocator()
        //.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
        .distanceBetween(
          initialPosition.latitude,
           initialPosition.longitude,
            destination.latitude,
            destination.longitude
        );
      double distanceInKM =double.parse((distanceInMeters / 1000).toStringAsFixed(1));


        print("=======================================================");
        print("distance in meteres is $distanceInKM Kilometers");
//        print(price);
        print("=======================================================");
        notifyListeners();
        return distanceInKM;
  }

/// to calculate time between two addresses using google distance matrix api
   Future<dynamic> _calculateTimeBetweenAddresses (LatLng initialPosition,LatLng destination) async{

    /*for debug purpose
     print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
     print("${initialPosition.latitude},${initialPosition.longitude}");
     print("${initialPosition.latitude},${initialPosition.longitude}");
    */
    String apiUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${initialPosition.latitude},${initialPosition.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$apiKey";


     //     Response response=await dio.get(apiUrl);
     http.Response response = await http.get(apiUrl);
//     print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
//     print(response.data.toString());
      return json.decode(response.body);
   }

/*
//This method for future use 
//bottom sheet will pop up to change map modes
  void _settingModalBottomSheet(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: new Wrap(
            children: <Widget>[
              Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 10.0),
                      child: Text("MAP TYPES",
                      style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold
                      ),),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: ()=>Navigator.pop(context),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: FloatingActionButton(
                        child: Icon(Icons.map),
                        onPressed: (){
                          _currentMapType = MapType.normal;
                          Navigator.pop(context);
                          },
                    ),
                     ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        child: Icon(Icons.satellite),
                        onPressed: ()=>_currentMapType = MapType.satellite,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        child: Icon(Icons.streetview),
                        onPressed: ()=>_currentMapType = MapType.hybrid,
                      ),
                    ),
                  ],
                )
              ],)
            ],
          ),
          );
      }
    );
    notifyListeners();
}
*/

//Bottom sheet to confirm booking, select car type and use promo codes
 void _confirmBooking(BuildContext context){

   showModalBottomSheet(
       context: context,
       builder: (BuildContext bc){
           return Container(
             child: new Wrap(
             children: <Widget>[
               Column(children: <Widget>[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                    Expanded(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.directions_car),
                        ),
                        onTap: () => _displayAvailableTaxis(context),
                        //select car type
                        title: Text("Select Car Type"),
                      ),
                    ),
                     IconButton(
                       icon: Icon(Icons.more_horiz),
                       //Enter hint of place here
                       onPressed: ()=>Navigator.pop(context),
                     ),
                     IconButton(
                       icon: Icon(Icons.confirmation_number),
                       //Enter promotion code here
                       onPressed: ()=>Navigator.pop(context),
                     )
                   ],
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Column( children: <Widget>[
                       Text("Distance", style: TextStyle(color: Colors.grey),),
                       Text("$distance KM", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Time", style: TextStyle(color: Colors.grey),),
                       Text("$timeValue", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Price", style: TextStyle(color: Colors.grey),),
                       Text("$selectedTaxiPrice Rs", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                   ],
                 ),
                 Container(
                   height: 15.0,
                 ),
                 ButtonTheme(
                   minWidth: 200,
                   height: 50.0,
                   child: RaisedButton(
                     color: Colors.yellow[700],
                     onPressed: () {
                       Navigator.of(context).pop();
                       _confirmDriver(context);
                       // Navigator.pop(context);
                        },
                     child: Text("Book now", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                   ),
                 ),
                 Container(
                   height: 10.0,
                 ),
               ],
               )
             ],
           ),
           );
       }
     );
     notifyListeners();
 }

 //Bottom sheet to confirm Driver, call or
 void _confirmDriver(BuildContext context){
   showModalBottomSheet(
       context: context,
       builder: (BuildContext bc){
           return Container(
             child: new Wrap(
             children: <Widget>[
               Column(children: <Widget>[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                    Expanded(
                      child: ListTile(
                        leading: new Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(
                                        utils.profileTestImage)
                                )
                            )),
//                        title: Text("Driver name here"),
                        title: Text("$driverName $driverLastName"),
                        subtitle: Text("$carType\n$taxiNumberPlate"),
//                        subtitle: Text("Car Type here\nNumber plate"),
                        isThreeLine: true,
                      ),
                    ),
                     IconButton(
                       icon: Icon(Icons.message),
                       //chat with driver
                       onPressed: ()=>Navigator.of(context).pop(),
                     ),
                     IconButton(
                       icon: Icon(Icons.call),
                       //call the driver using inbuilt phone app
                       onPressed: ()=>_callDriver(),
                     )
                   ],
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Column( children: <Widget>[
                       Text("Distance", style: TextStyle(color: Colors.grey),),
                       Text("$distance KM", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Time", style: TextStyle(color: Colors.grey),),
                       Text("$timeValue", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Price", style: TextStyle(color: Colors.grey),),
                       Text("$selectedTaxiPrice Rs", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                   ],
                 ),
                 Container(
                   height: 15.0,
                 ),
//                 RaisedButton(
//                   color: Colors.yellow[700],
//                   child: Text("Confirm",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
//                     onPressed: (){}
//                     ),
                 ButtonTheme(
                   minWidth: 200,
                   height: 50.0,
                   child: RaisedButton(
                     color: Colors.yellow[700],
                     onPressed: () {},
                     child: Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                   ),
                 ),
                 Container(
                   height: 10.0,
                 ),
               ],
               )
             ],
           ),
           );
       }
     );
     notifyListeners();
 }

  /// Make http request to get list of available cars and their drivers
  Future<dynamic> _makeGetRequestForTaxiAndDrivers() async {
    http.Response response = await http.get("${localhost()}/taxi/details");
    return json.decode(response.body);
  }




  /// Make http request to get list of cars available;
  void _displayAvailableTaxis(BuildContext context) {
    var carPictureURL;
    selectedTaxiPrice = int.parse(price);

    showModalBottomSheet(
      backgroundColor: Colors.yellow.shade100,
      context: context,
      builder: (BuildContext bc)
    {
      return ListView.builder(
          itemCount: availableCarDriverDetails.length,
          itemBuilder: (BuildContext context, int index){
            if(availableCarDriverDetails[index]["CarType"] == "flash") {
              carPictureURL = utils.flashTypeUrl;
              selectedTaxiPrice = int.parse(price) + 50;
            }
            else if (availableCarDriverDetails[index]["CarType"] == "van"){
              carPictureURL = utils.vanTypeUrl;
              selectedTaxiPrice = int.parse(price) + 100 ;
            }
            else{

                   carPictureURL = utils.sedanTypeUrl;
                   selectedTaxiPrice = int.parse(price);
            }
            return Container(
              height: 80,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                elevation: 10,
                child: ListTile(
                  leading:
                  new Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  carPictureURL)
                          )
                      )),
                  trailing: Text("₹ ${selectedTaxiPrice.toString()}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                  title: Text(availableCarDriverDetails[index]["CarType"],
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22.0,color: Colors.black),),
                  onTap: (){
                    selectedTaxiCompleteDetails = availableCarDriverDetails[index];
                    carType = selectedTaxiCompleteDetails["CarType"];
                    driverName = selectedTaxiCompleteDetails["DriverName"];
                    driverLastName = selectedTaxiCompleteDetails["DriverLastName"];
                    taxiNumberPlate = selectedTaxiCompleteDetails["NumberPlate"];
                    driverContactNumber = selectedTaxiCompleteDetails["PhoneNumber"];
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          }
      );
    });
  }


  _callDriver() async {
    // Android
    var uri = 'tel:$driverContactNumber';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      var uri = 'tel:$driverContactNumber';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }




}


