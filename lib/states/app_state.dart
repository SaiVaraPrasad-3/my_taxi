import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_taxi/requests/google_maps_requests.dart';


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
  LatLng get initialPosition => _initialPosition;
  LatLng get lastposition => _lastPosition;
  GoogleMapsServices get googleMapsServices => _googleMapsServices;
  GoogleMapController get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polyLines;


  AppState(){
    _getUserLocation();
  }
/// ! TO GET THE USERS LOCATION

  void _getUserLocation() async{
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
      _initialPosition = LatLng(position.latitude, position.latitude);
      print("initial position is : ${_initialPosition.toString()}");
      locationController.text = placemark[0].name;
      notifyListeners();
  }

  ///! to Create route
  void createRoute(String encodedPoly){
      _polyLines.add(Polyline(polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: _convertToLanLng(_decodePoly(encodedPoly)),
        color: Colors.blue,));
      notifyListeners();
  }

  /// Add a marker on the map
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
      /* if value is negetive then bitwise not the value */
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
  void sendRequest(String intendedLocation) async{
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(_initialPosition, destination);
    //write route inside the map, actually add polylines on the map
    createRoute(route);
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

}