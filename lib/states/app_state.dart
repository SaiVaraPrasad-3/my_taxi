import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_taxi/requests/google_maps_requests.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/credentials.dart';
import 'package:http/http.dart' as http;
import '../utils/core.dart' as utils;
import 'package:flutter_icons/flutter_icons.dart';

class AppState with ChangeNotifier{


  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  final Set<Marker> _markers = {};
  //the lines that draw from on point to another
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



  AppState(){
    _getUserLocation();
    _loadingInitialPosition();
  }



/// ! TO GET THE USERS LOCATION

  void _getUserLocation() async{
    List<Placemark> placemark;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    try{
      placemark = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
    } catch(e){ debugPrint("getUserLocation Method exception");}
    ///getting placemark without exception
//    List<Placemark> placemark = await Geolocator()
//        .placemarkFromCoordinates(position.latitude, position.longitude);
    _initialPosition = LatLng(position.latitude, position.longitude);
    print("initial position is : ${_initialPosition.toString()}");
    locationController.text = placemark[0].name;
    notifyListeners();
  }

  /// ! to Create route
  void createRoute(String encodedPoly){
      _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: _convertToLanLng(_decodePoly(encodedPoly)),
        color: Colors.blue,));
      notifyListeners();
  }

  /// Add a marker on the map for destination address
  void _addMarker(LatLng location, String address) {
      _markers.add(Marker(markerId: MarkerId(_lastPosition.toString()),
          position: location,
          infoWindow: InfoWindow(
              title: address,
              snippet: "go here"
          ),
          icon: BitmapDescriptor.defaultMarker
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
  void sendRequest(String intendedLocation, context) async{
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination);



    /// get distance between two locations
    distance = await _calculateDistance(_initialPosition, destination);

    /// get duration between initial position and destination from google distance matrix api
    timeBetweenAddresses = await _calculateTimeBetweenAddresses(_initialPosition, destination);
    timeValue = timeBetweenAddresses['rows'][0]['elements'][0]['duration']['text'];


    ///   get prices here
    locationPrice = await _makeGetRequestForPrices();
    ///Local price (Goa rate) with rounding off the values
    price = (locationPrice[0]['price_per_km'] * distance).toStringAsFixed(0);


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
                       Text("$price Rs", style: TextStyle(fontWeight: FontWeight.bold),)
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
                        leading: CircleAvatar(
                          ///url in this image should be taken from the database
                          ///for now we are using simple image
                          child: Image.network(utils.profileTestImage),
                        ),
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
                       Text("$price Rs", style: TextStyle(fontWeight: FontWeight.bold),)
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
    http.Response response = await http.get("${_localhost()}/taxi/details");
    return json.decode(response.body);
  }


 /// Make http request to the server and fetch prices
  Future<dynamic> _makeGetRequestForPrices() async {
    http.Response response = await http.get("${_localhost()}/taxi/location/price");
    return json.decode(response.body);
  }

  /// Make http request to get list of cars available;

  String _localhost() {
    if (Platform.isAndroid)
      return 'http://10.0.2.2:7000';
    else // for iOS simulator
      return 'http://localhost:7000';
  }




  void _displayAvailableTaxis(BuildContext context) {
    var carURL;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc)
    {
      return ListView.builder(
          itemCount: availableCarDriverDetails.length,
          itemBuilder: (BuildContext context, int index){
            if(availableCarDriverDetails[index]["CarType"] == "flash_taxi")
              carURL = utils.flashTypeUrl;
            else if (availableCarDriverDetails[index]["CarType"] == "van")
              carURL = utils.vanTypeUrl;
            else
              carURL = utils.sedanTypeUrl;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.blueGrey,
              elevation: 10,
              child: ListTile(
                leading: CircleAvatar(
                  child: Image.network(carURL),
                ),
                trailing: Text(availableCarDriverDetails[index]["CarType"]),
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


