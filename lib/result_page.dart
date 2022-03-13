import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensordatenapp/sensor_and_gps.dart';
import 'package:sensordatenapp/screenSizeProperties.dart';
import 'package:http/http.dart' as http;

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;
  GoogleMapController _mapController;
  Map<String, dynamic> fetchedData = {};
  Map<String, dynamic> predictionResult = {};
  Map<int, dynamic> renamedResult = {};


  void showDrivenRoute() {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.blue.withOpacity(0.5),
      width: 12,
      points: _createPoints(),
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }


  void fetchResult() async {
    final response = await http.get(
        'https://europe-west3-sensordaten-d713c.cloudfunctions.net/lgo4qs-surface-prediction-cloud-function');
    if (response.statusCode == 200) {

      fetchedData = json.decode(response.body);
      predictionResult = fetchedData.values.toList().elementAt(0);
      print('Fetched predicted results successfully from server.');
      await renameResult();
      setState(() {});
    } else {

      throw Exception('Failed to load prediction results from server.');
    }
  }


  Future<void> renameResult() {
    predictionResult.forEach((key, value) {
      if (value == 'AS') {
        int newKey = int.parse(key) * 10;
        renamedResult.addAll({newKey: 'Asphalt'});
      } else if (value == 'KO') {
        int newKey = int.parse(key) * 10;
        renamedResult.addAll({newKey: 'Cobblestone'});
      } else if (value == 'SC') {
        int newKey = int.parse(key) * 10;
        renamedResult.addAll({newKey: 'Gravel'});
      } else if (value == 'WW') {
        int newKey = int.parse(key) * 10;
        renamedResult.addAll({newKey: 'Forest Path'});
      } else if (value == 'RW') {
        int newKey = int.parse(key) * 10;
        renamedResult.addAll({newKey: 'Bike Path'});
      }
    });
  }



  void predictData() async {
    await uploadFile(dataFile, 'sensordaten.csv');
    showDrivenRoute();
    fetchResult();
  }

  @override
  void initState() {
    predictData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Driven Route',
                style: TextStyle(fontSize: 26),
              ),
              Container(
                width: ScreenSizeProperties.safeBlockHorizontal * 90,
                height: ScreenSizeProperties.safeBlockVertical * 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 6,
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(geoData[0].position.latitude,
                          geoData[0].position.longitude),
                      zoom: 18),
                  polylines: Set<Polyline>.of(_mapPolylines.values),
                ),
              ),
              SizedBox(
                height: ScreenSizeProperties.safeBlockVertical * 2,
              ),
              Text(
                'Predicted surface',
                style: TextStyle(fontSize: 26),
              ),
              Container(
                width: ScreenSizeProperties.safeBlockHorizontal * 90,
                height: ScreenSizeProperties.safeBlockVertical * 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 6,
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: fetchedData.toString().contains('{}')
                    ? Container(
                  height: ScreenSizeProperties.safeBlockVertical * 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text(
                        'Predicting road surface.',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Please wait...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: renamedResult.length,
                    // ignore: missing_return
                    itemBuilder: (BuildContext context, int index) {
                      if (index < renamedResult.length - 1) {
                        return ListTile(
                          title: Text(
                            'From ${renamedResult.keys.toList().elementAt(index)} to ${renamedResult.keys.toList().elementAt(index + 1)} seconds:',
                          ),
                          subtitle: Text(
                            '${renamedResult.values.toList().elementAt(index)}',
                          ),
                        );
                      } else if (index < renamedResult.length) {
                        return ListTile(
                          title: Text(
                            'From ${renamedResult.keys.toList().elementAt(index)} seconds to end of recording:',
                          ),
                          subtitle: Text(
                            '${renamedResult.values.toList().elementAt(index)}',
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadFile(File file, String filename) async {
    if (dataFile != null) {
      StorageReference storageRef =
      FirebaseStorage.instance.ref().child("file_to_process/$filename");
      await storageRef.putFile(dataFile).onComplete.catchError((onError) {
        print(onError);
        return false;
      });
      print('Upload successful.');
    } else {
      print('File may be null. Upload cancelled.');
    }
  }
  void onMapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];

    for (int i = 0; i < geoData.length; i++) {
      points.add(
          LatLng(geoData[i].position.latitude, geoData[i].position.longitude));
    }
    return points;
  }

///===========================================================================
}
