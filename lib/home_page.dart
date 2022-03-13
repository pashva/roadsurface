import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensordatenapp/providers.dart';
import 'package:sensordatenapp/screenSizeProperties.dart';
import 'sensor_and_gps.dart';
import 'data_converter.dart';
import 'package:provider/provider.dart';
import 'csv.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

enum ChangeState {
  no,
  light,
  medium,
  high,
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double coefficient;
  int frequency;
  final myController = TextEditingController();
  SensorData sensorData = SensorData();
  Csv csv = Csv();
  DataConverter switchCreator = DataConverter();
  List<MeasuredDataObject> tempAccData = [];
  ChangeState selectedState;
  Stopwatch watch = Stopwatch();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizeProperties().init(context);

    return ChangeNotifierProvider<ViewNotifier>(
      create: (context) => ViewNotifier(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Consumer<ViewNotifier>(
                      builder: (context, _, child) {
                        return _.show['showLogo']
                            ? Container(
                                height:
                                    ScreenSizeProperties.safeBlockHorizontal *
                                        50,
                                width:
                                    ScreenSizeProperties.safeBlockHorizontal *
                                        50,
                                child:
                                    Image.asset('assets/images/pothole.webp'),
                              )
                            : Container();
                      },
                    ),
                    Consumer<ViewNotifier>(
                      builder: (context, _, child) {
                        return _.show['showLogo']
                            ? Container(
                                child: Text(
                                  'Road Assessment',
                                  style: TextStyle(fontSize: 26),
                                ),
                              )
                            : Container();
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Consumer<ViewNotifier>(
                      builder: (context, _, child) {
                        return _.show['startMeasuring']
                            ? Row(
                                children: [
                                  MainButton(
                                    title: 'Start Driving',
                                    color: Colors.white,
                                    textColor: Colors.black,
                                    function: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Information"),
                                            content: Text(
                                                "Please record at least 30 seconds of cycling. Otherwise the "
                                                "road surface prediction cannot be executed. Recording will start after pressing on OK."),
                                            actions: [
                                              FlatButton(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  sensorData.startDataStream();
                                                  sensorData.trackPosition();
                                                  _.switchView('showLogo');
                                                  _.switchView(
                                                      'startMeasuring');
                                                  _.switchView('stopMeasuring');
                                                  _.switchView('showIndicator');
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  MainButton(
                                    title: 'Capture Image',
                                    color: Colors.white,
                                    textColor: Colors.black,
                                    function: () async {
                                      // String res = await Tflite.loadModel(
                                      //     model: "assets/linear.tflite",
                                      //     labels: "assets/labels.txt",
                                      //     numThreads: 2, // defaults to 1
                                      //     isAsset:
                                      //         true, // defaults to true, set to false to load resources outside assets
                                      //     useGpuDelegate:
                                      //         false // defaults to false, set to true to use GPU delegate
                                      //     );

                                      // final ImagePicker _picker = ImagePicker();
                                      // ignore: deprecated_member_use
                                      final photo = await ImagePicker.pickImage(
                                          source: ImageSource.gallery);
                                      final bytes =
                                          File(photo.path).readAsBytesSync();
                                      String base64Image = base64Encode(bytes);

                                      // print("img_pan : $base64Image");
                                      var res = await http.post(
                                        "https://3228-2405-201-1f-fc7d-99e0-dfbc-aa91-189.ngrok.io/test",
                                        headers: <String, String>{
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json'
                                        },
                                        body: jsonEncode(<String, String>{
                                          'photo': base64Image,
                                        }),
                                      );

                                      var _result = jsonDecode(res.body);
                                      print(_result);
                                      Fluttertoast.showToast(
                                          msg: (_result['classLabel'] == "Plain"
                                                  ? "No Potholes "
                                                  : _result['classLabel']) +
                                              " Detected",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      // var recognitions =
                                      //     await Tflite.runModelOnImage(
                                      //   path: photo.path, // required
                                      // );
                                      // print(recognitions);
                                      MeasuredDataObject measuredData =
                                          MeasuredDataObject(
                                        position: await Geolocator()
                                            .getCurrentPosition(
                                                desiredAccuracy:
                                                    LocationAccuracy.high),
                                        time:
                                            watch.elapsed.inSeconds.toDouble(),
                                      );

                                      var x = await Geolocator()
                                          .placemarkFromCoordinates(
                                              measuredData.position.latitude,
                                              measuredData.position.longitude);
                                      print(x[0].thoroughfare);
                                      print(x[0].locality);
                                      print(x[0].subLocality);
                                      print(x[0].postalCode);
                                      // print(x[0].name);
                                      print(measuredData.position.latitude);
                                      print(measuredData.position.longitude);

                                      var res1 = await http.post(
                                        "https://3228-2405-201-1f-fc7d-99e0-dfbc-aa91-189.ngrok.io/pothole",
                                        headers: <String, String>{
                                          'Content-Type': 'application/json',
                                          'Accept': 'application/json'
                                        },
                                        body: jsonEncode({
                                          'long':
                                              measuredData.position.longitude,
                                          'lat': measuredData.position.latitude,
                                          'road': x[0].thoroughfare,
                                          'city': x[0].locality,
                                          'locality': x[0].subLocality,
                                          'postcode': x[0].postalCode
                                        }),
                                      );
                                      print(res1.body);
                                    },
                                  )
                                ],
                              )
                            : _.show['showIndicator']
                                ? Container(
                                    width: ScreenSizeProperties
                                            .safeBlockHorizontal *
                                        50,
                                    height: ScreenSizeProperties
                                            .safeBlockHorizontal *
                                        50,
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          Lottie.asset(
                                              'assets/lottie/road.json',
                                              height: 180,
                                              width: 180),
                                          // SizedBox(
                                          //   height: ScreenSizeProperties
                                          //           .safeBlockVertical *
                                          //       2,
                                          // ),
                                          // Text(
                                          //     'Recording accelerometer data...'),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container();
                      },
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Consumer<ViewNotifier>(
                      builder: (context, _, child) {
                        return _.show['stopMeasuring']
                            ? MainButton(
                                title: 'Stop Driving',
                                color: Colors.white,
                                textColor: Colors.black,
                                function: () async {
                                  tempAccData =
                                      await sensorData.stopDataStream();
                                  _.stopWatch();
                                  _.switchView('stopMeasuring');
                                  _.switchView('buildChart');
                                  _.switchView('showIndicator');
                                },
                              )
                            : Container();
                      },
                    ),
                    Consumer<ViewNotifier>(
                      builder: (context, _, child) {
                        return _.show['buildChart']
                            ? Container(
                                padding: EdgeInsets.all(
                                    ScreenSizeProperties.safeBlockHorizontal *
                                        5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 6,
                                      blurRadius: 15,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                width:
                                    ScreenSizeProperties.safeBlockHorizontal *
                                        75,
                                height:
                                    ScreenSizeProperties.safeBlockVertical * 65,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Choose your suspension type',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: ScreenSizeProperties
                                              .safeBlockVertical *
                                          6,
                                      thickness: 2,
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    Container(
                                      height: ScreenSizeProperties
                                              .safeBlockVertical *
                                          10,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedState =
                                                      ChangeState.no;
                                                  coefficient = 0.0;
                                                  print(
                                                      'coefficient is $coefficient');
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    ScreenSizeProperties
                                                            .safeBlockHorizontal *
                                                        1),
                                                decoration: BoxDecoration(
                                                  color: selectedState ==
                                                          ChangeState.no
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 3,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'No suspension',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: ScreenSizeProperties
                                                    .safeBlockHorizontal *
                                                4,
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedState =
                                                      ChangeState.light;
                                                  coefficient = 0.15;
                                                  print(
                                                      'coefficient is $coefficient');
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    ScreenSizeProperties
                                                            .safeBlockHorizontal *
                                                        1),
                                                decoration: BoxDecoration(
                                                  color: selectedState ==
                                                          ChangeState.light
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 3,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Light suspension',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenSizeProperties
                                              .safeBlockVertical *
                                          1.5,
                                    ),
                                    Container(
                                      height: ScreenSizeProperties
                                              .safeBlockVertical *
                                          10,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedState =
                                                      ChangeState.medium;
                                                  coefficient = 0.33;
                                                  print(
                                                      'coefficient is $coefficient');
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    ScreenSizeProperties
                                                            .safeBlockHorizontal *
                                                        1),
                                                decoration: BoxDecoration(
                                                  color: selectedState ==
                                                          ChangeState.medium
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 3,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Medium suspension',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: ScreenSizeProperties
                                                    .safeBlockHorizontal *
                                                4,
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedState =
                                                      ChangeState.high;
                                                  coefficient = 0.48;
                                                  print(
                                                      'coefficient is $coefficient');
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    ScreenSizeProperties
                                                            .safeBlockHorizontal *
                                                        1),
                                                decoration: BoxDecoration(
                                                  color: selectedState ==
                                                          ChangeState.high
                                                      ? Colors.white
                                                      : Colors.grey
                                                          .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      spreadRadius: 3,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'High suspension',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: ScreenSizeProperties
                                              .safeBlockVertical *
                                          3,
                                    ),
                                    coefficient != null
                                        ? Column(
                                            children: <Widget>[
                                              MainButton(
                                                title:
                                                    'Show Graph before Prediction',
                                                color: Color(0xFF655BB5),
                                                textColor: Colors.white,
                                                function: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Information"),
                                                          content: RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "Please click on 'OK' ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  TextSpan(
                                                                      text:
                                                                          "only once",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  TextSpan(
                                                                    text:
                                                                        ". The App will freeze for a couple of seconds before you will get redirected to the graph page. Please have patience.",
                                                                  )
                                                                ]),
                                                          ),
                                                          actions: [
                                                            FlatButton(
                                                              child: Text("OK"),
                                                              onPressed:
                                                                  () async {
                                                                // await csv.createCSV(
                                                                //     tempAccData);

                                                                Navigator.pushNamed(
                                                                    context,
                                                                    '/graph',
                                                                    arguments:
                                                                        tempAccData);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                              ),
                                              SizedBox(
                                                height: ScreenSizeProperties
                                                        .safeBlockVertical *
                                                    2,
                                              ),
                                              MainButton(
                                                //title: 'Show Graphs',
                                                title:
                                                    'Skip Graphs and show Prediction',
                                                color: Color(0xFF655BB5),
                                                textColor: Colors.white,
                                                function: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              "Information"),
                                                          content: RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    "Please click on 'OK' ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                children: <
                                                                    TextSpan>[
                                                                  TextSpan(
                                                                      text:
                                                                          "only once",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  TextSpan(
                                                                    text:
                                                                        ". The App will freeze for a couple of seconds before you will get redirected to the prediction page. Please have patience.",
                                                                  ),
                                                                ]),
                                                          ),
                                                          actions: [
                                                            FlatButton(
                                                              child: Text("OK"),
                                                              onPressed:
                                                                  () async {
                                                                // await csv.createCSV(
                                                                //     tempAccData,
                                                                //     0);

                                                                Navigator
                                                                    .pushNamed(
                                                                        context,
                                                                        '/result');
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            : Container();
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: ScreenSizeProperties.safeBlockVertical * 2),
                  child: Text(
                    'Final year Project',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  MainButton({this.title, this.function, this.color, this.textColor});

  String title;
  Function function;
  Color color;
  Color textColor;
  SensorData sensorData = SensorData();
  DataConverter switchCreator = DataConverter();

  @override
  Widget build(BuildContext context) {
    ScreenSizeProperties().init(context);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 6,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: ScreenSizeProperties.safeBlockVertical * 8,
      width: ScreenSizeProperties.safeBlockHorizontal * 50,
      child: FlatButton(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        onPressed: function,
      ),
    );
  }
}
