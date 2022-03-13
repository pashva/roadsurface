import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensordatenapp/screenSizeProperties.dart';
import 'package:sensordatenapp/sensor_and_gps.dart';
import 'data_converter.dart';

class ChartLayout {
  double maximumX = 0;
  double minimumX = 0;
  double maximumY = 0;
  double minimumY = 0;
  List<FlSpot> accelerometerData = [];

  ///=====Checking maximum and minimum value of x and y axis====================
  ///Is needed for building responsive charts, so no accelerometer chart will
  ///be overflowed.
  Future<void> MaxMinXandY() {
    for (var i = 0; i < accelerometerData.length; i++) {
      if (accelerometerData[i].x > maximumX) {
        maximumX = accelerometerData[i].x;
      }
      if (accelerometerData[i].x < minimumX) {
        minimumX = accelerometerData[i].x;
      }
    }
    for (var i = 0; i < accelerometerData.length; i++) {
      if (accelerometerData[i].y > maximumY) {
        maximumY = accelerometerData[i].y;
      }
      if (accelerometerData[i].y < minimumY) {
        minimumY = accelerometerData[i].y;
      }
    }
  }

  ///===========================================================================
}

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  ///Needed for general functionality of Chart Plugin
  List<Color> lineColor = [
    Color(0xFF655BB5),
  ];
  List<MeasuredDataObject> accData = [];
  bool dataForChartFinished = false;

  ///Special variables for Chart Plugin
  DataConverter dataConverter = DataConverter();
  ChartLayout xAccelerometerChart = ChartLayout();
  ChartLayout yAccelerometerChart = ChartLayout();
  ChartLayout zAccelerometerChart = ChartLayout();

  @override
  Widget build(BuildContext context) {
    accData = ModalRoute.of(context).settings.arguments;
    accDataToChartDataConverter(accData);
    ScreenSizeProperties().init(context);
    return dataForChartFinished
        ? Scaffold(
            body: SafeArea(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Accelerometer Data Chart',
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: ScreenSizeProperties.safeBlockVertical * 70,
                    width: ScreenSizeProperties.safeBlockHorizontal * 100,
                    padding: EdgeInsets.all(
                        ScreenSizeProperties.safeBlockVertical * 3),
                    margin: EdgeInsets.only(
                        left: ScreenSizeProperties.safeBlockHorizontal * 6,
                        right: ScreenSizeProperties.safeBlockHorizontal * 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 6,
                          blurRadius: 15,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'x-Accelerometer Data',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: ScreenSizeProperties.safeBlockVertical * 1,
                        ),
                        Expanded(
                          child: LineChart(
                            buildChart(xAccelerometerChart),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'y-Accelerometer Data',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: ScreenSizeProperties.safeBlockVertical * 1,
                        ),
                        Expanded(
                          child: LineChart(
                            buildChart(yAccelerometerChart),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'z-Accelerometer Data',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: ScreenSizeProperties.safeBlockVertical * 1,
                        ),
                        Expanded(
                          child: LineChart(
                            buildChart(zAccelerometerChart),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenSizeProperties.safeBlockVertical * 2,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: ScreenSizeProperties.safeBlockHorizontal * 6,
                        right: ScreenSizeProperties.safeBlockHorizontal * 6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
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
                            height: 60,
                            child: FlatButton(
                              child: Text(
                                'Go back',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ScreenSizeProperties.safeBlockHorizontal * 2,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF655BB5),
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
                            height: 60,
                            child: FlatButton(
                              child: Text(
                                'Predict Road Surface',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                setState(() {
                                  dataForChartFinished = false;
                                });

                                Navigator.of(context).pushNamedAndRemoveUntil('/result', (Route<dynamic> route) => false);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
          )
        : Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Container(
                      child: Text('Building chart...'),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  ///============Converting accelerometer data to FLSpots=======================
  ///Convert accelerometer data into data, which the fl chart plugin can understand
  ///and use for building the line chart. It extracts (currently) the time
  ///and Axis data from the whole measured dataset "sensordata". Time is
  ///represented on the xAxis of the Chart, whereas accelerometer data is on
  ///the yAxis of the Chart.

  accDataToChartDataConverter(List<MeasuredDataObject> data) async {
    xAccelerometerChart.accelerometerData =
        dataConverter.FLSpotConversion_TX(data);
    yAccelerometerChart.accelerometerData =
        dataConverter.FLSpotConversion_TY(data);
    zAccelerometerChart.accelerometerData =
        dataConverter.FLSpotConversion_TZ(data);

    await xAccelerometerChart.MaxMinXandY();
    await yAccelerometerChart.MaxMinXandY();
    await zAccelerometerChart.MaxMinXandY();

    setState(() {
      dataForChartFinished = true;
    });
  }

  ///===========================================================================

  ///==========Method for building the accelerometer data charts================
  LineChartData buildChart(ChartLayout data) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: false,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.w500,
              fontSize: 16),
          getTitles: (value) {
            if (value.toInt() == data.minimumX.toInt()) {
              return data.minimumX.toInt().toString();
            }

            if (value.toInt() == data.maximumX.toInt()) {
              return data.maximumX.toInt().toString();
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value.toInt() == data.minimumY.toInt()) {
              return data.minimumY.toInt().toString();
            }

            if (value.toInt() == data.maximumY.toInt()) {
              return data.maximumY.toInt().toString();
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      axisTitleData: FlAxisTitleData(
        leftTitle:
            AxisTitle(showTitle: true, titleText: 'accelerometer', margin: 4),
        bottomTitle: AxisTitle(
            showTitle: true,
            margin: 0,
            titleText: 'time (s)',
            textStyle: TextStyle(color: Colors.black, fontSize: 14),
            textAlign: TextAlign.right),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: data.minimumX,
      maxX: data.maximumX,
      minY: data.minimumY,
      maxY: data.maximumY,
      lineBarsData: [
        LineChartBarData(
          colors: lineColor,
          spots: data.accelerometerData,
          isCurved: false,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }

  ///===========================================================================
}
