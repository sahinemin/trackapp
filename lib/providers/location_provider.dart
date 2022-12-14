import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:trackapp/helpers/location_helper.dart';
import '../models/location_data.dart';

class LocationProvider with ChangeNotifier {
  final String? authToken;
  final String? userId;
  final List<LocationData> _locationDatas;
  late final StreamSubscription<Position> _streamSubscription;
  static final Uri baseUrl = Uri.parse(
      'https://trackapp-bc490-default-rtdb.europe-west1.firebasedatabase.app/');
  LocationProvider(this.authToken, this.userId, this._locationDatas);

  List<LocationData> get locations {
    return _locationDatas;
  }

  Future<void> endStream() async {
    await _streamSubscription.cancel();
  }

  Future<void> getLocationChanges() async {
    Stream<Position> stream = await LocationHelper.getLocationStream();
    _streamSubscription = stream.listen((Position? position) async {
      //print(userId);
      if (position != null && userId != null) {
        {
          await postLocation(LocationData(position: position));
        }
      }
    });
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

  Future<List> fetchLocations(String userLocId) async {
    _locationDatas.clear();
    final Uri url =
        Uri.parse('$baseUrl$userLocId/positions.json?auth=$authToken');
    //_locationDatas.add(locationData);
    final http.Response response = await http.get(url);
    final Map<String, dynamic> extractedData = jsonDecode(response.body);
    extractedData.forEach((locId, locData) {
      _locationDatas.add(LocationData.fromJson(locData));
    });
    notifyListeners();
    return await getLocationSnap(_locationDatas);
  }

  Future<List> getLocationSnap(List<LocationData> locDatas) async {
    String path = "";
    for (var element in locDatas) {
      path += "${element.position.latitude},${element.position.longitude}|";
    }
    path = path.substring(0, path.length - 1);
    final Uri url = Uri.parse(
        'https://roads.googleapis.com/v1/snapToRoads?interpolate=true&path=$path&key=AIzaSyCxoClFWl5kra_EYTp3mXHQouZQl9xrN_w');
    final http.Response response = await http.get(url);
    final Map<String, dynamic> extractedData = jsonDecode(response.body);
    return extractedData['snappedPoints'];
  }
}
