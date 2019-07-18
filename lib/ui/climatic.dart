import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'package:http/http.dart' as http;
import 'dart:async';

class Climatic extends StatefulWidget {
  @override
  _ClimaticState createState() => _ClimaticState();
}

class _ClimaticState extends State<Climatic> {
  String _cityEntered;

  Future _goToTheNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute<Map>(builder: (BuildContext context) {
        return ChangeCity();
      }),
    );
    if (results != null && results.containsKey('Enter')) {
      _cityEntered = results['Enter'];
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appKey, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Climatic"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.menu,
            ),
            onPressed: () {
              _goToTheNextScreen(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/umbrella.png",
              fit: BoxFit.fill,
              width: 490.0,
              height: 1200.0,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              "${_cityEntered == null ? util.defaultCity : _cityEntered}",
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset("images/light_rain.png"),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30.0, 260.0, 0.0, 0.0),
            child: updateTempWidget(_cityEntered),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiURL =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appKey}&units=metric";
    http.Response response = await http.get(apiURL);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: getWeather(util.appKey, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      content["main"]["temp"].toString() + " C",
                      style: tempStyle(),
                    ),
                    subtitle: ListTile(
                      title: Text(
                        "Humidity: ${content["main"]["humidity"].toString()}\n"
                            "Min: ${content["main"]["temp_min"].toString()} C\n"
                            "Max: ${content["main"]["temp_max"].toString()} C",
                        style: extraData(),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else
            return Container();
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change City",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "images/white_snow.png",
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(hintText: "Enter Your City"),
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {'Enter': _cityFieldController.text});
                  },
                  child: Text("Get Weather"),
                  color: Colors.redAccent,
                  textColor: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle extraData() {
  return TextStyle(
      color: Colors.white70,
      fontSize: 17.7,
      fontStyle: FontStyle.normal);
}

TextStyle tempStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 49.9,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500);
}
