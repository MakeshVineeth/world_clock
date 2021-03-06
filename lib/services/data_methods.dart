import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataMethods {
  final Duration _timeOut = const Duration(minutes: 1);
  final String httpStr = 'https://';

  Future<Response> getData(String urlStr) async {
    try {
      String fullUrl = httpStr + urlStr;

      return await get(fullUrl).timeout(_timeOut, onTimeout: () => null);
    } catch (e) {
      return null;
    }
  }

  Future<List> getList() async {
    try {
      Response responseList = await getData('worldtimeapi.org/api/timezone');

      if (responseList == null) return [];

      List listData = jsonDecode(responseList.body);
      return listData;
    } catch (e) {
      return [];
    }
  }

  Future<WorldTime> getTime({String location, String url, String flag}) async {
    try {
      Response response = await getData('worldtimeapi.org/api/timezone/$url');

      Map e = jsonDecode(response.body);

      String dumpTime = e['datetime'];
      String offset = e['utc_offset'].substring(1);
      String check = e['utc_offset'].substring(0, 1);
      DateTime now = DateTime.parse(dumpTime);

      int hours = int.tryParse(offset.split(":")[0]);
      int min = int.tryParse(offset.split(":")[1]);

      if (check.contains('-')) {
        now = now.subtract(Duration(hours: hours, minutes: min));
      } else {
        now = now.add(Duration(hours: hours, minutes: min));
      }

      DateFormat formatter = DateFormat('dd-MMM-yyyy');
      String date = formatter.format(now);

      bool isDayTime = now.hour > 6 && now.hour < 19 ? true : false;
      String time = DateFormat.jm().format(now);
      int secondsLeft = 60 - now.second;

      return WorldTime(
        location: location,
        url: url,
        flag: flag,
        date: date,
        isDayTime: isDayTime,
        time: time,
        secondsLeft: secondsLeft,
      );
    } catch (e) {
      return WorldTime(location: location, url: url, flag: flag);
    }
  }

  Future<void> getNewTimeData(TimeProvider timeProvider) async {
    WorldTime old = timeProvider.worldTime;
    WorldTime newTime =
        await getTime(location: old.location, url: old.url, flag: old.flag);

    if (newTime?.isDayTime != null && newTime?.time != null)
      timeProvider.change(newTime);
    else {
      timeProvider.change(WorldTime(
        isDayTime: old.isDayTime,
        location: old.location,
        url: old.url,
        flag: old.flag,
        date: old.date,
        secondsLeft: 10,
        time: old.time,
      ));
    }
  }

  Future<WorldTime> getDefaultClock() async {
    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location');
    String url = prefs.getString('url');
    String flag = prefs.getString('flag');

    if (location == null) {
      location = 'Kolkata';
      url = 'Asia/Kolkata';
      flag = 'https://www.countryflags.io/in/flat/32.png';
    }

    WorldTime instance =
        await getTime(location: location, url: url, flag: flag);

    return instance;
  }
}
