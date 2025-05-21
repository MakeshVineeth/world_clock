import 'dart:convert';

import 'package:flutter_clock/services/time_provider.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataMethods {
  final Duration _timeOut = const Duration(seconds: 10);
  final String httpStr = 'http://';

  Future<Response> getData(String urlStr) async {
    try {
      String fullUrl = Uri.encodeFull(httpStr + urlStr);
      Uri url = Uri.parse(fullUrl);
      return await get(url).timeout(_timeOut,
          onTimeout: () => Response("Error Timeout", 504));
    } catch (_) {
      return Response("Error retrieving data", 500);
    }
  }

  Future<List> getList() async {
    try {
      Response responseList = await getData('worldtimeapi.org/api/timezone');
      List listData = jsonDecode(responseList.body);

      return listData;
    } catch (_) {
      return const [];
    }
  }

  Future<WorldTime> getTime(
      {required String location,
      required String url,
      required String flag}) async {
    try {
      Response? response = await getData('worldtimeapi.org/api/timezone/$url');
      Map e = jsonDecode(response.body);

      String dumpTime = e['datetime'];
      String offset = e['utc_offset'].substring(1);
      String check = e['utc_offset'].substring(0, 1);
      DateTime now = DateTime.parse(dumpTime);

      int? hours = int.tryParse(offset.split(":")[0]);
      int? min = int.tryParse(offset.split(":")[1]);

      if (check.contains('-')) {
        now = now.subtract(Duration(hours: hours!, minutes: min!));
      } else {
        now = now.add(Duration(hours: hours!, minutes: min!));
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
      return WorldTime(
          location: location,
          url: url,
          flag: flag,
          date: '',
          isDayTime: true,
          time: '');
    }
  }

  Future<bool> getNewTimeData(TimeProvider timeProvider) async {
    try {
      final WorldTime old = timeProvider.worldTime;
      final WorldTime newTime =
          await getTime(location: old.location, url: old.url, flag: old.flag);

      timeProvider.change(newTime);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<WorldTime> getDefaultClock() async {
    String defaultLocation = 'Asia, Kolkata';
    String defaultUrl = 'Asia/Kolkata';
    String defaultFlag = 'icons/flags/png/in.png';

    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location') ?? "";
    String url = prefs.getString('url') ?? "";
    String flag = prefs.getString('flag') ?? "";
    WorldTime instance;

    // Also checking for country flags string as previously it uses online to get this flag icons.
    if (flag == "" ||
        location == "" ||
        url == "" ||
        flag.contains('https://www.countryflags.io')) {
      instance = await getTime(
        location: defaultLocation,
        url: defaultUrl,
        flag: defaultFlag,
      );
    }

    instance = await getTime(
      location: location,
      url: url,
      flag: flag,
    );

    return instance;
  }
}
