import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trackapp/providers/location_provider.dart';

class UserLocation extends StatelessWidget {
  static const String routeName = '/userLocation';
  //final String title;
  const UserLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text("${arguments['email']}'s Location Map"))),
      body: FutureBuilder<List>(
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                //
                //return Text(snapshot.data![0].position.toString());
                return GoogleMap(
                  markers: {
                    Marker(
                      position: LatLng(
                        snapshot.data![0]['location']['latitude'],
                        snapshot.data![0]['location']['longitude'],
                      ),
                      markerId: MarkerId(snapshot.data![0]['placeId']),
                    ),
                    if (snapshot.data!.length > 1)
                      Marker(
                          position: LatLng(
                            snapshot.data![snapshot.data!.length - 1]
                                ['location']['latitude'],
                            snapshot.data![snapshot.data!.length - 1]
                                ['location']['longitude'],
                          ),
                          markerId: MarkerId(snapshot
                              .data![snapshot.data!.length - 1]['placeId']))
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      snapshot.data![0]['location']['latitude'],
                      snapshot.data![0]['location']['longitude'],
                    ),
                    zoom: 14,
                  ),
                  polylines: {
                    Polyline(
                        color: Colors.blue,
                        polylineId: PolylineId(snapshot.data![0]['placeId']),
                        points: snapshot.data!
                            .map((position) => LatLng(
                                position['location']['latitude'],
                                position['location']['longitude']))
                            .toList())
                  },
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const Center(
                child: Text(
              "error",
              style: TextStyle(fontSize: 48),
            ));
          },
          future: Provider.of<LocationProvider>(context, listen: false)
              .fetchLocations(arguments['userId'])),
    );
  }
}
