import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/location_data.dart';

class LocationProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  final List<LocationData> _locationDatas;
  static final Uri baseUrl = Uri.parse(
      'https://trackapp-bc490-default-rtdb.europe-west1.firebasedatabase.app/');
  LocationProvider(this.authToken, this.userId, this._locationDatas);

  List<LocationData> get locations {
    return _locationDatas;
  }

  Future<void> getLocationChanges() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    /*
          Geolocator.getCurrentPosition().then((position) async {
            //print(position.toString());
            await Provider.of<LocationProvider>(context, listen: false)
                .postLocation(LocationData(id: "3", position: position));
          });*/
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (position != null) {
        {
          await postLocation(LocationData(position: position));
          //();
        }
      }
      //print("position null geldi");
      //print(position.toString());
    });
    /*.listen(
      (Position? position) async {
        
        if (position != null) {
          oldPosition = position;
          print("girdim");
        }
      },
    );*/
    //positionStream.cancel();
    //await postLocation(LocationData(position: fetchedPosition!));
  }

  Future<void> postLocation(LocationData locationData) async {
    final Uri url = Uri.parse('$baseUrl$userId/positions.json?auth=$authToken');
    Map<String, dynamic> data = locationData.toJson();
    try {
      await http.post(url, body: json.encode(data));
      _locationDatas.add(locationData);
    } catch (error) {
      rethrow;
    }
  }
/*
  Future<void> fetchLocations() async {
    _locationDatas.clear();
    final Uri url = Uri.parse('$baseUrl$userId/positions.json?auth=$authToken');
    //_locationDatas.add(locationData);
    final http.Response response = await http.get(url);
    final Map<String, dynamic> extractedData = jsonDecode(response.body);
    extractedData.forEach((locId, locData) {
      _locationDatas.add(LocationData.fromJson(locData));
      //print(_locationDatas.toString());
      notifyListeners();
    });
  }*/
}
