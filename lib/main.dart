import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final clients = [];
final Set<Marker> markers = {};

void main() {
  runApp(MaterialApp(
    title: 'Location Share',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController mapController;
  Geolocator geolocator;
  Position currentLocation;

  bool mapToggle = false;
  bool clientsToggle = false;

  Future<Position> getCurrentLocation() async {
    final position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  void populateClients() async {
    var docs = await Firestore.instance.collection('clients').getDocuments();
    if (docs.documents.isNotEmpty) {
      for (int i = 0; i < docs.documents.length; i++) {
        clients.add(docs.documents[i].data);
        // add to markers set
        initMarker(docs.documents[i].data);
      }
    }
    setState(() {
      clientsToggle = true;
    });
  }

  // initilaize marker on the map
  void initMarker(Map<String, dynamic> clientData) {
    var markerId = MarkerId(
      clientData['name'],
    );
    var position = LatLng(
        clientData['location'].latitude, clientData['location'].longitude);
    markers.add(
      Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: clientData['name'],
        ),
      ),
    );
  }

  Widget clientCard(client) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.only(left: 2, top: 10),
      child: InkWell(
        onTap: () {
          zoomInMarker(client);
        },
        child: Container(
          width: 124,
          height: 100,
          child: Center(
            child: Text(client['name']),
          ),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  void zoomInMarker(client) {
    if (mapController == null) {
      print('Controller is null');
    }
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(client['location'].latitude, client['location'].longitude),
          zoom: 14,
          bearing: 90,
          tilt: 45,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    geolocator = Geolocator();

    getCurrentLocation().then((newLocation) {
      setState(() {
        currentLocation = newLocation;
        mapToggle = true;
        populateClients();
      });
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                mapToggle
                    ? GoogleMap(
                        onMapCreated: onMapCreated,
                        initialCameraPosition: CameraPosition(
                          zoom: 10,
                          target: LatLng(currentLocation.latitude,
                              currentLocation.longitude),
                        ),
                        markers: markers,
                      )
                    : Center(
                        child: Text(
                          'Loading map...',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 124,
                    width: MediaQuery.of(context).size.width,
                    child: clientsToggle
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(8),
                            children: clients.map((client) {
                              return clientCard(client);
                            }).toList(),
                          )
                        : Container(
                            height: 1,
                            width: 1,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
