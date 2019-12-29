import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_taxi/states/app_state.dart';
import 'package:provider/provider.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}): super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // to change icon of drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Map(),
      key: _scaffoldKey,
  /// add drawer here
    );
  }
}
// This class should be added to new file Maps.dart file
class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}
class _MapState extends State<Map> {
 @override
 void initState() {
   // TODO: implement initState
   super.initState();
  //  _getUserLocation();
 }


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child: appState.initialPosition == null
          ? Container(
               alignment: Alignment.center,
               child: Center(
                  child: SpinKitFadingCircle(
                   itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                      decoration: BoxDecoration(
                      color: index.isEven ? Colors.yellow : Colors.red,
                      ),
                      );
                      },
                      ),
          )
        ,
      ) : Stack(
        children: <Widget>[
          GoogleMap(initialCameraPosition:
            CameraPosition(target: appState.initialPosition,zoom: 8.0),
            onMapCreated: appState.onCreated,
            myLocationEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            markers: appState.markers,
            onCameraMove: appState.onCameraMove,
            polylines: appState.polylines,
          ),


          //Pickup location search part
          //Destination position search
          Positioned(
            bottom: 105.0,//50.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.yellow.shade100,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: TextField(
                cursorColor: Colors.blueGrey,
                //appState.
                controller: appState.locationController,
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



          Positioned(
            bottom: 50.0,//105.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.yellow.shade100,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: TextField(
                cursorColor: Colors.blueGrey,
                controller: appState.destinationController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  appState.sendRequest(value);
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
  /*
  *      [12.12  ,23.4 ,43.44   ,343.43  ,342.45   ]
  * index(0------1-----2--------3---------4        )
  * */
}
