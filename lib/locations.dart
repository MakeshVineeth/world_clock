import 'dart:convert';

import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock/services/worldtime.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  List<WorldTime> locations = [];
  Map listData = {};

  @override
  void initState() {
    super.initState();
    firstSetup();
  }

  void updateTime(index) async {
    try {
      WorldTime instance = locations[index];
      await instance.taskLoader();

      final prefs = await SharedPreferences
          .getInstance(); // We set SharedPrefs only when changing the location
      prefs.setString('url', instance.url);
      prefs.setString('flag', instance.flag);
      prefs.setString('location', instance.location);

      Navigator.pop(context, {
        'time': instance.time,
        'isDayTime': instance.isDayTime,
        'location': instance.location,
        'flag': instance.flag,
        'date': instance.date,
        'url': instance.url,
        'secondsLeft': instance.secondsLeft
      });
    } catch (e) {}
  }

  void firstSetup() async {
    try {
      WorldTime ins = WorldTime(url: "", location: "");
      await ins.getList();
      Map e = jsonDecode(await rootBundle.loadString('assets/countries.json'));
      for (var item in ins.listData) {
        String listItem = item.toString();

        String flag = e['$listItem'].toString().toLowerCase();
        flag = 'https://www.countryflags.io/$flag/flat/32.png';
        if (flag.contains('null')) {
          flag =
              'https://cdn2.iconfinder.com/data/icons/Siena/32/globe%20green.png';
        }

        listItem = listItem.replaceAll('[', '');
        listItem = listItem.replaceAll(' ', '');

        var temp = listItem.split('/');
        String countryName = temp[temp.length - 1];
        countryName = countryName.replaceAll('_', ' ');

        setState(() {
          locations
              .add(WorldTime(url: listItem, location: countryName, flag: flag));
        });
      }
    } catch (e) {}
  }

  Widget loadCards(int index) {
    return Card(
      child: ListTile(
        onTap: () async {
          updateTime(index);
        },
        title: Row(
          children: [
            Image(
              image: NetworkImage('${locations[index].flag}'),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              locations[index].location,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Card>> search(String search) async {
    await Future.delayed(Duration(seconds: 1));
    List<Card> lists = [];
    for (var i = 0; i < locations.length; i++) {
      if (locations[i].url.toLowerCase().contains(search.toLowerCase())) {
        lists.add(loadCards(i));
      }
    }
    return lists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choose Location'),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 2.0),
          color: Colors.white,
          child: SearchBar<Card>(
            onSearch: search,
            suggestions:
                List.generate(locations.length, (index) => loadCards(index)),
            onItemFound: (Card foundCard, int index) {
              return Card(
                child: foundCard.child,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 3.0,
              );
            },
            searchBarStyle: SearchBarStyle(
              padding: EdgeInsets.all(5),
              borderRadius: BorderRadius.circular(20),
            ),
            minimumChars: 2,
            onError: (error) {
              return Center(
                child: Text(
                  "Error occurred : $error",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            emptyWidget: Center(
              child: Text(
                "No Results",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            cancellationWidget: Text(
              "Cancel",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
              child: Icon(
                Icons.search,
              ),
            ),
            hintText: "Type here to search...",
            searchBarPadding: EdgeInsets.all(15.0),
            listPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            iconActiveColor: Colors.blue,
          ),
        ));
  }
}
