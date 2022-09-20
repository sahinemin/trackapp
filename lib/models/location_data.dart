import 'package:geolocator/geolocator.dart';

class LocationData {
  final Position position;
  LocationData({
    required this.position,
  });
  LocationData.fromJson(Map<String, dynamic> json)
      : position = Position(
          longitude: json['longitude'],
          latitude: json['latitude'],
          timestamp: DateTime.parse(json['timestamp']),
          accuracy: json['accuracy'],
          altitude: json['altitude'],
          heading: json['heading'],
          speed: json['speed'],
          speedAccuracy: json['speedAccuracy'],
        );

  Map<String, dynamic> toJson() => {
        "longitude": position.longitude,
        "latitude": position.latitude,
        "timestamp": position.timestamp!.toIso8601String(),
        "accuracy": position.accuracy,
        "altitude": position.altitude,
        "heading": position.heading,
        "speed": position.speed,
        "speedAccuracy": position.speedAccuracy,
      };
}
