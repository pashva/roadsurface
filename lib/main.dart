import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensordatenapp/result_page.dart';
import 'chart_page.dart';
import 'home_page.dart';
import 'package:flutter/services.dart' as serv;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await serv.SystemChrome.setPreferredOrientations([
    serv.DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getPermissions();
    // _signInAnonymously();
    return MaterialApp(
      title: 'Road Surface Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPge(),
      routes: {
        '/home': (context) => MyHomePage(),
        '/graph': (context) => ChartPage(),
        '/result': (context) => ResultPage(),
        '/home1': (context) => GovernmentOfficials()
      },
    );
  }

  void _getPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
    ].request();
    print('Permission for location: ${statuses[Permission.location]}');
    print('Permission for storage: ${statuses[Permission.storage]}');
  }
}

class LandingPge extends StatelessWidget {
  const LandingPge() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: FlatButton(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.pushNamed(context, "/home");
                },
                child: Text(
                  "Go to User App",
                  style: TextStyle(color: Colors.white),
                )),
          ),
          Center(
            child: FlatButton(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.pushNamed(context, "/home1");
                },
                child: Text(
                  "Go to Officials App",
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }
}

class GovernmentOfficials extends StatefulWidget {
  const GovernmentOfficials() : super();

  @override
  _GovernmentOfficialsState createState() => _GovernmentOfficialsState();
}

class _GovernmentOfficialsState extends State<GovernmentOfficials> {
  GoogleMapController mapController;
  List<Widget> data = [];
  void getData() async {
    var res = await http.get(
      "https://3228-2405-201-1f-fc7d-99e0-dfbc-aa91-189.ngrok.io/potholes_coordinates",
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      // body: jsonEncode(<String, String>{}),
    );

    var a = jsonDecode(res.body);
    print(a);
    List<Widget> children = [];
    for (int i = 0; i < a.length; i++) {
      Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
      final marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(a[i][0].toDouble(), a[i][1].toDouble()),
        // icon: BitmapDescriptor.,
        infoWindow: InfoWindow(
          title: 'Pothole $i',
          snippet: 'Reported today',
        ),
      );
      markers[MarkerId(i.toString())] = marker;
      children.add(
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: 100,
          child: Stack(children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                  target: LatLng(a[i][0].toDouble(), a[i][1].toDouble()),
                  zoom: 14),
              markers: markers.values.toSet(),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Reproted at 21:06 PM"),
                  Text("Reproted by Anuj Mishra")
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: FlatButton.icon(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {},
                  icon: Icon(Icons.done_all_rounded, color: Colors.green),
                  label: Text("Fixed", style: TextStyle(color: Colors.black))),
            )
          ]),
        ),
      );
    }

    setState(() {
      data = children;
    });
  }

  // LatLng _center = LatLng(9.669111, 80.014007);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: data),
    );
  }
}
