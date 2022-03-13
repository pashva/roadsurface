import 'package:flutter/material.dart';

///==========================Providers==========================================
///These Providers are needed for state management of the home page.

class ViewNotifier extends ChangeNotifier {
  var show = {
    'showLogo': true,
    'startMeasuring': true,
    'stopMeasuring': false,
    'buildChart': false,
    'showIndicator': false,
    'showLoading': false,
  };
  Stopwatch watch = Stopwatch();

  void switchView(String index) {
    print(index);
    if (show[index] == true) {
      show[index] = false;
      notifyListeners();
    } else if (show[index] == false) {
      show[index] = true;
      notifyListeners();
    }
  }

  void startWatch() {
    watch.start();
  }

  void getTime() {
    while (watch.isRunning) {
      notifyListeners();
    }
  }

  void stopWatch() {
    watch.stop();
  }
}
