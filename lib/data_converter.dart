import 'package:fl_chart/fl_chart.dart';
import 'sensor_and_gps.dart';

class DataConverter {
  SensorData sensorData = SensorData();
  List<FlSpot> chartDataX = [];
  List<FlSpot> chartDataY = [];
  List<FlSpot> chartDataZ = [];

  ///=======Converting accelerometer data to FLSpots============================
  ///The fl_chart plugin can only display FLSpots, so the accelerometer data
  ///has to be converted. There are 3 converting methods each method converting
  ///a specific accelerometer axis.

  List<FlSpot> FLSpotConversion_TX(List<MeasuredDataObject> accData) {
    for (int i = 0; i < accData.length; i++) {
      chartDataX.add(
        FlSpot(
          accData[i].time,
          accData[i].x,
        ),
      );
      i += 9;
    }
    return chartDataX;
  }

  List<FlSpot> FLSpotConversion_TY(List<MeasuredDataObject> accData) {
    for (int i = 0; i < accData.length; i++) {
      chartDataY.add(
        FlSpot(
          accData[i].time,
          accData[i].y,
        ),
      );
      i += 9;
    }
    return chartDataY;
  }

  List<FlSpot> FLSpotConversion_TZ(List<MeasuredDataObject> accData) {
    for (int i = 0; i < accData.length; i++) {
      chartDataZ.add(
        FlSpot(
          accData[i].time,
          accData[i].z,
        ),
      );
      i += 9;
    }
    return chartDataZ;
  }

///===========================================================================
}
