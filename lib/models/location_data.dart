import 'package:geolocator/geolocator.dart';

class LocationData {
  final Position position;
  LocationData({
    required this.position,
  });
  LocationData.fromJson(Map<String, dynamic> json)
      : position = Position(
            longitude: json['position']['longitude'],
            latitude: json['position']['latitude'],
            timestamp: DateTime.parse(json['position']['timestamp']),
            accuracy: json['position']['accuracy'],
            altitude: json['position']['altitude'],
            heading: json['position']['heading'],
            speed: json['position']['speed'],
            speedAccuracy: json['position']['speedAccuracy']);

  Map<String, dynamic> toJson() => {
        'position': {
          "longitude": position.longitude,
          "latitude": position.latitude,
          "timestamp": position.timestamp!.toIso8601String(),
          "accuracy": position.accuracy,
          "altitude": position.altitude,
          "heading": position.heading,
          "speed": position.speed,
          "speedAccuracy": position.speedAccuracy,
        },
      };
}
