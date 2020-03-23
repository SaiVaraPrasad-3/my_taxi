import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:my_taxi/database_interaction/send_ride_request.dart';
import 'package:my_taxi/requests/google_maps_requests.dart';
import 'package:my_taxi/screens/confirm_booking_screen.dart';
import 'package:my_taxi/utils/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/credentials.dart';
import 'package:http/http.dart' as http;
import '../utils/core.dart' as utils;
import 'db_data.dart';
import '../maps/maps.dart';


class AppState with ChangeNotifier{

  DatabaseData _dbData = DatabaseData();
  RideRequest _rideRequest = RideRequest();

  static LatLng _initialPosition;
  static LatLng _destination;
  LatLng _lastPosition = _initialPosition;
  bool locationServiceActive = true;
  final Set<Marker> _markers = {};
  ///the lines that draw from one point to another
  final Set<Polyline> _polyLines = {};
  GoogleMapController _mapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  ///static const _initialPosition = LatLng(12.97, 77.58);
  MapType _currentMapType = MapType.normal;
  MapType get currentMapType => _currentMapType;
  LatLng get initialPosition => _initialPosition;
  LatLng get lastPosition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
//  get confirmBooking => _confirmBooking;
  get onMapTypeButtonPressed => _onMapTypeButtonPressed;
  get getUserLocation => _getUserLocation;
  MapClass googleDistanceMatrixData;
  get destination => _destination;
//  get chooseMapType => _chooseMapType;

  var _distance;
  List _locationPrice ;
  var _price;
  var _timeBetweenAddresses;
  var _timeValue;
  List _availableCarDriverDetails;

  /// to check if rider still in ride or finished
  bool _pendingRide = false;


  /// we will store the complete details of the  selected car and it's owner details in this variable with owner name and contact number
  /// it data will be driven from availableCarDriverDetails variable
  var _selectedTaxiCompleteDetails;
  var _carType = "";
  var _driverName = "";
  var _driverLastName = "";
  var _taxiNumberPlate = "";
  var _driverContactNumber;
  var _selectedTaxiPrice;

  var globalContext;

  /*
  *real time location update on google map,
  *  the link:
  * https://medium.com/flutter-community/implement-real-time-location-updates-on-google-maps-in-flutter-235c8a09173e
  * */

  AppState(){
    ///he in loading of app we just pass empty values
    /// because in loading stage the the parameters of _getUserLocation won't be needed
    ///
    /// context is need for this method call
    _getUserLocation("From AppState()");
    _loadingInitialPosition();
  }



/// ! To get location auto complete
    Future<void> getPickUpLocationAutoComplete () async {
      Prediction p = await PlacesAutocomplete.show(context: globalContext, apiKey: apiKey,
          language: "en", components: [
            Component(Component.country, "in")
          ]
      );
      if(p == null) return;
      locationController.text = p.description;
     notifyListeners();
    }

  /// ! To get location auto complete
  Future<void> getDestinationLocationAutoComplete () async {
    Prediction p = await PlacesAutocomplete.show(context: globalContext, apiKey: apiKey,
        language: "en", components: [
          Component(Component.country, "in")
        ]
    );
    if(p == null) return;
    destinationController.text = p.description;
    notifyListeners();
  }




/// ! TO GET THE USERS LOCATION
  void _getUserLocation(String pickupLocationSearched) async{
    List<Placemark> placemark;
    String error;
    /// From AppState means to decide the behavior of the getUserLocation method based on user current location or searched pickup location
    if(pickupLocationSearched != "From AppState()"){
      try {
        List<Placemark> placemark = await Geolocator ( ).placemarkFromAddress ( pickupLocationSearched );
        double latitude = placemark[0].position.latitude;
        double longitude = placemark[0].position.longitude;
        _initialPosition = LatLng(latitude, longitude);
        _addPickupMarker(_initialPosition, pickupLocationSearched);
        /// if the user has not searched destination the we won't send request if destination is searched then request will be sent
        /// user will have to search for destination else if already searched then
        /// based on new initial position and previous searched destination we send request
        if(_destination != null)
          /// 0.0 LatLng because when we call sendRequest method from here then LatLng won't we needed only we change initial value
          /// and send request to the already searched destination
         sendRequest("From _getUserLocation", _initialPosition,LatLng(0.0,0.0));
        error = null;
        notifyListeners();
      }
      on Exception catch (e) {
        if(e.toString() == 'PERMISSION_DENIED') {
          error = 'Permission denied';
        } else if (e.toString() == 'PERMISSION_DENIED_NEVER_ASK') {
          error = 'Permission denied - please ask user to enable it from the app settings';
        }
        print(error);
      }


    }
    else {
      Position position = await Geolocator ( )
          .getCurrentPosition ( desiredAccuracy: LocationAccuracy.best );

      placemark = await Geolocator ( )
          .placemarkFromCoordinates ( position.latitude, position.longitude );
      _initialPosition = LatLng ( position.latitude, position.longitude );
      _addPickupMarker(_initialPosition, locationController.text.toString());
      locationController.text = placemark[0].name;
      notifyListeners();
    }
    print("initial position is : ${_initialPosition.toString()}");
//    print(placemark.toString());
  }

  /// ! to Create route
  void createRoute(String encodedPoly){
   /// remove all previous routes
      _polyLines.clear();
      _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 8,
        points: _convertToLanLng(_decodePoly(encodedPoly)),
        color: currentMapType == MapType.normal ? Colors.blueGrey : Colors.blueAccent,));
      notifyListeners();
  }



  /// Add a marker on the map for pick up address
  void _addPickupMarker(LatLng location, String address) {
    ///clear all previous markers
    _markers.remove(MarkerId("Pick Up"));
    _markers.add(Marker(markerId: MarkerId("Pick Up"),
        draggable: true,
        position: location,
        infoWindow: InfoWindow(
            title: "Starting Address",
            snippet: "Pick Up"
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//          icon: BitmapDescriptor.fromAsset('images/test2.png',),
        ///          to change opacity of the marker
        alpha: .9,
        onDragEnd: ((value) {
          /// if user drags marker without searching destination the on drag we only update the pickup location
          _initialPosition = value;
          /// if user already searched the destination position the we request new route on pickup marker dragged
          if(_destination != null){
            sendRequest("From Pickup Marker", _initialPosition, _destination);
          }

        })
    ));
    notifyListeners();
  }


  /// Add a marker on the map for destination address
  void _addMarker(LatLng location, String address) {
    ///clear all previous markers
      _markers.remove(MarkerId("Destination"));
      _markers.add(Marker(markerId: MarkerId("Destination"),
          draggable: true,
          position: location,
          infoWindow: InfoWindow(
              title: "Destination",
              snippet: "go here"
          ),

          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
//          icon: BitmapDescriptor.fromAsset('images/test2.png',),
///          to change opacity of the marker
          alpha: .9,
          onDragEnd: ((value) {
            sendRequest("FROM _addMarker", _initialPosition,value);
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

//    print(lList.toString());

    return lList;
  }

  ///Send requests
  void sendRequest(String intendedLocation, LatLng pickUpMarkerLatLng, LatLng destinationMarkerLatLng ) async {
    /// create a global context so passing context wont be needed in between methods
    print("testing gloabl context;_________________________");
    print(globalContext);

    double latitude;
    double longitude;

    /// if sendRequest method is called from addMarker method means if destination marker is dragged to new position
    if(intendedLocation == "FROM _addMarker"){
      latitude = destinationMarkerLatLng.latitude;
      longitude = destinationMarkerLatLng.longitude;
      List<Placemark> placemark = await Geolocator ( )
          .placemarkFromCoordinates ( latitude, longitude );
      destinationController.text = placemark[0].name;
      notifyListeners();
    }
    else if( intendedLocation == "From Pickup Marker"){
      _initialPosition = pickUpMarkerLatLng;
      latitude = _destination.latitude;
      longitude = _destination.longitude;
    }
    /// if sendRequest is called from getUser location => means user searches pickup location
    ///  and already searched destination
    else if (intendedLocation == "From _getUserLocation"){
      /// because destination is alread searched by user so we have destination value
      latitude = _destination.latitude;
      longitude = _destination.longitude;
    }
    else {
      try{

        List<Placemark> placemark = await Geolocator().placemarkFromAddress ( intendedLocation );
        latitude = placemark[0].position.latitude;
        longitude = placemark[0].position.longitude;
      } on Exception catch (e) {
        /// if(e != null) sendRequest(intendedLocation, context, pickUpMarkerLatLng, destinationMarkerLatLng);
        print("Error caught");
        print(e);
      }


    }


    _destination = LatLng(latitude, longitude);
    _addMarker(_destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, _destination);



    /// get distance between two locations
    _distance = await _calculateDistance(_initialPosition, _destination);

    /// get duration between initial position and destination from google distance matrix api
    _timeBetweenAddresses = await _calculateTimeBetweenAddresses(_initialPosition, _destination);
    _timeValue = _timeBetweenAddresses['rows'][0]['elements'][0]['duration']['text'];


    ///   get prices here
    _locationPrice = await _dbData.makeGetRequestForPrices();
    ///Local price (Goa rate) with rounding off the values
    _price = (_locationPrice[0]['price_per_km'] * _distance).toStringAsFixed(0);
    _selectedTaxiPrice = _price;

    ///   get list of available cars and their drivers
    _availableCarDriverDetails = await _dbData.makeGetRequestForTaxiAndDrivers();


   /* for debugging purpose

    print("======================================   { Taxi and Driver Details }  ============================================================");
    print(availableCarDriverDetails);

    print("********************************************************************");
    print(price);
    print(timeValue);

    */


    /// to select default car if customer doesn't select any car type
    /// default selected car will be first car from the list of cars available
    _selectedTaxiCompleteDetails = _availableCarDriverDetails[0];
    _carType = _selectedTaxiCompleteDetails["CarType"];
    _driverName = _selectedTaxiCompleteDetails["DriverName"];
    _driverLastName = _selectedTaxiCompleteDetails["DriverLastName"];
    _taxiNumberPlate = _selectedTaxiCompleteDetails["NumberPlate"];
    _driverContactNumber = _selectedTaxiCompleteDetails["PhoneNumber"];



    print("===================================================================");
    print(globalContext);
    print("Distance inside sendRequest method $_distance");
    _confirmBooking();

   ////Send initial and destination position from here to driver app (Send the rout to the driver app)
   ///write route inside the map, actually add polyLines on the map
    createRoute(route);

    /// Zoom camera position to the destination address
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _destination,
          tilt: 40.0,
          bearing: 20.0,
          zoom: 13.0,
        ),
      ),
    );

//    _settingModalBottomSheet();
    _pendingRide = false;
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
    await Future.delayed(Duration(seconds: 7)).then((v) {
      if(_initialPosition == null){
        locationServiceActive = false;
        notifyListeners();
      }
    });
  }

  ///Change Map mode normal & satellite
  void _onMapTypeButtonPressed() {
    _currentMapType = _currentMapType == MapType.normal
        ? MapType.hybrid
        : MapType.normal;
        notifyListeners();
  }


  ///Calculate distance between initial position and destination
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
/*
  void _chooseMapType () async {
    showModalBottomSheet(
      context: globalContext,
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
                      onPressed: (){
                        _currentMapType  = MapType.satellite;
                        Navigator.of(globalContext).pop();
                      },
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
                          Navigator.pop(globalContext);
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
 void _confirmBooking()
 {
   showBottomSheet(
//     backgroundColor: Colors.grey,
       context: globalContext,
       builder: (BuildContext bc){
           return Container(
             child: Wrap(
             children: <Widget>[
               Column(children: <Widget>[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: <Widget>[
                    Expanded(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.directions_car),
                        ),
                        onTap: () => _displayAvailableTaxis(),
                        //select car type
                        title: Text("Select Car Type"),
                      ),
                    ),
                     IconButton(
                       icon: Icon(Icons.more_horiz),
                       //Enter hint of place here
                       onPressed: ()=>Navigator.pop(globalContext),
                     ),
                     IconButton(
                       icon: Icon(Icons.confirmation_number),
                       //Enter promotion code here
                       onPressed: ()=>Navigator.pop(globalContext),
                     )
                   ],
                 ),
                 Divider(thickness: 2,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Column( children: <Widget>[
                       Text("Distance", style: TextStyle(color: Colors.grey),),
                       Text("$_distance KM", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Time", style: TextStyle(color: Colors.grey),),
                       Text("$_timeValue", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Price", style: TextStyle(color: Colors.grey),),
                       Text("$_selectedTaxiPrice Rs", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                   ],
                 ),
                 Divider(thickness: 2,),
                 Container(
                   height: 15.0,
                 ),
                 ButtonTheme(
                   minWidth: 200,
                   height: 50.0,
                   child: RaisedButton(
                     color: Colors.yellow[700],
                     onPressed: () {
                       Navigator.of(globalContext).pop();
                       _confirmDriver();
                       // Navigator.pop(globalContext);
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
 void _confirmDriver(){
   showBottomSheet(
//     backgroundColor: Colors.yellow.shade50,
       context: globalContext,
       builder: (BuildContext bc){
           return Container(
             child: new Wrap(
             children: <Widget>[
               Column(children: <Widget>[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[

                               Container(
                            margin: EdgeInsets.all(10.0),
                              width: 70.0,
                              height: 70.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                          utils.driverTestImage)
                                  )
                              )),

//                        title: Text("Driver name here"),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("$_driverName $_driverLastName", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19.0),),
                              Text("$_carType", style: TextStyle(fontSize: 17.0),),
                              Text("$_taxiNumberPlate")
                              //                        subtitle: Text("Car Type here\nNumber plate"),
                              // isThreeLine: true,
                            ],
                          ),
                           IconButton(
                             icon: Icon(Icons.message),
                             //chat with driver
                             onPressed: ()=>Navigator.of(globalContext).pop(),
                           ),
                           IconButton(
                             icon: Icon(Icons.call),
                             //call the driver using inbuilt phone app
                             onPressed: ()=>_callDriver(),
                   )
             ]
                        ),
                      ),
                    ),

                   ],
                 ),
                 Divider(thickness: 2,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Column( children: <Widget>[
                       Text("Distance", style: TextStyle(color: Colors.grey),),
                       Text("$_distance KM", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(thickness: 2,),
                     Column( children: <Widget>[
                       Text("Time", style: TextStyle(color: Colors.grey),),
                       Text("$_timeValue", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                     VerticalDivider(),
                     Column( children: <Widget>[
                       Text("Price", style: TextStyle(color: Colors.grey),),
                       Text("$_selectedTaxiPrice Rs", style: TextStyle(fontWeight: FontWeight.bold),)
                     ]
                     ),
                   ],
                 ),
                 Divider(thickness: 2,),
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
                   child: _pendingRide == true ? CircularProgressIndicator() : RaisedButton(
                     color: Colors.yellow[700],
                     onPressed: () {
                       /// send ride request to Driver app
                       _pendingRide = true;
                       notifyListeners();
                       print(_pendingRide);
                       _rideRequest.sendRideRequest(_initialPosition.latitude, _initialPosition.longitude, _destination.latitude, _destination.longitude);
                     },
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

  /// Make http request to get list of cars available
  void _displayAvailableTaxis() {
    var carPictureURL;
    _selectedTaxiPrice = int.parse(_price);

    showModalBottomSheet(
      backgroundColor: Colors.yellow.shade50,
      context: globalContext,
      builder: (BuildContext bc)
    {
      return ListView.builder(
          itemCount: _availableCarDriverDetails.length,
          itemBuilder: (BuildContext context, int index){
            if(_availableCarDriverDetails[index]["CarType"] == "flash") {
              carPictureURL = utils.flashTypeUrl;
              _selectedTaxiPrice = int.parse(_price) + 50;
            }
            else if (_availableCarDriverDetails[index]["CarType"] == "van"){
              carPictureURL = utils.vanTypeUrl;
              _selectedTaxiPrice = int.parse(_price) + 100 ;
            }
            else{

                   carPictureURL = utils.sedanTypeUrl;
                   _selectedTaxiPrice = int.parse(_price);
            }
            return
                Container(
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
                      trailing: Text("₹ ${_selectedTaxiPrice.toString()}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                      title: Text(_availableCarDriverDetails[index]["CarType"],
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22.0,color: Colors.black),),
                      onTap: (){
                        _selectedTaxiCompleteDetails = _availableCarDriverDetails[index];
                        _carType = _selectedTaxiCompleteDetails["CarType"];
                        _driverName = _selectedTaxiCompleteDetails["DriverName"];
                        _driverLastName = _selectedTaxiCompleteDetails["DriverLastName"];
                        _taxiNumberPlate = _selectedTaxiCompleteDetails["NumberPlate"];
                        _driverContactNumber = _selectedTaxiCompleteDetails["PhoneNumber"];
                        Navigator.of(globalContext).pop();
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
    var uri = 'tel:$_driverContactNumber';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      var uri = 'tel:$_driverContactNumber';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }


}




