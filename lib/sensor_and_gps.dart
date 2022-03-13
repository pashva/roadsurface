import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'csv.dart';

String csvPath;
File dataFile;
List<MeasuredDataObject> geoData = [];
bool shouldTrack = false;
Csv csv = Csv();

class SensorData {
  List<MeasuredDataObject> accData = [];
  List<MeasuredDataObject> linearData = [];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  Stopwatch watch = Stopwatch();
  Stopwatch watch1 = Stopwatch();

  ///=====Starting the accelerometer recording==================================
  startDataStream() async {
    shouldTrack = true;
    accData = [];

    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_FASTEST,
    );
    final stream1 = await SensorManager().sensorUpdates(
      sensorId: Sensors.LINEAR_ACCELERATION,
      interval: Sensors.SENSOR_DELAY_FASTEST,
    );
    _streamSubscriptions.add(stream.listen((sensorEvent) {
      watch.start();
      MeasuredDataObject measuredData = MeasuredDataObject(
        time: watch.elapsedMilliseconds * 0.001,
        x: sensorEvent.data[0],
        y: sensorEvent.data[1],
        z: sensorEvent.data[2],
      );

      accData.add(measuredData);
    }));
    _streamSubscriptions.add(stream1.listen((sensorEvent) {
      watch1.start();
      MeasuredDataObject measuredData1 = MeasuredDataObject(
        time: watch1.elapsedMilliseconds * 0.001,
        x: sensorEvent.data[0],
        y: sensorEvent.data[1],
        z: sensorEvent.data[2],
      );

      linearData.add(measuredData1);
    }));
  }

  ///===========================================================================

  ///===========Stopping the accelerometer recording============================
  Future<List<MeasuredDataObject>> stopDataStream() async {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
      watch.stop();
      shouldTrack = false;
      print('Amount of Geopoints ${geoData.length}');
      print(' Amount of accelerometer Points ${accData.length}');
    }
    await csv.createCSV(accData, 0);
    await csv.createCSV(linearData, 1);
    _streamSubscriptions.clear();
    return accData;
  }

  ///===========================================================================

  ///===========Recording the GPS coordinates of the device=====================
  int i = 0;
  trackPosition() async {
    geoData = [];
    while (shouldTrack == true) {
      MeasuredDataObject measuredData = MeasuredDataObject(
        position: await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
        time: watch.elapsed.inSeconds.toDouble(),
      );

      if (i == 0) {
        var x = await Geolocator().placemarkFromCoordinates(
            measuredData.position.latitude, measuredData.position.longitude);
        print(x[0].thoroughfare);
        print(x[0].locality);
        print(x[0].subLocality);
        print(x[0].postalCode);
        // print(x[0].name);
        print(measuredData.position.latitude);
        print(measuredData.position.longitude);
      }
      i++;
      geoData.add(measuredData);
    }
  }

  ///===========================================================================
}

class MeasuredDataObject {
  double time, x, y, z;
  Position position;

  MeasuredDataObject({this.time, this.x, this.y, this.z, this.position});
}
