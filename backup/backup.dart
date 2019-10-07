import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final Set<Marker> markers = {
  Marker(markerId: MarkerId('Dekernes'), position: LatLng(31.0857, 31.5888)),
  Marker(markerId: MarkerId('Mahala'), position: LatLng(30.9697, 31.1681)),
  Marker(markerId: MarkerId('Shirbin'), position: LatLng(31.1968, 31.5209))
};

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
  GoogleMapController controller;
  Geolocator geolocator;

  Future<Position> getCurrentLocation() async {
    final position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  @override
  void initState() {
    super.initState();
    geolocator = Geolocator();

    //getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Share App'),
      ),
      body: FutureBuilder<Position>(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return ModalProgressHUD(
              child: Container(),
              opacity: 1,
              inAsyncCall: true,
            );
          } else {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    zoom: 10,
                    target:
                        LatLng(snapshot.data.latitude, snapshot.data.longitude),
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      controller = controller;
                    });
                  },
                  markers: markers,
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
