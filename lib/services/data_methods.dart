import 'package:flutter/cupertino.dart';
import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataMethods {
  final Duration _timeOut = const Duration(seconds: 10);
  final String httpStr = 'http://';

  Future<Response> getData(String urlStr) async {
    try {
      String fullUrl = Uri.encodeFull(httpStr + urlStr);
      Uri url = Uri.parse(fullUrl);
      return await get(url).timeout(_timeOut, onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  Future<List> getList() async {
    try {
      Response responseList = await getData('worldtimeapi.org/api/timezone');

      if (responseList == null) return const [];
      List listData = jsonDecode(responseList.body);

      return listData;
    } catch (_) {
      return const [];
    }
  }

  Future<WorldTime> getTime(
      {@required String location,
      @required String url,
      @required String flag}) async {
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
    } catch (_) {
      return WorldTime(location: location, url: url, flag: flag);
    }
  }

  Future<bool> getNewTimeData(TimeProvider timeProvider) async {
    try {
      final WorldTime old = timeProvider.worldTime;
      final WorldTime newTime =
          await getTime(location: old.location, url: old.url, flag: old.flag);

      if (newTime?.isDayTime != null && newTime?.time != null) {
        timeProvider.change(newTime);
        return true;
      } else {
        final WorldTime oldTime = WorldTime(
          isDayTime: old.isDayTime,
          location: old.location,
          url: old.url,
          flag: old.flag,
          date: old.date,
          secondsLeft: 10,
          time: old.time,
        );

        timeProvider.change(oldTime);
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<WorldTime> getDefaultClock() async {
    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location');
    String url = prefs.getString('url');
    String flag = prefs.getString('flag');

    // Also checking for country flags string as previously it uses online to get this flag icons.
    if (location == null ||
        url == null ||
        flag.contains('https://www.countryflags.io')) {
      location = 'Asia, Kolkata';
      url = 'Asia/Kolkata';
      flag = 'icons/flags/png/in.png';
    }

    WorldTime instance = await getTime(
      location: location,
      url: url,
      flag: flag,
    );

    return instance;
  }
}
