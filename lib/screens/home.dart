import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:my_taxi/authentication/login.dart';
import 'package:my_taxi/states/app_state.dart';
import 'package:my_taxi/states/db_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/credentials.dart';
import './drawer/drawer.dart';
import 'package:flutter_icons/flutter_icons.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}): super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DatabaseData dbData  = DatabaseData();

  /// to check if the use is logged in
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();

  }
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }



  /// to change icon of drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Map(),
      key: _scaffoldKey,
     
  /// add drawer here
      floatingActionButton: Stack(
        children: <Widget>[
         Positioned(
           top: 65,
           left: 30,
           child: Container(
             height: 45.0,
             width: 45.0,
             child: FittedBox(
               child:
               ClipOval(
                 child: Material(
                   color: Colors.grey[300], // button color
                   child: InkWell(
                     splashColor: Colors.yellow.shade100, // inkwell color
                     child: SizedBox(width: 56, height: 56, child: Icon(Icons.menu)),
                     onTap: ()=>_scaffoldKey.currentState.openDrawer(),
                   ),
                 ),
               )
//               RaisedButton(
//
//                 child: Icon(Icons.menu),
////                 backgroundColor: Colors.grey[200],
//                 onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
//                 ),
             ),
           )
          ),
      ], 
      ),
      drawer: DrawerBuilder(),
    );
  }
}



// This class should be added to new file Maps.dart file
class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return SafeArea(
      child: appState.initialPosition == null
          ? Container(
        //        alignment: Alignment.center,
        //        child: Center(
        //           child: SpinKitFadingCircle(
        //            itemBuilder: (BuildContext context, int index) {
        //               return DecoratedBox(
        //               decoration: BoxDecoration(
        //               color: index.isEven ? Colors.yellow : Colors.red,
        //               ),
        //               );
        //               },
        //               ),
        //   )
        // ,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitFadingCircle(
                   itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                      decoration: BoxDecoration(
                      color: index.isEven ? Colors.yellow : Colors.red,
//                      color: Colors.yellow
                      ),
                      );
                      },
                      ),
              ],
            ),
            SizedBox(height: 10,),
                  Visibility(
                    visible: appState.locationServiceActive == false,
                    child: Text("Please enable device location services!",
                    style: TextStyle(color: Colors.grey, fontSize: 18),),
                  )]
          ,),
      ) : Stack(
        children: <Widget>[
          GoogleMap(initialCameraPosition:
            CameraPosition(target: appState.initialPosition,zoom: 18.0),
            onMapCreated: appState.onCreated,
            myLocationEnabled: true,
            mapType: appState.currentMapType,
            compassEnabled: true,
            markers: appState.markers,
            onCameraMove: appState.onCameraMove,
            polylines: appState.polyLines,
          ),

      
          //this button will change modes of map
          Positioned(
            right: 10.0,
            bottom: 170.0,
              child: Container(
                height: 55,
                width: 55,
                child:
//                ClipOval(
//                  child: Material(
//                    color: appState.currentMapType == MapType.normal ? Colors.green[100] : Colors.white, // button color
//                    child: InkWell(
//                      splashColor: Colors.yellow.shade100, // inkwell color
//                      child: SizedBox(width: 66, height: 66, child: Icon(Icons.map)),
//                      onTap: appState.onMapTypeButtonPressed,
//                    ),
//                  ),
//                )
                FloatingActionButton(
                  child: Icon(Icons.map),
                  onPressed: appState.onMapTypeButtonPressed,
                  backgroundColor:
                   appState.currentMapType == MapType.normal ? Colors.green[100] : Colors.white
                ),


              ),
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
//                onTap: () => appState.getLocationAutoComplete(context),
    //places autocomplete
//                onTap: () async{
//                  Prediction p = await PlacesAutocomplete.show(context: context, apiKey: apiKey,
//                  language: "en", components: [
//                    Component(Component.country, "in")
//                      ]
//                  );
//                  if(p != null) return;
//                  setState(() {
//                    appState.destinationController.text = p.description;
//
//                  });
//                },
                 
                cursorColor: Colors.blueGrey,
                controller: appState.destinationController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) async{
                  const test = LatLng(12.97, 77.58);
                  appState.sendRequest(value, context, test);
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
  /*
  *      [12.12  ,23.4 ,43.44   ,343.43  ,342.45   ]
  * index(0------1-----2--------3---------4        )
  * */

}
