import 'package:flutter/cupertino.dart';
import 'package:flutter_clock/services/worldtime.dart';

class TimeProvider extends ChangeNotifier {
  WorldTime worldTime;

  TimeProvider({required this.worldTime});

  void change(WorldTime worldTime) {
    this.worldTime = worldTime;
    notifyListeners();
  }
}
