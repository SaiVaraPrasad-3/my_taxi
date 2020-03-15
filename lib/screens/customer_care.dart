import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCare extends StatelessWidget {

  openMyTaxiFacebook() async {
    final url="http://www.facebook.com/mytaxi";
    if (await canLaunch(url)){
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  openMyTaxiInstagram() async {
    final url="http://www.instagram.com/mytaxi";
    if (await canLaunch(url)){
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  openHaztechHomePage() async {
    final url="http://www.haztech.in";
    if (await canLaunch(url)){
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade100,
          title: Text("Contact us"),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                child: Image.network(
                    "https://facebookbrand.com/wp-content/uploads/2019/04/f_logo_RGB-Hex-Blue_512.png?w=512&h=512"
                ),
              ),
              title: Text("Facebook Page"),
              subtitle: Text("http://www.facebook.com/mytaxi"),
              onTap: openMyTaxiFacebook,
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(
                child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT4aICHwULanuNjg4DHIfeLkkpngCjTsV-SFNMAUqlOjBJrKcFv"
                ),
              ),
              title: Text("Instagram Page"),
              subtitle: Text("http://www.instagram.com/mytaxi"),
              onTap: openMyTaxiInstagram,
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.network("http://www.haztech.in/img/logo-dark.png"),
              ),
              title: Text("Haztech Website"),
              subtitle: Text("http://www.haztech.in"),
              onTap: openHaztechHomePage,
            ),
            Divider(),
          ],
        )
    );
  }
}
