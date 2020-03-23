// This class should be added to new file Maps.dart file
import 'package:flutter/cupertino.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:my_taxi/screens/confirm_booking_screen.dart';
import 'package:my_taxi/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_taxi/utils/credentials.dart';
import 'package:provider/provider.dart';

class MapClass extends StatefulWidget {

  @override
  _MapClassState createState() => _MapClassState();
}

class _MapClassState extends State<MapClass> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.globalContext = context;
    const test = LatLng(12.97, 77.58);
    return SafeArea(
      child: appState.initialPosition == null ? Container
        (
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpinKitFadingCircle (
                    itemBuilder: ( BuildContext context, int index ) {
                      return DecoratedBox (
                        decoration: BoxDecoration (
                          color: index.isEven ? Colors.yellow: Colors.red,
                          //                      color: Colors.yellow
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox ( height: 10, ),
              Visibility (
                visible: appState.locationServiceActive == false,
                child: Text ( "Please enable device location services!",
                  style: TextStyle ( color: Colors.grey, fontSize: 18 ), ),
              )
            ],
          ),
         ): Stack (
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.height,
            child: GoogleMap(initialCameraPosition:
              CameraPosition(target: appState.initialPosition,zoom: 18.0),
                onMapCreated: appState.onCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: true,
                mapType: appState.currentMapType,
                compassEnabled: true,
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.polyLines,
            ),
          ),

          ///this button will change modes of map
          Positioned(
            right: 15.0,
            top: 180.0,
            child: Container(
              height: 55,
              width: 55,
              child:
                FloatingActionButton(
                    child: Icon(Icons.map),
                    // TODO: use this button for testing card creation
                    onPressed: appState.onMapTypeButtonPressed,
                    backgroundColor:
                    appState.currentMapType == MapType.normal ? Colors.green[100] : Colors.white
                ),
            ),
          ),
          ///Pickup location search part
          Positioned(
            top: 60.0,//50.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 45.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 5.0),
                      blurRadius: 20,
                      spreadRadius: 3)
                ],
              ),
              child: TextField(
                onTap: appState.getPickUpLocationAutoComplete,
                cursorColor: Colors.blueGrey,
                //appState.
                controller: appState.locationController,
                ///! IMPORTANT
                ///WE use this function to get searchable initial location
                onSubmitted: (value) async{
                  /// we pass the searched values test will just have some value it won't be used we pass now just because
                  appState.getUserLocation(value);
                },
                decoration: InputDecoration(
                  icon: Container(
                    margin: EdgeInsets.only(left: 20, top: 5),
                    width: 10,
                    height: 10,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red.shade900,
                    ),
                  ),
                  hintText: "pick up",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                ),
              ),
            ),
          ),
          ///Destination position search
          Positioned(
            top: 110.0,//105.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 45.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: TextField(
//                onTap: () => appState.getLocationAutoComplete(context),
                //places autocomplete
               onTap: appState.getDestinationLocationAutoComplete,
               cursorColor: Colors.blueGrey,
                controller: appState.destinationController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) async{
                  appState.sendRequest(value, test,test);
//                  appState.confirmBooking(context);
                },
                decoration: InputDecoration(
                  icon: Container(
                    margin: EdgeInsets.only(left: 20, top: 5),
                    width: 10,
                    height: 10,
                    child: Icon(
                      Icons.local_taxi,
                      color: Colors.red.shade900,
                    ),
                  ),
                  hintText: "destination?",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                ),
              ),
            ),
          ),
          //add markers part
          // We use positioned to add markers on the map
//        Positioned(
//          top: 40,
//          right: 40,
//          child: FloatingActionButton(onPressed: _onAddMarkerPressed,
//          tooltip: "Add marker",
//            backgroundColor: oranage,
//            child: Icon(Icons.add_location, color: white,),
//          ),
//        ),
        ],
      ),
    );
  }
}
