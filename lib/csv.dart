import 'package:csv/csv.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensordatenapp/sensor_and_gps.dart';
import 'dart:io';

class Csv {
  createCSV(List<MeasuredDataObject> accData, int q) async {
    List<List<dynamic>> rows = List<List<dynamic>>();

    for (int i = 0; i < accData.length; i++) {
      List<dynamic> row = List();
      if (i == 0) {
        row.add('time');
        row.add('x');
        row.add('y');
        row.add('z');
        rows.add(row);
      } else {
        row.add(accData[i].time);
        row.add(accData[i].x);
        row.add(accData[i].y);
        row.add(accData[i].z);
        rows.add(row);
      }
    }
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      print('Permission for storage is not set yet.');
    } else if (await Permission.storage.isRestricted) {
      print('No Permission for storage was granted');
    } else if (await Permission.storage.isGranted) {
      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getExternalStorageDirectory();

      String pathOfTheFileToWrite;
      DateTime temp = DateTime.now();
      if (q == 0) {
        pathOfTheFileToWrite = directory.path + "/" + "fypAccData$temp.csv";
      } else {
        pathOfTheFileToWrite = directory.path + "/" + "fypLinData$temp.csv";
      }
      print(csv);
      dataFile = null;
      dataFile = File(pathOfTheFileToWrite);

      await dataFile.writeAsString(csv);
      print('Wrote csv file to $pathOfTheFileToWrite');
      csvPath = '';
      csvPath = pathOfTheFileToWrite;
    }
  }

  ///===========================================================================
}
