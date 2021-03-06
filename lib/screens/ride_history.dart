import 'package:flutter/material.dart';
import '../states/db_data.dart';

class RideHistory extends StatefulWidget {
  @override
  _RideHistoryState createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  DatabaseData dbData = DatabaseData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.shade100,
          title: Text("History of Rides"),
          centerTitle: true,
        ),
        body:
          FutureBuilder(
              future: dbData.historyOfRides(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print(snapshot.data);
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var count = snapshot.data.length;
                      var start = snapshot.data[index]
                              ['address_starting_point']
                          .toString();
                      var destination = snapshot.data[index]
                              ['address_destination']
                          .toString();
                      var price = snapshot.data[index]['price'].toString();
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.local_taxi),
                        ),
                        title: Text("From: $start"),
                        subtitle: Text("To: $destination"),
                        trailing: Text("₹ $price"),
                        onTap: () {},
                      );
                    },
                  );
                }
              }
          )
    );
  }
}
